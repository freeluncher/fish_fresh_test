import 'package:flutter/material.dart';
import '../services/fish_detection_service.dart';
import '../config/app_theme.dart';

class FishDetectionSummary extends StatelessWidget {
  final List<FishSummary> summaries;
  final List<DetectionResult> allDetections;

  const FishDetectionSummary({
    Key? key,
    required this.summaries,
    required this.allDetections,
  }) : super(key: key);

  Color _getFreshnessColor(String freshnessLevel) {
    return AppTheme.getFreshnessColor(freshnessLevel);
  }

  IconData _getFreshnessIcon(String freshnessLevel) {
    switch (freshnessLevel.toLowerCase()) {
      case 'segar':
        return Icons.check_circle;
      case 'kurang segar':
        return Icons.warning;
      case 'tidak segar':
        return Icons.dangerous;
      case 'tidak diketahui':
        return Icons.help;
      default:
        return Icons.info;
    }
  }

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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: Colors.blue[700]),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    bool isMain = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMain ? color.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMain ? color.withOpacity(0.3) : Colors.grey[300]!,
          width: isMain ? 2 : 1,
        ),
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
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isMain ? 16 : 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[300]!, Colors.grey[200]!],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.search_off,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak Ada Ikan Terdeteksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Pastikan foto menunjukkan ikan bandeng dengan jelas dan pencahayaan yang cukup',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tips_and_updates,
                                color: Colors.blue[600], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Tips untuk foto yang baik:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTip('Gunakan pencahayaan yang cukup'),
                        _buildTip('Fokus pada area mata ikan'),
                        _buildTip('Hindari bayangan atau pantulan'),
                        _buildTip('Pastikan ikan terlihat jelas'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan visual summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[600]!, Colors.blue[400]!],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.analytics_outlined,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Hasil Analisis Deteksi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard(
                      icon: Icons.visibility,
                      label: 'Total Deteksi',
                      value: '${allDetections.length}',
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      icon: Icons.category,
                      label: 'Grup Ikan',
                      value: '${summaries.length}',
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: summaries.map((summary) {
                final color = _getFreshnessColor(summary.freshnessLevel);
                final icon = _getFreshnessIcon(summary.freshnessLevel);
                final recommendation =
                    _getRecommendation(summary.freshnessLevel, summary.count);

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: color.withOpacity(0.3), width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Header dengan visual yang kuat
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    summary.fishType,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    summary.freshnessLevel.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${(summary.averageConfidence * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Akurasi',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Content Section
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kesimpulan utama
                            _buildInfoSection(
                              icon: Icons.assessment,
                              title: 'Kesimpulan',
                              content: recommendation,
                              color: color,
                              isMain: true,
                            ),

                            const SizedBox(height: 16),
                            const Divider(thickness: 1),
                            const SizedBox(height: 16),

                            // Saran dan rekomendasi
                            Text(
                              'Panduan & Saran',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),

                            _buildInfoSection(
                              icon: Icons.restaurant_menu,
                              title: 'Cara Pengolahan',
                              content: _getProcessingSuggestion(
                                      summary.freshnessLevel)
                                  .replaceFirst('Saran pengolahan: ', ''),
                              color: Colors.orange[600]!,
                            ),

                            const SizedBox(height: 12),

                            _buildInfoSection(
                              icon: Icons.kitchen,
                              title: 'Cara Penyimpanan',
                              content:
                                  _getStorageSuggestion(summary.freshnessLevel)
                                      .replaceFirst('Saran penyimpanan: ', ''),
                              color: Colors.blue[600]!,
                            ),
                          ],
                        ),
                      ),

                      // Detail detections jika lebih dari 1
                      if (summary.count > 1) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(thickness: 1),
                        ),
                        Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            childrenPadding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 16),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.list_alt,
                                color: color,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              'Detail Deteksi (${summary.count} objek)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            subtitle: Text(
                              'Tap untuk melihat detail setiap deteksi',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            children:
                                summary.detections.asMap().entries.map((entry) {
                              int index = entry.key;
                              DetectionResult detection = entry.value;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: color,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Akurasi: ${(detection.confidence * 100).toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Posisi: [${detection.boundingBox.map((e) => e.toStringAsFixed(0)).join(', ')}]',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        detection.className,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: color,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
