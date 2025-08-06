import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'dart:math' as math;
import 'package:fish_fresh_test/config/detection_config.dart';

class DetectionResult {
  final List<double> boundingBox; // [x1, y1, x2, y2]
  final double confidence;
  final int classId;
  final String className;

  DetectionResult({
    required this.boundingBox,
    required this.confidence,
    required this.classId,
    required this.className,
  });

  // Helper untuk menghitung area bounding box
  double get area {
    return (boundingBox[2] - boundingBox[0]) *
        (boundingBox[3] - boundingBox[1]);
  }

  // Helper untuk menghitung IoU (Intersection over Union)
  double calculateIoU(DetectionResult other) {
    final x1 = math.max(boundingBox[0], other.boundingBox[0]);
    final y1 = math.max(boundingBox[1], other.boundingBox[1]);
    final x2 = math.min(boundingBox[2], other.boundingBox[2]);
    final y2 = math.min(boundingBox[3], other.boundingBox[3]);

    if (x2 <= x1 || y2 <= y1) return 0.0;

    final intersection = (x2 - x1) * (y2 - y1);
    final union = area + other.area - intersection;

    return intersection / union;
  }
}

class FishSummary {
  final String fishType;
  final String freshnessLevel;
  final int count;
  final double averageConfidence;
  final List<DetectionResult> detections;

  FishSummary({
    required this.fishType,
    required this.freshnessLevel,
    required this.count,
    required this.averageConfidence,
    required this.detections,
  });
}

class BasicFishDetectionService {
  static const int inputSize = 640;
  // Ambil threshold dan parameter dari DetectionConfig
  static double get bandengDetectionThreshold =>
      DetectionConfig.bandengDetectionThreshold;
  static double get freshnessClassificationThreshold =>
      DetectionConfig.freshnessClassificationThreshold;
  static double get nmsThreshold => DetectionConfig.nmsThreshold;
  static int get maxDetections => DetectionConfig.maxDetections;
  static bool get showOnlyTopDetection => DetectionConfig.showOnlyTopDetection;
  static bool get enableNMS => DetectionConfig.enableNMS;

  static const List<String> classNames = [
    'ikan_bandeng',
    'kurang_segar',
    'segar',
    'tidak_segar'
  ];

  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  // Load TensorFlow Lite model
  Future<bool> loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset('assets/models/best_float32.tflite');
      _isModelLoaded = true;

      print('Model loaded successfully');
      print('Input tensors: ${_interpreter!.getInputTensors().length}');
      print('Output tensors: ${_interpreter!.getOutputTensors().length}');

      if (_interpreter!.getInputTensors().isNotEmpty) {
        print('Input shape: ${_interpreter!.getInputTensors().first.shape}');
      }
      if (_interpreter!.getOutputTensors().isNotEmpty) {
        print('Output shape: ${_interpreter!.getOutputTensors().first.shape}');
      }

      return true;
    } catch (e) {
      print('Error loading model: $e');
      print('Make sure best_float32.tflite is in assets/models/ folder');
      return false;
    }
  }

  // Preprocess gambar untuk input model
  Float32List preprocessImage(img.Image image) {
    // Resize gambar ke input size (640x640)
    img.Image resizedImage = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
    );

    // Convert ke Float32List dengan normalisasi [0,1]
    Float32List inputBytes = Float32List(1 * inputSize * inputSize * 3);
    int pixelIndex = 0;

    // Format: [batch, height, width, channels] = [1, 640, 640, 3]
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        img.Pixel pixel = resizedImage.getPixel(x, y);

        // Normalize ke [0,1] dalam urutan RGB
        inputBytes[pixelIndex++] = pixel.r / 255.0;
        inputBytes[pixelIndex++] = pixel.g / 255.0;
        inputBytes[pixelIndex++] = pixel.b / 255.0;
      }
    }

    print('Preprocessed image: ${inputBytes.length} values');
    print('Sample values: ${inputBytes.take(10).toList()}');
    return inputBytes;
  }

  // Fungsi utama untuk deteksi
  Future<List<DetectionResult>> detectFish(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      throw Exception(
          'Model not loaded. Please ensure best_float32.tflite is in assets/models/');
    }

    try {
      // Load dan decode gambar
      Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      print('Performing real TensorFlow Lite inference...');
      return await performRealInference(image);
    } catch (e) {
      print('Error during detection: $e');
      throw Exception('Detection failed: $e');
    }
  }

  // Inference sesungguhnya menggunakan model
  Future<List<DetectionResult>> performRealInference(img.Image image) async {
    try {
      // Preprocess gambar
      Float32List inputTensor = preprocessImage(image);

      // Reshape input ke format [1, 640, 640, 3]
      var reshapedInput = inputTensor.reshape([1, inputSize, inputSize, 3]);

      // Prepare output tensor - sesuaikan dengan model output shape
      // Untuk YOLOv8: output shape biasanya [1, 8, 8400] atau [1, 8400, 8]
      var outputTensor = List.filled(1 * 8 * 8400, 0.0).reshape([1, 8, 8400]);

      print('Running TensorFlow Lite inference...');
      print('Input shape: [1, $inputSize, $inputSize, 3]');

      // Run inference
      _interpreter!.run(reshapedInput, outputTensor);

      print('Inference completed. Processing output...');

      // Post-process hasil
      List<DetectionResult> rawResults =
          _postprocessYoloOutput(outputTensor.cast<List<List<double>>>());

      // Apply NMS dan filtering
      List<DetectionResult> finalResults = _applyNMSAndFiltering(rawResults);

      return finalResults;
    } catch (e) {
      print('Real inference failed: $e');
      throw Exception('TensorFlow Lite inference failed: $e');
    }
  }

  // Post-process output YOLO v8 dengan format [1, 8, 8400]
  List<DetectionResult> _postprocessYoloOutput(
      List<List<List<double>>> output) {
    List<DetectionResult> results = [];

    print(
        'Processing YOLO output: ${output.length} x ${output[0].length} x ${output[0][0].length}');

    // Output format: [1, 8, 8400]
    // Dimana 8 = [x, y, w, h, class1_conf, class2_conf, class3_conf, class4_conf]
    // Dan 8400 = jumlah deteksi

    int numDetections = output[0][0].length; // 8400

    for (int i = 0; i < numDetections; i++) {
      double x = output[0][0][i]; // center x
      double y = output[0][1][i]; // center y
      double w = output[0][2][i]; // width
      double h = output[0][3][i]; // height

      List<double> classScores = [
        output[0][4][i], // ikan_bandeng
        output[0][5][i], // kurang_segar
        output[0][6][i], // segar
        output[0][7][i], // tidak_segar
      ];

      // Debug print untuk beberapa deteksi pertama
      if (i < 5) {
        print('Detection $i: x=$x, y=$y, w=$w, h=$h, scores=$classScores');
      }

      // Convert normalized coordinates ke pixel coordinates
      double x1 = (x - w / 2) * inputSize;
      double y1 = (y - h / 2) * inputSize;
      double x2 = (x + w / 2) * inputSize;
      double y2 = (y + h / 2) * inputSize;

      x1 = x1.clamp(0.0, inputSize.toDouble());
      y1 = y1.clamp(0.0, inputSize.toDouble());
      x2 = x2.clamp(0.0, inputSize.toDouble());
      y2 = y2.clamp(0.0, inputSize.toDouble());

      // 1. Tambahkan deteksi ikan_bandeng jika confidence > bandengDetectionThreshold
      if (classScores[0] > bandengDetectionThreshold) {
        results.add(DetectionResult(
          boundingBox: [x1, y1, x2, y2],
          confidence: classScores[0],
          classId: 0,
          className: classNames[0],
        ));
      }

      // 2. Tambahkan deteksi freshness jika confidence > freshnessClassificationThreshold
      for (int j = 1; j < classScores.length; j++) {
        if (classScores[j] > freshnessClassificationThreshold) {
          results.add(DetectionResult(
            boundingBox: [x1, y1, x2, y2],
            confidence: classScores[j],
            classId: j,
            className: classNames[j],
          ));
        }
      }
    }

    print('Raw detections above threshold: ${results.length}');
    return results;
  }

  // Apply Non-Maximum Suppression dan filtering
  List<DetectionResult> _applyNMSAndFiltering(
      List<DetectionResult> detections) {
    if (detections.isEmpty) return detections;

    // Sort berdasarkan confidence (tertinggi dulu)
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));

    // Jika hanya ingin menampilkan deteksi tertinggi
    if (showOnlyTopDetection && detections.isNotEmpty) {
      print(
          'Showing only top detection: ${detections.first.className} with confidence ${detections.first.confidence.toStringAsFixed(3)}');
      return [detections.first];
    }

    // Class-agnostic NMS seperti sebelumnya
    List<DetectionResult> nmsResults = [];
    List<bool> suppressed = List.filled(detections.length, false);

    for (int i = 0; i < detections.length; i++) {
      if (suppressed[i]) continue;
      List<int> overlapping = [i];
      for (int j = i + 1; j < detections.length; j++) {
        if (suppressed[j]) continue;
        double iou = detections[i].calculateIoU(detections[j]);
        if (iou > nmsThreshold) {
          overlapping.add(j);
        }
      }
      int bestIdx = overlapping[0];
      double bestConf = detections[bestIdx].confidence;
      for (int idx in overlapping) {
        if (detections[idx].confidence > bestConf) {
          bestIdx = idx;
          bestConf = detections[idx].confidence;
        }
      }
      nmsResults.add(detections[bestIdx]);
      for (int idx in overlapping) {
        suppressed[idx] = true;
      }
      // Batasi jumlah deteksi sesuai maxDetections
      if (nmsResults.length >= maxDetections) break;
    }

    // Jangan batasi hasil NMS ke satu deteksi saja, biarkan semua deteksi lolos NMS dikembalikan

    print('Final detections after NMS: ${nmsResults.length}');
    return nmsResults;
  }

  // Fungsi untuk menganalisis dan mengelompokkan hasil deteksi
  List<FishSummary> analyzeFishDetections(List<DetectionResult> detections) {
    // Hanya proses jika ada ikan_bandeng
    if (detections.isEmpty) return [];

    List<FishSummary> summaries = [];
    // Ambil semua deteksi ikan_bandeng
    List<DetectionResult> bandengs =
        detections.where((d) => d.className == 'ikan_bandeng').toList();
    if (bandengs.isEmpty) return [];

    print('=== DEBUG: BANDENG & FRESHNESS MATCHING ===');
    for (var fish in bandengs) {
      print(
          'BANDENG: bbox=${fish.boundingBox.map((v) => v.toStringAsFixed(1)).toList()}, conf=${(fish.confidence * 100).toStringAsFixed(1)}%');
      // Cari freshness yang overlap dengan ikan_bandeng ini
      DetectionResult? bestFreshness;
      double bestIou = 0.0;
      for (var d in detections) {
        if (d.className == 'segar' ||
            d.className == 'kurang_segar' ||
            d.className == 'tidak_segar') {
          double iou = fish.calculateIoU(d);
          // Cek apakah pusat freshness ada di dalam bbox ikan_bandeng
          double cx = (d.boundingBox[0] + d.boundingBox[2]) / 2;
          double cy = (d.boundingBox[1] + d.boundingBox[3]) / 2;
          bool centerInFish = cx >= fish.boundingBox[0] &&
              cx <= fish.boundingBox[2] &&
              cy >= fish.boundingBox[1] &&
              cy <= fish.boundingBox[3];
          print(
              '  Cek freshness: ${d.className} bbox=${d.boundingBox.map((v) => v.toStringAsFixed(1)).toList()}, conf=${(d.confidence * 100).toStringAsFixed(1)}%, IoU=${iou.toStringAsFixed(3)}, centerInFish=$centerInFish');
          if (iou > 0.3 || centerInFish) {
            if (bestFreshness == null ||
                d.confidence > bestFreshness.confidence) {
              bestFreshness = d;
              bestIou = iou;
            }
          }
        }
      }
      if (bestFreshness != null) {
        print(
            '  ==> Dipilih freshness: ${bestFreshness.className} conf=${(bestFreshness.confidence * 100).toStringAsFixed(1)}% IoU=${bestIou.toStringAsFixed(3)}');
      } else {
        print('  ==> Tidak ada freshness yang overlap cukup (IoU > 0.3)');
      }
      String fishType = 'Ikan Bandeng';
      String freshnessLevel = 'Tidak Diketahui';
      double confidence = fish.confidence;
      List<DetectionResult> dets = [fish];
      if (bestFreshness != null) {
        switch (bestFreshness.className) {
          case 'segar':
            freshnessLevel = 'Segar';
            break;
          case 'kurang_segar':
            freshnessLevel = 'Kurang Segar';
            break;
          case 'tidak_segar':
            freshnessLevel = 'Tidak Segar';
            break;
        }
        confidence = bestFreshness.confidence;
        dets.add(bestFreshness);
      }
      summaries.add(FishSummary(
        fishType: fishType,
        freshnessLevel: freshnessLevel,
        count: 1,
        averageConfidence: confidence,
        detections: dets,
      ));
    }
    print('=== END DEBUG ===');
    return summaries;
  }

  // Cleanup
  void dispose() {
    _interpreter?.close();
    _isModelLoaded = false;
  }
}
