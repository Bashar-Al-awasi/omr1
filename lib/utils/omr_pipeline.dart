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

  List<int> processImage(String imagePath) {

    // 1. Load and preprocess image
    final img = imread(imagePath);
    final imgResized = resize(img, (widthImg, heightImg));
    final imgGray = cvtColor(imgResized, 6); // 6 = COLOR_BGR2GRAY
    final imgBlur = gaussianBlur(imgGray, (5, 5), 1);
    final imgCanny = canny(imgBlur, 10, 70);

    // 2. Find contours
    final contoursTuple = findContours(imgCanny, 0, 2); // 0=RETR_EXTERNAL, 2=CHAIN_APPROX_NONE
    final contours = contoursTuple.$1;
    final rects = rectContour(contours);
    if (rects.length < 1) throw Exception('No rectangle found');
    final biggest = rects[0];
    final points = List.generate(biggest.length, (i) => [biggest[i].x, biggest[i].y]);
    final ordered = reorder(points);

    // 3. Perspective transform
    final srcPoints = VecPoint.fromList(ordered.map((p) => Point(p[0], p[1])).toList());
    final dstPoints = VecPoint.fromList([
      Point(0, 0),
      Point(widthImg, 0),
      Point(0, heightImg),
      Point(widthImg, heightImg),
    ]);
    final matrix = getPerspectiveTransform(srcPoints, dstPoints);
    final imgWarp = warpPerspective(imgResized, matrix, (widthImg, heightImg));

    // 4. Threshold
    final imgWarpGray = cvtColor(imgWarp, 6);
    // Use adaptive thresholding for better robustness
    final imgThresh = adaptiveThreshold(
      imgWarpGray, 255, 0, 1, 11, 2
    ); // 0=ADAPTIVE_THRESH_MEAN_C, 1=THRESH_BINARY_INV

    // 5. Split into boxes
    final boxes = splitBoxes(imgThresh);

    // 6. Analyze boxes
    List<List<int>> myPixelVal = List.generate(questions, (_) => List.filled(choices, 0));
    int row = 0, col = 0;
    for (var box in boxes) {
      myPixelVal[row][col] = countNonZeroBox(box);
      col++;
      if (col == choices) {
        col = 0;
        row++;
      }
    }

    // Print pixel values for each box for debugging
    print('myPixelVal matrix:');
    for (int i = 0; i < myPixelVal.length; i++) {
      print('Q${i + 1}: ' + myPixelVal[i].toString());
    }

    // 7. Find chosen answers (highlighted bubbles only, with improved threshold and relative check)
    List<int> myIndex = [];
    for (int x = 0; x < questions; x++) {
      var arr = myPixelVal[x];
      int maxVal = arr.reduce((a, b) => a > b ? a : b);
      int maxIndex = arr.indexOf(maxVal);
      // Find the second highest value
      List<int> sorted = List.from(arr)..sort((a, b) => b.compareTo(a));
      int secondMax = sorted.length > 1 ? sorted[1] : 0;
      int threshold = 1700; // Adjusted for your blank sheet values
      // Accept only if maxVal is above threshold and at least 20% higher than next highest
      if (maxVal < threshold || (secondMax > 0 && maxVal < secondMax * 1.2)) {
        myIndex.add(-1);
      } else {
        myIndex.add(maxIndex);
      }
    }

    return myIndex;
  }
}