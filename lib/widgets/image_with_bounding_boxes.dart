import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../services/fish_detection_service.dart';

class ImageWithBoundingBoxes extends StatelessWidget {
  final File imageFile;
  final List<DetectionResult> detections;

  const ImageWithBoundingBoxes({
    Key? key,
    required this.imageFile,
    required this.detections,
  }) : super(key: key);

  Color _getClassColor(String className) {
    switch (className.toLowerCase()) {
      case 'segar':
        return Colors.green;
      case 'kurang_segar':
        return Colors.orange;
      case 'tidak_segar':
        return Colors.red;
      case 'ikan_bandeng':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: _loadImage(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final image = snapshot.data!;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Hitung skala untuk fit gambar ke dalam container
            final imageAspectRatio = image.width / image.height;
            final containerAspectRatio =
                constraints.maxWidth / constraints.maxHeight;

            double displayWidth, displayHeight;
            double offsetX = 0, offsetY = 0;

            if (imageAspectRatio > containerAspectRatio) {
              // Gambar lebih lebar, fit berdasarkan width
              displayWidth = constraints.maxWidth;
              displayHeight = displayWidth / imageAspectRatio;
              offsetY = (constraints.maxHeight - displayHeight) / 2;
            } else {
              // Gambar lebih tinggi, fit berdasarkan height
              displayHeight = constraints.maxHeight;
              displayWidth = displayHeight * imageAspectRatio;
              offsetX = (constraints.maxWidth - displayWidth) / 2;
            }

            return Stack(
              children: [
                // Gambar asli
                Positioned(
                  left: offsetX,
                  top: offsetY,
                  child: Image.file(
                    imageFile,
                    width: displayWidth,
                    height: displayHeight,
                    fit: BoxFit.contain,
                  ),
                ),
                // Bounding boxes
                Positioned(
                  left: offsetX,
                  top: offsetY,
                  child: CustomPaint(
                    size: Size(displayWidth, displayHeight),
                    painter: BoundingBoxPainter(
                      detections: detections,
                      imageSize:
                          Size(image.width.toDouble(), image.height.toDouble()),
                      displaySize: Size(displayWidth, displayHeight),
                      getClassColor: _getClassColor,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<ui.Image> _loadImage() async {
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<DetectionResult> detections;
  final Size imageSize;
  final Size displaySize;
  final Color Function(String) getClassColor;

  BoundingBoxPainter({
    required this.detections,
    required this.imageSize,
    required this.displaySize,
    required this.getClassColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Hitung skala dari ukuran model (640x640) ke ukuran gambar asli
    final scaleX = imageSize.width / 640.0;
    final scaleY = imageSize.height / 640.0;

    // Hitung skala dari ukuran gambar asli ke ukuran display
    final displayScaleX = displaySize.width / imageSize.width;
    final displayScaleY = displaySize.height / imageSize.height;

    for (int i = 0; i < detections.length; i++) {
      final detection = detections[i];
      final color = getClassColor(detection.className);

      // Konversi koordinat dari model space (640x640) ke image space lalu ke display space
      final x1 = detection.boundingBox[0] * scaleX * displayScaleX;
      final y1 = detection.boundingBox[1] * scaleY * displayScaleY;
      final x2 = detection.boundingBox[2] * scaleX * displayScaleX;
      final y2 = detection.boundingBox[3] * scaleY * displayScaleY;

      final rect = Rect.fromLTRB(x1, y1, x2, y2);

      // Gambar bounding box
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawRect(rect, paint);

      // Gambar background untuk label
      final labelText =
          '${detection.className.replaceAll('_', ' ')} ${(detection.confidence * 100).toStringAsFixed(1)}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Background untuk text
      final labelRect = Rect.fromLTWH(
        x1,
        y1 - textPainter.height - 8,
        textPainter.width + 16,
        textPainter.height + 8,
      );

      final labelPaint = Paint()..color = color;
      canvas.drawRect(labelRect, labelPaint);

      // Gambar text
      textPainter.paint(canvas, Offset(x1 + 8, y1 - textPainter.height - 4));

      // Gambar nomor detection di pojok kanan atas bounding box
      final numberText = '${i + 1}';
      final numberPainter = TextPainter(
        text: TextSpan(
          text: numberText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      numberPainter.layout();

      final numberSize = 24.0;
      final numberRect = Rect.fromLTWH(
        x2 - numberSize,
        y1,
        numberSize,
        numberSize,
      );

      final numberBgPaint = Paint()..color = color;
      canvas.drawOval(numberRect, numberBgPaint);

      numberPainter.paint(
        canvas,
        Offset(
          x2 - numberSize / 2 - numberPainter.width / 2,
          y1 + numberSize / 2 - numberPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
