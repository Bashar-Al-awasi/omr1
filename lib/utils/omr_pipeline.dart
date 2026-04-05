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
  final centerBox = getRectSubPix(image, (cropSize, cropSize), Point2f(cx, cy));
  return countNonZero(centerBox);
  }

  List<List<int>> reorder(List<List<int>> points) {
    List<List<int>> newPoints = List.generate(4, (_) => [0, 0]);
    List<int> add = points.map((p) => p[0] + p[1]).toList();
    List<int> diff = points.map((p) => p[1] - p[0]).toList();
    newPoints[0] = points[add.indexOf(add.reduce((a, b) => a < b ? a : b))]; // top-left
    newPoints[3] = points[add.indexOf(add.reduce((a, b) => a > b ? a : b))]; // bottom-right
    newPoints[1] = points[diff.indexOf(diff.reduce((a, b) => a < b ? a : b))]; // top-right
    newPoints[2] = points[diff.indexOf(diff.reduce((a, b) => a > b ? a : b))]; // bottom-left
    return newPoints;
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

  /// Process image and extract both ID and answers, matching the PDF structure
  Map<String, dynamic> processImage(String imagePath, {int idDigits = 6, int numQuestions = 8, int numChoices = 5}) {
    // 1. Load and preprocess image
    final img = imread(imagePath);
    final imgResized = resize(img, (widthImg, heightImg));
    final imgGray = cvtColor(imgResized, 6); // 6 = COLOR_BGR2GRAY
    final imgBlur = gaussianBlur(imgGray, (5, 5), 1);
    final imgThresh = adaptiveThreshold(imgBlur, 255, 0, 1, 11, 2);

    // 2. Find all contours (potential markers)
    final markerContoursTuple = findContours(imgThresh, 0, 2);
    final markerContours = markerContoursTuple.$1;
    // Filter for large black squares (corner markers)
    List<List<int>> markerCenters = [];
    for (var cont in markerContours) {
      final area = contourArea(cont);
      if (area > 80 && area < 400) { // adjust for marker size
        final rect = boundingRect(cont);
        final cx = rect.x + rect.width ~/ 2;
        final cy = rect.y + rect.height ~/ 2;
        markerCenters.add([cx, cy]);
      }
    }
    // Sort markers by y, then x
    markerCenters.sort((a, b) => a[1] == b[1] ? a[0] - b[0] : a[1] - b[1]);
    if (markerCenters.length < 8) throw Exception('Not all inner corner markers found');

    // Assign markers: first 4 are ID section, next 4 are answer section
    final idMarkers = markerCenters.sublist(0, 4);
    final ansMarkers = markerCenters.sublist(4, 8);

    // Order markers: TL, TR, BL, BR
    List<List<int>> orderMarkers(List<List<int>> pts) {
      List<List<int>> ordered = List.generate(4, (_) => [0, 0]);
      List<int> add = pts.map((p) => p[0] + p[1]).toList();
      List<int> diff = pts.map((p) => p[1] - p[0]).toList();
      ordered[0] = pts[add.indexOf(add.reduce((a, b) => a < b ? a : b))]; // TL
      ordered[3] = pts[add.indexOf(add.reduce((a, b) => a > b ? a : b))]; // BR
      ordered[1] = pts[diff.indexOf(diff.reduce((a, b) => a < b ? a : b))]; // TR
      ordered[2] = pts[diff.indexOf(diff.reduce((a, b) => a > b ? a : b))]; // BL
      return ordered;
    }
    final idOrdered = orderMarkers(idMarkers);
    final ansOrdered = orderMarkers(ansMarkers);

    // Perspective transform for ID region
    final idW = ((idOrdered[1][0] - idOrdered[0][0]).abs() + (idOrdered[3][0] - idOrdered[2][0]).abs()) ~/ 2;
    final idH = ((idOrdered[2][1] - idOrdered[0][1]).abs() + (idOrdered[3][1] - idOrdered[1][1]).abs()) ~/ 2;
    final idSrc = VecPoint.fromList([
      Point(idOrdered[0][0], idOrdered[0][1]),
      Point(idOrdered[1][0], idOrdered[1][1]),
      Point(idOrdered[2][0], idOrdered[2][1]),
      Point(idOrdered[3][0], idOrdered[3][1]),
    ]);
    final idDst = VecPoint.fromList([
      Point(0, 0),
      Point(idW, 0),
      Point(0, idH),
      Point(idW, idH),
    ]);
    final idMatrix = getPerspectiveTransform(idSrc, idDst);
    final idRegion = warpPerspective(imgThresh, idMatrix, (idW, idH));

    // Perspective transform for answer region
    final ansW = ((ansOrdered[1][0] - ansOrdered[0][0]).abs() + (ansOrdered[3][0] - ansOrdered[2][0]).abs()) ~/ 2;
    final ansH = ((ansOrdered[2][1] - ansOrdered[0][1]).abs() + (ansOrdered[3][1] - ansOrdered[1][1]).abs()) ~/ 2;
    final ansSrc = VecPoint.fromList([
      Point(ansOrdered[0][0], ansOrdered[0][1]),
      Point(ansOrdered[1][0], ansOrdered[1][1]),
      Point(ansOrdered[2][0], ansOrdered[2][1]),
      Point(ansOrdered[3][0], ansOrdered[3][1]),
    ]);
    final ansDst = VecPoint.fromList([
      Point(0, 0),
      Point(ansW, 0),
      Point(0, ansH),
      Point(ansW, ansH),
    ]);
    final ansMatrix = getPerspectiveTransform(ansSrc, ansDst);
    final ansRegion = warpPerspective(imgThresh, ansMatrix, (ansW, ansH));

    // Split ID region into boxes (10 rows × idDigits columns)
    final idBoxes = <Mat>[];
    int idBoxHeight = (idRegion.rows / 10).floor();
    int idBoxWidth = (idRegion.cols / idDigits).floor();
    for (int r = 0; r < 10; r++) {
      for (int c = 0; c < idDigits; c++) {
        int startY = r * idBoxHeight;
        int startX = c * idBoxWidth;
        int endY = (r == 9) ? idRegion.rows : (startY + idBoxHeight);
        int endX = (c == idDigits - 1) ? idRegion.cols : (startX + idBoxWidth);
        int w = endX - startX;
        int h = endY - startY;
        double cx = startX + w / 2.0;
        double cy = startY + h / 2.0;
        final box = getRectSubPix(idRegion, (w, h), Point2f(cx, cy));
        idBoxes.add(box);
      }
    }
    List<int> idDigitsResult = [];
    for (int d = 0; d < idDigits; d++) {
      int detected = -1;
      int maxVal = 0;
      for (int i = 0; i < 10; i++) {
        final box = idBoxes[i * idDigits + d];
        int val = countNonZeroBox(box);
        if (val > maxVal && val > 100) {
          maxVal = val;
          detected = i;
        }
      }
      idDigitsResult.add(detected);
    }

    // Split answer region into boxes (numQuestions × numChoices)
    final ansBoxes = <Mat>[];
    int ansBoxHeight = (ansRegion.rows / numQuestions).floor();
    int ansBoxWidth = (ansRegion.cols / numChoices).floor();
    for (int r = 0; r < numQuestions; r++) {
      for (int c = 0; c < numChoices; c++) {
        int startY = r * ansBoxHeight;
        int startX = c * ansBoxWidth;
        int endY = (r == numQuestions - 1) ? ansRegion.rows : (startY + ansBoxHeight);
        int endX = (c == numChoices - 1) ? ansRegion.cols : (startX + ansBoxWidth);
        int w = endX - startX;
        int h = endY - startY;
        double cx = startX + w / 2.0;
        double cy = startY + h / 2.0;
        final box = getRectSubPix(ansRegion, (w, h), Point2f(cx, cy));
        ansBoxes.add(box);
      }
    }
    List<int> answers = [];
    for (int q = 0; q < numQuestions; q++) {
      int detected = -1;
      int maxVal = 0;
      for (int c = 0; c < numChoices; c++) {
        final box = ansBoxes[q * numChoices + c];
        int val = countNonZeroBox(box);
        if (val > maxVal && val > 100) {
          maxVal = val;
          detected = c;
        }
      }
      answers.add(detected);
    }

    return {
      'id': idDigitsResult,
      'answers': answers,
    };
  }
}