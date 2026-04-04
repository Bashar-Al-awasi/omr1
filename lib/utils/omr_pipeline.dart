  import 'package:opencv_dart/opencv_dart.dart';

  
  // Helper to crop a region from a Mat (x, y, w, h)
  Mat matCropRect(Mat src, int x, int y, int w, int h) {
    // rowRange is [startRow, endRow), colRange is [startCol, endCol)
    final rowStart = y;
    final rowEnd = y + h;
    final colStart = x;
    final colEnd = x + w;
    return src.rowRange(rowStart, rowEnd).colRange(colStart, colEnd);
  }
  


class OMRScanner {
      /// Extracts ID and answers using fixed regions matching the PDF layout
      /// idDigits: number of ID digits, numQuestions: number of questions, numChoices: number of choices
      Map<String, dynamic> processImageWithLayout(String imagePath, {int idDigits = 5, int numQuestions = 10, int numChoices = 4}) {
        // 1. Load and preprocess image
        final img = imread(imagePath);
        final imgResized = resize(img, (widthImg, heightImg));
        final imgGray = cvtColor(imgResized, 6); // 6 = COLOR_BGR2GRAY
        final imgBlur = gaussianBlur(imgGray, (5, 5), 1);
        final imgCanny = canny(imgBlur, 10, 70);

        // 2. Find contours and warp
        final contoursTuple = findContours(imgCanny, 0, 2);
        final contours = contoursTuple.$1;
        final rects = rectContour(contours);
        if (rects.length < 1) throw Exception('No rectangle found');
        final biggest = rects[0];
        final points = List.generate(biggest.length, (i) => [biggest[i].x, biggest[i].y]);
        final ordered = reorder(points);
        final srcPoints = VecPoint.fromList(ordered.map((p) => Point(p[0], p[1])).toList());
        final dstPoints = VecPoint.fromList([
          Point(0, 0),
          Point(widthImg, 0),
          Point(0, heightImg),
          Point(widthImg, heightImg),
        ]);
        final matrix = getPerspectiveTransform(srcPoints, dstPoints);
        final imgWarp = warpPerspective(imgResized, matrix, (widthImg, heightImg));

        // 3. Threshold
        final imgWarpGray = cvtColor(imgWarp, 6);
        final imgThresh = adaptiveThreshold(imgWarpGray, 255, 0, 1, 11, 2);

        // 4. Define ID region (top area, horizontal row of bubbles)
        // These proportions should match the PDF layout
        final idRegionY = (0.18 * heightImg).toInt(); // ~18% from top
        final idRegionHeight = (0.10 * heightImg).toInt(); // ~10% of height
        final idRegionX = (0.13 * widthImg).toInt(); // ~13% from left
        final idRegionWidth = (0.74 * widthImg).toInt(); // ~74% of width
        final idRegion = matCropRect(imgThresh, idRegionX, idRegionY, idRegionWidth, idRegionHeight);

        // Split ID region into columns (digits)
        List<int> idDigitsResult = [];
        final digitWidth = (idRegionWidth / idDigits).floor();
        final digitHeight = idRegionHeight;
        for (int d = 0; d < idDigits; d++) {
          // Each digit column has 10 bubbles (0-9), vertically
          int colX = d * digitWidth;
          int colY = 0;
          final digitCol = matCropRect(idRegion, colX, colY, digitWidth, digitHeight);
          final bubbleHeight = (digitHeight / 10).floor();
          int detected = -1;
          int maxVal = 0;
          for (int i = 0; i < 10; i++) {
            int bubbleY = i * bubbleHeight;
            final bubble = matCropRect(digitCol, 0, bubbleY, digitWidth, bubbleHeight);
            int val = countNonZeroBox(bubble);
            if (val > maxVal && val > 100) { // threshold
              maxVal = val;
              detected = i;
            }
          }
          idDigitsResult.add(detected);
        }

        // 5. Define answer region (large grid below ID)
        final ansRegionY = (0.35 * heightImg).toInt(); // ~35% from top
        final ansRegionHeight = (0.55 * heightImg).toInt(); // ~55% of height
        final ansRegionX = (0.08 * widthImg).toInt(); // ~8% from left
        final ansRegionWidth = (0.84 * widthImg).toInt(); // ~84% of width
        final ansRegion = matCropRect(imgThresh, ansRegionX, ansRegionY, ansRegionWidth, ansRegionHeight);

        // Split answer region into grid
        final qHeight = (ansRegionHeight / numQuestions).floor();
        final cWidth = (ansRegionWidth / numChoices).floor();
        List<int> answers = [];
        for (int q = 0; q < numQuestions; q++) {
          int rowY = q * qHeight;
          int detected = -1;
          int maxVal = 0;
          for (int c = 0; c < numChoices; c++) {
            int colX = c * cWidth;
            final cell = matCropRect(ansRegion, colX, rowY, cWidth, qHeight);
            int val = countNonZeroBox(cell);
            if (val > maxVal && val > 100) { // threshold
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
    /// Automatically detect number of questions, choices, and extract ID
    /// Returns: { 'answers': List<int>, 'numQuestions': int, 'numChoices': int, 'id': List<int> }
    Map<String, dynamic> processImageAuto(String imagePath) {
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
      final imgThresh = adaptiveThreshold(
        imgWarpGray, 255, 0, 1, 11, 2
      );

      // 5. Attempt to auto-detect answer region grid size
      final answerRegion = imgThresh; // Use the whole image for now
      List<int> rowSums = List.generate(answerRegion.rows, (i) => 0);
      List<int> colSums = List.generate(answerRegion.cols, (i) => 0);
      for (int y = 0; y < answerRegion.rows; y++) {
        for (int x = 0; x < answerRegion.cols; x++) {
          int val = answerRegion.at(y, x);
          rowSums[y] += val > 0 ? 1 : 0;
          colSums[x] += val > 0 ? 1 : 0;
        }
      }
      int minRowGap = 10;
      int minColGap = 10;
      List<int> rowPeaks = [];
      for (int i = 1; i < rowSums.length - 1; i++) {
        if (rowSums[i] > rowSums[i - 1] && rowSums[i] > rowSums[i + 1] && (rowPeaks.isEmpty || i - rowPeaks.last > minRowGap)) {
          rowPeaks.add(i);
        }
      }
      List<int> colPeaks = [];
      for (int i = 1; i < colSums.length - 1; i++) {
        if (colSums[i] > colSums[i - 1] && colSums[i] > colSums[i + 1] && (colPeaks.isEmpty || i - colPeaks.last > minColGap)) {
          colPeaks.add(i);
        }
      }
      int detectedQuestions = rowPeaks.length;
      int detectedChoices = colPeaks.length;
      if (detectedQuestions < 1 || detectedChoices < 1) {
        detectedQuestions = 5;
        detectedChoices = 5;
      }

      // 6. Split into boxes using detected grid
      List<Mat> boxes = [];
      for (int r = 0; r < detectedQuestions; r++) {
        for (int c = 0; c < detectedChoices; c++) {
          int startY = r == 0 ? 0 : rowPeaks[r - 1];
          int endY = rowPeaks[r];
          int startX = c == 0 ? 0 : colPeaks[c - 1];
          int endX = colPeaks[c];
          int w = endX - startX;
          int h = endY - startY;
          double cx = startX + w / 2.0;
          double cy = startY + h / 2.0;
          final box = getRectSubPix(answerRegion, (w, h), Point2f(cx, cy));
          boxes.add(box);
        }
      }

      List<List<int>> myPixelVal = List.generate(detectedQuestions, (_) => List.filled(detectedChoices, 0));
      int row = 0, col = 0;
      for (var box in boxes) {
        myPixelVal[row][col] = countNonZeroBox(box);
        col++;
        if (col == detectedChoices) {
          col = 0;
          row++;
        }
      }

      List<int> myIndex = [];
      for (int x = 0; x < detectedQuestions; x++) {
        var arr = myPixelVal[x];
        int maxVal = arr.reduce((a, b) => a > b ? a : b);
        int maxIndex = arr.indexOf(maxVal);
        List<int> sorted = List.from(arr)..sort((a, b) => b.compareTo(a));
        int secondMax = sorted.length > 1 ? sorted[1] : 0;
        int threshold = 1700;
        if (maxVal < threshold || (secondMax > 0 && maxVal < secondMax * 1.2)) {
          myIndex.add(-1);
        } else {
          myIndex.add(maxIndex);
        }
      }

      // Dummy ID extraction (replace with real logic)
      List<int> idDigits = [1, 2, 3, 4, 5];

      return {
        'answers': myIndex,
        'numQuestions': detectedQuestions,
        'numChoices': detectedChoices,
        'id': idDigits,
      };
    }
  final int questions;
  final int choices;
  final int widthImg;
  final int heightImg;
  OMRScanner({required this.questions, required this.choices, this.widthImg = 700, this.heightImg = 700});

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