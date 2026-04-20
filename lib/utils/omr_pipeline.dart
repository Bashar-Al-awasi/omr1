import 'package:opencv_dart/opencv_dart.dart';

class OMRScanner {
  final int questions = 5;
  final int choices = 5;
  final List<int> answers = [1, 2, 0, 2, 4];
  final int widthImg = 700;
  final int heightImg = 700;

  /// **** Equivalent of splitBoxes in Python ***
  List<Mat> splitBoxes(Mat image) {
    List<Mat> boxes = [];
    int boxHeight = (image.rows / questions).floor();
    int boxWidth = (image.cols / choices).floor();
    for (int r = 0; r < questions; r++) {
      for (int c = 0; c < choices; c++) {
        int startY = r * boxHeight;
        int startX = c * boxWidth;
        int endY = (r == questions - 1) ? image.rows : (startY + boxHeight);
        int endX = (c == choices - 1) ? image.cols : (startX + boxWidth);
        int w = endX - startX;
        int h = endY - startY;
        double cx = startX + w / 2.0;
        double cy = startY + h / 2.0;
        final box = getRectSubPix(image, (w, h), Point2f(cx, cy));
        boxes.add(box);
      }
    }
    return boxes;
  }

  /// Count non-zero pixels like cv2.countNonZero
  int countNonZeroBox(Mat image) {
    // Use a robust center square crop instead of unavailable bitwise_and/circle
    int w = image.cols;
    int h = image.rows;
    int cropSize = ((w < h ? w : h) * 0.6).toInt();
    double cx = w / 2.0;
    double cy = h / 2.0;
    // Use getRectSubPix to extract a center square region
    final centerBox =
        getRectSubPix(image, (cropSize, cropSize), Point2f(cx, cy));
    return countNonZero(centerBox);
  }

  VecPoint reorder(VecPoint points) {
    if (points.length != 4) return points;
    List<Point> pts = points.toList();

    List<int> sums = pts.map((p) => p.x + p.y).toList();
    List<int> diffs = pts.map((p) => p.y - p.x).toList();

    int tl_idx = 0;
    int minSum = sums[0];
    int br_idx = 0;
    int maxSum = sums[0];
    int tr_idx = 0;
    int minDiff = diffs[0];
    int bl_idx = 0;
    int maxDiff = diffs[0];

    for (int i = 1; i < 4; i++) {
      if (sums[i] < minSum) {
        tl_idx = i;
        minSum = sums[i];
      }
      if (sums[i] > maxSum) {
        br_idx = i;
        maxSum = sums[i];
      }
      if (diffs[i] < minDiff) {
        tr_idx = i;
        minDiff = diffs[i];
      }
      if (diffs[i] > maxDiff) {
        bl_idx = i;
        maxDiff = diffs[i];
      }
    }

    return VecPoint.fromList([
      pts[tl_idx],
      pts[tr_idx],
      pts[br_idx],
      pts[bl_idx],
    ]);
  }

  List<VecPoint> rectContour(VecVecPoint contours) {
    List<VecPoint> rectCon = [];
    for (var i = 0; i < contours.length; i++) {
      final cont = contours[i];
      final area = contourArea(cont);
      if (area > 1000) {
        final peri = arcLength(cont, true);
        final approx = approxPolyDP(cont, 0.02 * peri, true);
        if (approx.length == 4) {
          rectCon.add(approx);
        }
      }
    }
    rectCon.sort((a, b) => contourArea(b).compareTo(contourArea(a)));
    return rectCon;
  }

  /// Crop the document using 4 Page markers
  List<int> clusterCoordinates(List<int> vals,
      {int dist = 15, int minBubbles = 3}) {
    if (vals.isEmpty) return [];
    vals.sort();
    List<List<int>> groups = [];
    for (int v in vals) {
      if (groups.isEmpty || (v - groups.last.last) > dist) {
        groups.add([v]);
      } else {
        groups.last.add(v);
      }
    }
    // Filter for "Significant Clusters" (clusters that have enough bubbles to be a real line)
    List<List<int>> significant =
        groups.where((g) => g.length >= minBubbles).toList();

    // Fallback: If no significant clusters found, return all groups to avoid total failure
    if (significant.isEmpty) significant = groups;

    return significant.map((g) {
      int sum = g.reduce((a, b) => a + b);
      return (sum / g.length).round();
    }).toList()
      ..sort();
  }

  /// Process image and extract both ID and answers dynamically
  Map<String, dynamic> processImage(String imagePath) {
    // 1. Load and preprocess image
    final rawImg = imread(imagePath);
    // Scale image proportionally for robust feature detection
    double scale = 1500.0 / rawImg.rows;
    int newWidth = (rawImg.cols * scale).toInt();
    final img = resize(rawImg, (newWidth, 1500));
    final imgGray = cvtColor(img, 6); // 6 = COLOR_BGR2GRAY
    final imgBlur = gaussianBlur(imgGray, (5, 5), 1);
    final imgThresh = adaptiveThreshold(imgBlur, 255, 0, 1, 11, 2);

    // Apply morphological closing to heal shadows/glare on the frame lines
    final kernel = getStructuringElement(0, (5, 5));
    final imgClosed = morphologyEx(imgThresh, 3, kernel);

    // 2. Locate the ID and Answer Framing boxes
    final contoursTuple = findContours(imgClosed, 3, 2);
    final contours = contoursTuple.$1;

    List<Map<String, dynamic>> distFrames = [];
    for (var cont in contours) {
      final area = contourArea(cont);
      if (area > 15000) {
        final peri = arcLength(cont, true);
        final approx = approxPolyDP(cont, 0.02 * peri, true);
        if (approx.length == 4) {
          final rect = boundingRect(approx);
          bool overlap = false;
          for (var db in distFrames) {
            if ((rect.x - (db['x'] as int)).abs() < 50 &&
                (rect.y - (db['y'] as int)).abs() < 50) {
              overlap = true;
              if (area > (db['area'] as double)) {
                db['x'] = rect.x;
                db['y'] = rect.y;
                db['w'] = rect.width;
                db['h'] = rect.height;
                db['area'] = area;
                db['cnt'] = approx;
              }
              break;
            }
          }
          if (!overlap) {
            distFrames.add({
              'x': rect.x,
              'y': rect.y,
              'w': rect.width,
              'h': rect.height,
              'area': area,
              'cnt': approx
            });
          }
        }
      }
    }

    if (distFrames.isEmpty)
      throw Exception(
          'No thick framing boxes found on the page at all. Ensure paper is well lit.');

    Map<String, dynamic>? idFrame;
    Map<String, dynamic>? ansFrame;

    for (var f in distFrames) {
      double aspect = f['w'] / f['h'];
      if (aspect > 1.2 && aspect < 4.0) {
        if (ansFrame == null || f['area'] > ansFrame['area']) ansFrame = f;
      } else if (aspect > 0.3 && aspect <= 1.2) {
        if (idFrame == null || f['area'] > idFrame['area']) idFrame = f;
      }
    }

    if (ansFrame == null || idFrame == null) {
      String debug = distFrames.map((f) => '${f['w']}x${f['h']}').join(', ');
      throw Exception('Could not distinguish boxes. Found: $debug');
    }

    // 3. Perspective Warp and Fixed Coordinate Read
    List<int> solveSection(Map<String, dynamic> frame, bool isId) {
      final Size targetSize = isId ? Size(400, 600) : Size(800, 500);
      final VecPoint src = reorder(frame['cnt'] as VecPoint);
      final VecPoint dst = VecPoint.fromList([
        Point(0, 0),
        Point(targetSize.width.toInt(), 0),
        Point(targetSize.width.toInt(), targetSize.height.toInt()),
        Point(0, targetSize.height.toInt()),
      ]);

      final mat = getPerspectiveTransform(src, dst);
      final warpedColor = warpPerspective(
          img, mat, (targetSize.width.toInt(), targetSize.height.toInt()));
      final warpedGray = cvtColor(warpedColor, 6);
      final warpedThreshTuple =
          threshold(warpedGray, 0, 255, 8 + 1); // OTSU + BINARY_INV
      final Mat warpedThresh = warpedThreshTuple.$2;

      // 1. Detect all bubbles in the warped section
      final warpedCntsTuple = findContours(warpedThresh, 3, 2);
      final warpedCnts = warpedCntsTuple.$1;
      List<Point> seeds = [];
      for (var c in warpedCnts) {
        final r = boundingRect(c);
        final a = contourArea(c);
        if (r.width / r.height > 0.6 &&
            r.width / r.height < 1.4 &&
            a > 100 &&
            a < 1500) {
          seeds.add(
              Point((r.x + r.width / 2).toInt(), (r.y + r.height / 2).toInt()));
        }
      }

      // 2. Discover the Grid via significant clusters (Autonomous)
      // ID uses min 5 bubbles per column, Answers uses min 4
      List<int> rowLattice = clusterCoordinates(seeds.map((p) => p.y).toList(),
          minBubbles: isId ? 3 : 4);
      List<int> colLattice = clusterCoordinates(seeds.map((p) => p.x).toList(),
          minBubbles: isId ? 5 : 5);

      // Fallback for ID: If 10 rows not found, use historical defaults for your specific form
      if (isId && rowLattice.length != 10)
        rowLattice = [110, 160, 210, 260, 310, 360, 410, 460, 510, 560];

      List<int> results = [];
      const int bS = 12; // Sampling Box size
      const int minFilledPixels = 150;

      if (isId) {
        for (int cx in colLattice) {
          int det = -1;
          int mVal = 0;
          for (int r = 0; r < rowLattice.length; r++) {
            final b = warpedThresh
                .region(Rect(cx - bS, rowLattice[r] - bS, bS * 2, bS * 2));
            int val = countNonZero(b);
            if (val > mVal && val > minFilledPixels) {
              mVal = val;
              det = r;
            }
          }
          results.add(det);
        }
      } else {
        // ANS: Dynamically group columns into choice blocks using gap analysis
        if (colLattice.length < 2) return [];

        // Find median gap to distinguish choices vs gutters
        List<int> gaps = [];
        for (int i = 0; i < colLattice.length - 1; i++)
          gaps.add(colLattice[i + 1] - colLattice[i]);
        gaps.sort();
        int medianGap = gaps[gaps.length ~/ 2];

        List<List<int>> blocks = [];
        List<int> curr = [colLattice[0]];
        for (int i = 0; i < colLattice.length - 1; i++) {
          if (colLattice[i + 1] - colLattice[i] < medianGap * 1.8) {
            curr.add(colLattice[i + 1]);
          } else {
            blocks.add(curr);
            curr = [colLattice[i + 1]];
          }
        }
        blocks.add(curr);

        // Filter out blocks that represent question numbers (usually small counts)
        final choiceBlocks = blocks.where((b) => b.length >= 2).toList();

        for (var b in choiceBlocks) {
          for (int ry in rowLattice) {
            // Check if this specific row-block intersection actually contains bubbles
            // (Distinguishes between a blank question and a non-existent one)
            bool rowExistsInBlock = seeds.any((s) =>
                (s.y - ry).abs() < 15 &&
                s.x >= b.first - 20 &&
                s.x <= b.last + 20);
            if (!rowExistsInBlock) continue;

            int det = -1;
            int mVal = 0;
            int filledCount = 0;
            for (int c = 0; c < b.length; c++) {
              final box =
                  warpedThresh.region(Rect(b[c] - bS, ry - bS, bS * 2, bS * 2));
              int val = countNonZero(box);
              if (val > minFilledPixels) {
                filledCount++;
                if (val > mVal) {
                  mVal = val;
                  det = c;
                }
              }
            }
            // If more than one choice is shaded, return the "Multi" code (-2)
            results.add(filledCount > 1 ? -2 : det);
          }
        }
      }
      return results;
    }

    final idDigitsResult = solveSection(idFrame, true);
    final answers = solveSection(ansFrame, false);

    return {
      'id': idDigitsResult,
      'answers': answers,
    };
  }
}
