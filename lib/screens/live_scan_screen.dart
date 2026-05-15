import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../utils/omr_pipeline.dart';
import '../providers/auth_provider.dart';
import '../providers/sync_provider.dart';
import '../db/database_helper.dart';
import '../models/exam.dart';
import '../models/result.dart';
import '../models/question.dart';
import 'dart:convert';

class LiveScanScreen extends StatefulWidget {
  final Exam exam;
  const LiveScanScreen({super.key, required this.exam});

  @override
  State<LiveScanScreen> createState() => _LiveScanScreenState();
}

class _LiveScanScreenState extends State<LiveScanScreen>
    with TickerProviderStateMixin {
  // Camera
  CameraController? _cameraController;
  bool _isCameraReady = false;

  // Scanning loop
  bool _isProcessing = false;
  Timer? _scanTimer;
  String _statusText = 'Initializing...';

  // Confirmation: require same ID twice to prevent misreads
  String? _pendingId;
  int _confirmCount = 0;
  static const int _requiredConfirmations = 2;
  String? _lastScannedId; // cooldown: skip if same sheet still present

  // Feedback
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

  // Results
  int _scannedCount = 0;
  final List<Map<String, dynamic>> _sessionResults = [];

  // Torch
  bool _isTorchOn = false;
  // Focus point visual
  Offset? _focusPoint;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _flashAnimation = CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeOut,
    );
    _initCamera();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _cameraController?.dispose();
    _flashController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // 720p — best balance of focus speed and detail for OMR
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      // Do NOT call setFocusMode — Android uses CONTINUOUS_VIDEO by default
      try {
        await _cameraController!.setFlashMode(FlashMode.off);
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _isCameraReady = true;
        _statusText = 'Camera ready...';
      });

      // Warm-up: let continuous AF lock before first capture
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _statusText = 'Place paper under camera');
        _startScanLoop();
      }
    } catch (e) {
      if (mounted) setState(() => _statusText = 'Camera error: $e');
    }
  }

  void _startScanLoop() {
    _scanTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (!_isProcessing && _isCameraReady && mounted) {
        _captureAndProcess();
      }
    });
  }

  Future<void> _onTapFocus(TapDownDetails details) async {
    if (!_isCameraReady || _cameraController == null) return;
    try {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset local = box.globalToLocal(details.globalPosition);
      final double dx = (local.dx / box.size.width).clamp(0.0, 1.0);
      final double dy = (local.dy / box.size.height).clamp(0.0, 1.0);
      setState(() => _focusPoint = local);
      await _cameraController!.setFocusPoint(Offset(dx, dy));
      await _cameraController!.setExposurePoint(Offset(dx, dy));
      await _cameraController!.setFocusMode(FocusMode.auto);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _focusPoint = null);
      });
    } catch (_) {}
  }

  Future<void> _captureAndProcess() async {
    if (!_isCameraReady || _cameraController == null || _isProcessing) return;
    setState(() {
      _isProcessing = true;
      _statusText = '🔍 Scanning...';
    });

    XFile? photo;
    try {
      photo = await _cameraController!.takePicture();
    } catch (_) {
      if (mounted)
        setState(() {
          _isProcessing = false;
          _statusText = 'Place paper under camera';
        });
      return;
    }

    try {
      // Use the exact same pipeline as "take pic" — no rotation
      final Map<String, dynamic> result = await compute(
        processImageInIsolate,
        photo.path,
      );

      final scannedAnswers = result['answers'] as List<int>;
      final idDigits = result['id'] as List<int>;
      final studentIdStr = idDigits.join();

      // Skip cooldown: same sheet still under camera
      if (studentIdStr == _lastScannedId) {
        if (mounted)
          setState(() {
            _isProcessing = false;
            _statusText = '✅ Done! Remove paper for next';
          });
        try {
          await File(photo.path).delete();
        } catch (_) {}
        return;
      }

      // Confirmation: require 2 consecutive same reads
      if (studentIdStr == _pendingId) {
        _confirmCount++;
      } else {
        _pendingId = studentIdStr;
        _confirmCount = 1;
      }

      if (_confirmCount < _requiredConfirmations) {
        if (mounted)
          setState(() {
            _isProcessing = false;
            _statusText = '🔍 Hold still — confirming...';
          });
        try {
          await File(photo.path).delete();
        } catch (_) {}
        return;
      }

      // ── Confirmed! Grade the paper ──
      final db = DatabaseHelper();
      final correctQuestions = await db.getQuestionsByExamId(widget.exam.id!);

      int totalMaxMark = 0;
      int studentMark = 0;
      final List<Map<String, dynamic>> answerData = [];

      for (int i = 0; i < scannedAnswers.length; i++) {
        final qNum = i + 1;
        final correctQ = correctQuestions.firstWhere(
          (q) => q.questionNumber == qNum,
          orElse: () => Question(
              examId: -1, questionNumber: -1, correctChoice: -1, mark: 0),
        );

        String sel = 'Blank';
        if (scannedAnswers[i] >= 0)
          sel = String.fromCharCode(65 + scannedAnswers[i]);
        else if (scannedAnswers[i] == -2) sel = 'Multi';

        String cor = 'N/A';
        if (correctQ.correctChoice >= 0)
          cor = String.fromCharCode(65 + correctQ.correctChoice);

        final isCorrect = (scannedAnswers[i] == correctQ.correctChoice) &&
            (scannedAnswers[i] >= 0);
        if (correctQ.id != null && correctQ.id != -1) {
          totalMaxMark += correctQ.mark;
          if (isCorrect) studentMark += correctQ.mark;
        }
        answerData.add({
          'question': qNum,
          'selected': sel,
          'correct': cor,
          'isCorrect': isCorrect,
          'mark': correctQ.mark,
        });
      }

      final scorePercent =
          totalMaxMark > 0 ? (studentMark / totalMaxMark * 100).round() : 0;

      final auth = Provider.of<AuthProvider>(context, listen: false);
      final student = await db.getStudentByStudentId(studentIdStr, auth.userId);
      final studentName = student?.name ?? 'Unknown ($studentIdStr)';

      await db.insertResult(Result(
        examId: widget.exam.id!,
        studentId: studentIdStr,
        studentName: studentName,
        score: scorePercent,
        answers: jsonEncode(answerData),
        date: DateTime.now().toIso8601String(),
        userId: auth.userId,
      ));

      if (mounted) {
        Provider.of<SyncProvider>(context, listen: false).autoSync(auth.userId);
      }

      try {
        await _audioPlayer.play(AssetSource('sounds/beep.wav'));
      } catch (_) {}
      _flashController.forward(from: 0.0);

      _lastScannedId = studentIdStr;
      _pendingId = null;
      _confirmCount = 0;

      if (mounted) {
        setState(() {
          _scannedCount++;
          _sessionResults.insert(0, {
            'studentName': studentName,
            'studentId': studentIdStr,
            'score': scorePercent,
            'totalMark': totalMaxMark,
            'studentMark': studentMark,
          });
          _statusText =
              '✅ $studentName — $studentMark/$totalMaxMark   (remove paper)';
        });
      }

      // Reset cooldown after 3s
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted)
          setState(() {
            _lastScannedId = null;
            _statusText = 'Place next paper under camera';
          });
      });
    } catch (_) {
      _pendingId = null;
      _confirmCount = 0;
      if (mounted)
        setState(() {
          _isProcessing = false;
          _statusText = 'Place paper under camera';
        });
    }

    try {
      await File(photo.path).delete();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Full-screen camera preview ──
          if (_isCameraReady && _cameraController != null)
            Positioned.fill(
              child: GestureDetector(
                onTapDown: _onTapFocus,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1 / _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),
            )
          else
            const Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Initializing camera...',
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            ),

          // ── Focus ring ──
          if (_focusPoint != null)
            Positioned(
              left: _focusPoint!.dx - 35,
              top: _focusPoint!.dy - 35,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber, width: 2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.center_focus_strong,
                      color: Colors.amber, size: 20),
                ),
              ),
            ),

          // ── Top bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Live Scan',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Text(widget.exam.title,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off,
                          color: _isTorchOn ? Colors.amber : Colors.white),
                      onPressed: () async {
                        setState(() => _isTorchOn = !_isTorchOn);
                        try {
                          await _cameraController?.setFlashMode(
                              _isTorchOn ? FlashMode.torch : FlashMode.off);
                        } catch (_) {}
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            _scannedCount > 0 ? Colors.green : Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_scannedCount ✓',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Corner alignment guide ──
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.65,
              child: CustomPaint(
                painter: _CornerPainter(
                  color: _lastScannedId != null ? Colors.green : Colors.white,
                ),
              ),
            ),
          ),

          // ── Bottom status / result ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _statusText,
                        key: ValueKey(_statusText),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _statusText.startsWith('✅')
                              ? Colors.greenAccent
                              : _statusText.startsWith('🔍')
                                  ? Colors.amberAccent
                                  : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          shadows: const [
                            Shadow(blurRadius: 8, color: Colors.black)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tap screen to focus  •  Flash icon for light',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    // Last result card
                    if (_sessionResults.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (_sessionResults.first['score'] as int) >= 50
                                ? Colors.green.withOpacity(0.5)
                                : Colors.red.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  (_sessionResults.first['score'] as int) >= 50
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                              child: Text(
                                '${_sessionResults.first['studentMark']}/${_sessionResults.first['totalMark']}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      (_sessionResults.first['score'] as int) >=
                                              50
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _sessionResults.first['studentName']
                                        as String,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'ID: ${_sessionResults.first['studentId']}  •  '
                                    '${_sessionResults.first['studentMark']}/${_sessionResults.first['totalMark']} marks',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Processing spinner ──
          if (_isProcessing)
            Positioned(
              top: 90,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('Processing...',
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),

          // ── Green flash on success ──
          IgnorePointer(
            child: FadeTransition(
              opacity: _flashAnimation.drive(Tween(begin: 0.0, end: 0.5)
                  .chain(CurveTween(curve: Curves.easeOut))),
              child: Container(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.85)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 40.0;
    final w = size.width;
    final h = size.height;

    canvas.drawLine(const Offset(0, len), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(len, 0), paint);
    canvas.drawLine(Offset(w - len, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, len), paint);
    canvas.drawLine(Offset(0, h - len), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(len, h), paint);
    canvas.drawLine(Offset(w - len, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - len), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}
