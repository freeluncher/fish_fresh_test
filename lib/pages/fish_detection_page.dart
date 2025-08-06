import 'history_page.dart';
import 'detection_settings_page.dart';
import 'app_info_page.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/fish_detection_service.dart';
import '../config/app_theme.dart';

import '../widgets/image_with_bounding_boxes.dart';
import '../widgets/fish_summary_widget.dart';

import 'package:hive_flutter/hive_flutter.dart';
import '../models/detection_history.dart';

class FishDetectionPage extends StatefulWidget {
  const FishDetectionPage({Key? key}) : super(key: key);

  @override
  State<FishDetectionPage> createState() => _FishDetectionPageState();
}

class _FishDetectionPageState extends State<FishDetectionPage> {
  // Tampilkan modal loading spinner
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Tutup modal loading spinner jika masih terbuka
  void _hideLoadingDialog() {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  // Copy logic rekomendasi dari fish_summary_widget agar history konsisten
  String _getRecommendation(String freshnessLevel, int count) {
    switch (freshnessLevel.toLowerCase()) {
      case 'segar':
        return count > 1
            ? 'Ikan dalam kondisi segar dan layak konsumsi. Total: $count ekor'
            : 'Ikan dalam kondisi segar dan layak konsumsi';
      case 'kurang segar':
        return count > 1
            ? 'Ikan kurang segar, segera dimasak atau diproses. Total: $count ekor'
            : 'Ikan kurang segar, segera dimasak atau diproses';
      case 'tidak segar':
        return count > 1
            ? 'Ikan tidak segar, tidak disarankan untuk dikonsumsi. Total: $count ekor'
            : 'Ikan tidak segar, tidak disarankan untuk dikonsumsi';
      case 'tidak diketahui':
        return count > 1
            ? 'Ikan bandeng terdeteksi, namun tingkat kesegaran belum dapat ditentukan. Total: $count ekor'
            : 'Ikan bandeng terdeteksi, namun tingkat kesegaran belum dapat ditentukan';
      default:
        return 'Status tidak diketahui';
    }
  }

  String _getProcessingSuggestion(String freshnessLevel) {
    switch (freshnessLevel.toLowerCase()) {
      case 'segar':
        return 'Saran pengolahan: Cocok untuk dimasak menjadi sup, bakar, goreng, pepes, atau sashimi.';
      case 'kurang segar':
        return 'Saran pengolahan: Sebaiknya dimasak matang seperti digoreng, dibakar, atau dibuat pindang.';
      case 'tidak segar':
        return 'Saran pengolahan: Tidak disarankan dikonsumsi. Jika terpaksa, pastikan dimasak sangat matang dan buang bagian yang mencurigakan.';
      case 'tidak diketahui':
        return 'Saran pengolahan: Pastikan kondisi ikan sebelum diolah. Jika ragu, masak hingga benar-benar matang.';
      default:
        return '';
    }
  }

  String _getStorageSuggestion(String freshnessLevel) {
    switch (freshnessLevel.toLowerCase()) {
      case 'segar':
        return 'Saran penyimpanan: Simpan di kulkas (4°C) maksimal 2-3 hari, atau bekukan di freezer untuk penyimpanan jangka panjang (3-6 bulan).';
      case 'kurang segar':
        return 'Saran penyimpanan: Segera masak dalam 24 jam atau bekukan setelah dibersihkan. Hindari penyimpanan di suhu ruang.';
      case 'tidak segar':
        return 'Saran penyimpanan: Tidak disarankan disimpan. Jika terpaksa, bekukan segera setelah pembersihan menyeluruh maksimal 1 bulan.';
      case 'tidak diketahui':
        return 'Saran penyimpanan: Simpan di kulkas maksimal 1-2 hari sambil memantau kondisi ikan, atau bekukan untuk keamanan.';
      default:
        return '';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  final BasicFishDetectionService _detectionService =
      BasicFishDetectionService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  List<DetectionResult> _detections = [];
  List<FishSummary> _fishSummaries = [];
  bool _isLoading = false;
  bool _isModelLoaded = false;
  String _statusMessage = 'Memuat model...';

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Memuat TensorFlow Lite model...';
    });

    bool success = await _detectionService.loadModel();

    setState(() {
      _isLoading = false;
      _isModelLoaded = success;
      _statusMessage = success
          ? 'Model berhasil dimuat. Siap untuk deteksi!'
          : 'Gagal memuat model. Periksa apakah best_float32.tflite ada di assets/models/';
    });

    if (!success) {
      _showErrorSnackBar(
          'Gagal memuat model. Gunakan model TensorFlow Lite yang valid untuk deteksi yang akurat.');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Kesalahan mengakses kamera: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Kesalahan mengakses galeri: $e');
    }
  }

  Future<void> _saveDetectionToHistory(String imagePath, String summary) async {
    final box = Hive.box<DetectionHistory>('history');
    await box.add(DetectionHistory(
      imagePath: imagePath,
      detectedAt: DateTime.now(),
      summary: summary,
    ));
  }

  Future<void> _processImage(File imageFile) async {
    if (!_isModelLoaded) {
      _showErrorSnackBar('Model tidak dimuat. Tidak dapat melakukan deteksi.');
      return;
    }

    setState(() {
      _selectedImage = imageFile;
      _isLoading = true;
      _statusMessage = 'Menjalankan inferensi TensorFlow Lite...';
      _detections.clear();
      _fishSummaries.clear();
    });
    // Tampilkan modal loading spinner
    _showLoadingDialog();

    try {
      final stopwatch = Stopwatch()..start();
      List<DetectionResult> results =
          await _detectionService.detectFish(imageFile);
      stopwatch.stop();
      final detectionTimeMs = stopwatch.elapsedMilliseconds;

      // Analyze and group detections
      List<FishSummary> summaries =
          _detectionService.analyzeFishDetections(results);

      setState(() {
        _detections = results;
        _fishSummaries = summaries;
        _isLoading = false;
        _statusMessage = results.isEmpty
            ? 'Tidak ada objek yang terdeteksi di atas ambang batas deteksi bandeng (${(BasicFishDetectionService.bandengDetectionThreshold * 100).toStringAsFixed(1)}%)\n(Waktu deteksi: ${detectionTimeMs} ms)'
            : '${results.length} deteksi ditemukan dengan ${summaries.length} grup ikan\n(Waktu deteksi: ${detectionTimeMs} ms)';
      });
      // Tutup modal loading spinner
      _hideLoadingDialog();

      // Simpan ke history jika ada deteksi
      if (results.isNotEmpty) {
        String summaryText;
        if (summaries.isNotEmpty) {
          summaryText = summaries.map((s) {
            final recommendation =
                _getRecommendation(s.freshnessLevel, s.count);
            final suggestion = _getProcessingSuggestion(s.freshnessLevel);
            final storageSuggestion = _getStorageSuggestion(s.freshnessLevel);
            return '${s.fishType} - ${s.freshnessLevel} (${s.count} ekor, avg: ${(s.averageConfidence * 100).toStringAsFixed(1)}%)\n- $recommendation\n- $suggestion\n- $storageSuggestion';
          }).join('\n\n');
        } else {
          summaryText = 'tidak ada ringkasan ikan yang ditemukan';
        }
        await _saveDetectionToHistory(imageFile.path, summaryText);
      }

      // Debug print
      print('\n=== DETECTION RESULTS ===');
      for (var detection in results) {
        print(
            'Detected: ${detection.className} with ${(detection.confidence * 100).toStringAsFixed(1)}% confidence');
      }

      print('\n=== FISH SUMMARIES ===');
      for (var summary in summaries) {
        print(
            'Fish: ${summary.fishType} - ${summary.freshnessLevel} (${summary.count} ekor, avg confidence: ${(summary.averageConfidence * 100).toStringAsFixed(1)}%)');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Detection failed: $e';
      });
      // Tutup modal loading spinner jika error
      _hideLoadingDialog();
    }
  }

  Color _getClassColor(String className) {
    switch (className.toLowerCase()) {
      case 'segar':
        return AppTheme.freshGreen;
      case 'kurang_segar':
        return AppTheme.warningOrange;
      case 'tidak_segar':
        return AppTheme.dangerRed;
      case 'ikan_bandeng':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.textLight;
    }
  }

  // --- Widget builders moved above build() for correct order ---

  // --- Widget builders moved above build() for correct order ---
  Widget _buildWelcomeWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.crystallWater,
              shape: BoxShape.circle,
              boxShadow: AppTheme.softShadow,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/icon-launcher.png',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Deteksi Kesegaran Ikan Bandeng',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ambil foto atau pilih dari galeri\nuntuk mendeteksi ikan dan menganalisis kesegaran',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textLight,
                ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: AppTheme.cleanGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.seaFoam),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 24),
                const SizedBox(height: 8),
                Text(
                  'Fitur Utama',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Penyaringan deteksi cerdas\n'
                  '• Penanganan beberapa ikan\n'
                  '• Analisis kesegaran\n'
                  '• Visualisasi deteksi',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textDark,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AppInfoPage()),
                    );
                  },
                  icon: const Icon(Icons.help_outline, size: 18),
                  label: const Text('Cara Penggunaan & Info'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Move _buildDetailedResults above _buildImageWithDetections for correct order
  Widget _buildDetailedResults() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(Icons.list_alt, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Raw Detection Results (${_detections.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
        children: _detections.asMap().entries.map((entry) {
          int index = entry.key;
          DetectionResult detection = entry.value;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getClassColor(detection.className).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getClassColor(detection.className).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getClassColor(detection.className),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        detection.className.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Confidence: ${(detection.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Bbox: [${detection.boundingBox.map((e) => e.toStringAsFixed(0)).join(', ')}]',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImageWithDetections() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Image dengan bounding boxes
          Container(
            margin: const EdgeInsets.all(16),
            height: 400, // Set tinggi tetap untuk gambar
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Processing image...\nApplying NMS and filtering',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ImageWithBoundingBoxes(
                      imageFile: _selectedImage!,
                      detections: _detections,
                    ),
            ),
          ),

          // Fish analysis summary
          FishDetectionSummary(
            summaries: _fishSummaries,
            allDetections: _detections,
          ),

          // Detailed detection results (jika diperlukan)
          if (_detections.isNotEmpty) _buildDetailedResults(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FishFresh'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Detection Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const DetectionSettingsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Info Aplikasi',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AppInfoPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isModelLoaded
                  ? AppTheme.lightFreshGreen
                  : AppTheme.lightWarningOrange,
              border: Border(
                bottom: BorderSide(
                  color: _isModelLoaded
                      ? AppTheme.freshGreen
                      : AppTheme.warningOrange,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isModelLoaded ? Icons.check_circle : Icons.warning,
                  color: _isModelLoaded
                      ? AppTheme.freshGreen
                      : AppTheme.warningOrange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _isModelLoaded
                              ? AppTheme.freshGreen
                              : AppTheme.warningOrange,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Image display
          Expanded(
            child: _selectedImage == null
                ? _buildWelcomeWidget()
                : _buildImageWithDetections(),
          ),

          // Control buttons
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 3,
                      shadowColor: AppTheme.primaryBlue.withOpacity(0.3),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.freshMint,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 3,
                      shadowColor: AppTheme.freshMint.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _detectionService.dispose();
    super.dispose();
  }
}
