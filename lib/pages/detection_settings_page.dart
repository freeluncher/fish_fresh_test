import 'package:flutter/material.dart';
import 'package:fish_fresh_test/config/detection_config.dart';

class DetectionSettingsPage extends StatefulWidget {
  const DetectionSettingsPage({Key? key}) : super(key: key);

  @override
  State<DetectionSettingsPage> createState() => _DetectionSettingsPageState();
}

class _DetectionSettingsPageState extends State<DetectionSettingsPage> {
  double bandengThreshold = DetectionConfig.bandengDetectionThreshold;
  double freshnessThreshold = DetectionConfig.freshnessClassificationThreshold;
  double nms = DetectionConfig.nmsThreshold;
  int maxDet = DetectionConfig.maxDetections;
  bool onlyTop = DetectionConfig.showOnlyTopDetection;

  void _updateBandengThreshold(double value) {
    setState(() {
      bandengThreshold = value;
      DetectionConfig.setBandengDetectionThreshold(value);
    });
  }

  void _updateFreshnessThreshold(double value) {
    setState(() {
      freshnessThreshold = value;
      DetectionConfig.setFreshnessClassificationThreshold(value);
    });
  }

  void _updateNMS(double value) {
    setState(() {
      nms = value;
      DetectionConfig.setNMSThreshold(value);
    });
  }

  void _updateMaxDet(int value) {
    setState(() {
      maxDet = value;
      DetectionConfig.maxDetections = value;
    });
  }

  void _updateOnlyTop(bool value) {
    setState(() {
      onlyTop = value;
      DetectionConfig.setTopDetectionMode(value);
      if (value) {
        maxDet = 1;
      } else {
        maxDet = DetectionConfig.maxDetections;
      }
    });
  }

  void _setPreset(String mode) {
    setState(() {
      switch (mode) {
        case 'High Precision':
          DetectionConfig.setHighPrecisionMode();
          break;
        case 'Balanced':
          DetectionConfig.setBalancedMode();
          break;
        case 'High Sensitivity':
          DetectionConfig.setHighSensitivityMode();
          break;
        case 'Single Detection':
          DetectionConfig.setSingleDetectionMode();
          break;
      }
      bandengThreshold = DetectionConfig.bandengDetectionThreshold;
      freshnessThreshold = DetectionConfig.freshnessClassificationThreshold;
      nms = DetectionConfig.nmsThreshold;
      maxDet = DetectionConfig.maxDetections;
      onlyTop = DetectionConfig.showOnlyTopDetection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Deteksi'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
            tooltip: 'Bantuan Pengaturan',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[50]!,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header info card
              _buildHeaderCard(),
              const SizedBox(height: 20),

              // Detection thresholds section
              _buildThresholdSection(),
              const SizedBox(height: 20),

              // Advanced settings section
              _buildAdvancedSection(),
              const SizedBox(height: 20),

              // Preset modes section
              _buildPresetSection(),
              const SizedBox(height: 20),

              // Current settings preview
              _buildPreviewCard(),

              const SizedBox(height: 100), // Extra space at bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[600]!, Colors.blue[400]!],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengaturan Deteksi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Sesuaikan parameter untuk hasil optimal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.track_changes, color: Colors.orange[600], size: 24),
                const SizedBox(width: 12),
                Text(
                  'Threshold Deteksi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSliderSetting(
              title: 'Deteksi Ikan Bandeng',
              description: 'Kepekaan deteksi keberadaan ikan bandeng',
              value: bandengThreshold,
              min: 0.1,
              max: 0.9,
              divisions: 8,
              onChanged: _updateBandengThreshold,
              icon: Icons.visibility,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildSliderSetting(
              title: 'Klasifikasi Kesegaran',
              description: 'Kepekaan menentukan tingkat kesegaran ikan',
              value: freshnessThreshold,
              min: 0.05,
              max: 0.5,
              divisions: 9,
              onChanged: _updateFreshnessThreshold,
              icon: Icons.grade,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings_applications,
                    color: Colors.purple[600], size: 24),
                const SizedBox(width: 12),
                Text(
                  'Pengaturan Lanjutan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSliderSetting(
              title: 'NMS Threshold',
              description: 'Menghilangkan deteksi yang tumpang tindih',
              value: nms,
              min: 0.1,
              max: 0.9,
              divisions: 8,
              onChanged: _updateNMS,
              icon: Icons.filter_list,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            _buildMaxDetectionSetting(),
            const SizedBox(height: 16),
            _buildSwitchSetting(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required String description,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          _buildSliderLegend(min, max, value, color),
        ],
      ),
    );
  }

  Widget _buildSliderLegend(
      double min, double max, double current, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Min: ${min.toStringAsFixed(1)}',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          Text(
            _getThresholdDescription(current),
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Max: ${max.toStringAsFixed(1)}',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _getThresholdDescription(double value) {
    if (value < 0.3) return 'Sensitif';
    if (value < 0.6) return 'Seimbang';
    return 'Presisi';
  }

  Widget _buildMaxDetectionSetting() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.numbers, color: Colors.indigo, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Maksimal Deteksi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Jumlah maksimal objek yang dapat dideteksi',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: onlyTop ? Colors.grey[300] : Colors.indigo,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: maxDet,
                dropdownColor: Colors.white,
                items: List.generate(15, (i) => i + 1)
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                            v.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: onlyTop ? null : (v) => _updateMaxDet(v!),
                style: TextStyle(
                  color: onlyTop ? Colors.grey[600] : Colors.white,
                  fontSize: 14,
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: onlyTop ? Colors.grey[600] : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.filter_1, color: Colors.teal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mode Deteksi Tunggal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Hanya tampilkan hasil deteksi dengan confidence tertinggi',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: onlyTop,
            onChanged: _updateOnlyTop,
            activeColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.pink[600], size: 24),
                const SizedBox(width: 12),
                Text(
                  'Mode Preset',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih pengaturan yang sudah dioptimasi untuk kebutuhan berbeda',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildPresetCard(
                  'High Precision',
                  'Presisi Tinggi',
                  'Akurasi maksimal, deteksi konservatif',
                  Icons.verified,
                  Colors.green,
                ),
                _buildPresetCard(
                  'Balanced',
                  'Seimbang',
                  'Keseimbangan akurasi dan sensitivitas',
                  Icons.balance,
                  Colors.blue,
                ),
                _buildPresetCard(
                  'High Sensitivity',
                  'Sensitivitas Tinggi',
                  'Deteksi maksimal, mungkin ada false positive',
                  Icons.sensors,
                  Colors.orange,
                ),
                _buildPresetCard(
                  'Single Detection',
                  'Deteksi Tunggal',
                  'Hanya satu hasil terbaik',
                  Icons.looks_one,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetCard(String mode, String title, String description,
      IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _setPreset(mode),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: Colors.indigo[600], size: 24),
                const SizedBox(width: 12),
                Text(
                  'Pengaturan Saat Ini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPreviewItem('Deteksi Bandeng',
                '${(bandengThreshold * 100).toInt()}%', Icons.pets),
            _buildPreviewItem('Klasifikasi Kesegaran',
                '${(freshnessThreshold * 100).toInt()}%', Icons.grade),
            _buildPreviewItem(
                'NMS Threshold', '${(nms * 100).toInt()}%', Icons.filter_list),
            _buildPreviewItem('Max Deteksi', '$maxDet objek', Icons.numbers),
            _buildPreviewItem('Mode Tunggal', onlyTop ? 'Aktif' : 'Nonaktif',
                Icons.toggle_on),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.indigo[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blue),
              SizedBox(width: 12),
              Text('Bantuan Pengaturan'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHelpItem(
                  'Deteksi Bandeng',
                  'Mengatur seberapa yakin sistem sebelum mendeteksi ikan bandeng. Nilai tinggi = lebih presisi, nilai rendah = lebih sensitif.',
                ),
                _buildHelpItem(
                  'Klasifikasi Kesegaran',
                  'Mengatur kepekaan dalam menentukan tingkat kesegaran. Nilai rendah = lebih mudah mengklasifikasi kesegaran.',
                ),
                _buildHelpItem(
                  'NMS Threshold',
                  'Menghilangkan deteksi yang overlapping/tumpang tindih. Nilai tinggi = lebih banyak deteksi dipertahankan.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
