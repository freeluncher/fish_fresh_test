import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/app_theme.dart';

class AppInfoPage extends StatefulWidget {
  const AppInfoPage({Key? key}) : super(key: key);

  @override
  State<AppInfoPage> createState() => _AppInfoPageState();
}

class _AppInfoPageState extends State<AppInfoPage> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softGray,
      appBar: AppBar(
        title: const Text('Info Aplikasi'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan logo
            _buildHeaderSection(),
            const SizedBox(height: 24),

            // Informasi aplikasi
            _buildAppInfoSection(),
            const SizedBox(height: 24),

            // Cara penggunaan
            _buildUsageGuideSection(),
            const SizedBox(height: 24),

            // Fitur aplikasi
            _buildFeaturesSection(),
            const SizedBox(height: 24),

            // Tips dan saran
            _buildTipsSection(),
            const SizedBox(height: 24),

            // Tentang pengembang
            _buildDeveloperSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.oceanGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/icon-launcher.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'FishFresh',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aplikasi Deteksi Kesegaran Ikan Bandeng',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (_packageInfo != null)
            Text(
              'Versi ${_packageInfo!.version} (Build ${_packageInfo!.buildNumber})',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white60,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return _buildSectionCard(
      title: 'Tentang Aplikasi',
      icon: Icons.info_outline,
      color: Colors.blue,
      children: [
        _buildInfoRow('Nama', 'FishFresh'),
        _buildInfoRow('Platform', 'Android'),
        _buildInfoRow('Teknologi', 'Flutter + TensorFlow Lite'),
        _buildInfoRow('Model AI', 'YOLOv8s Custom Trained'),
        _buildInfoRow('Ukuran Model', '~42.3 MB'),
        _buildInfoRow('Offline', 'Ya, 100% offline processing'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: const Text(
            'Aplikasi ini menggunakan teknologi AI untuk mendeteksi kesegaran ikan bandeng secara otomatis melalui analisis visual. Semua proses dilakukan secara offline di perangkat Anda.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageGuideSection() {
    return _buildSectionCard(
      title: 'Cara Penggunaan',
      icon: Icons.help_outline,
      color: Colors.green,
      children: [
        _buildStepItem(
          '1',
          'Ambil Foto',
          'Gunakan kamera atau pilih foto dari galeri. Pastikan ikan terlihat jelas dan pencahayaan cukup.',
          Icons.camera_alt,
        ),
        _buildStepItem(
          '2',
          'Proses Deteksi',
          'AI akan menganalisis foto dan mendeteksi ikan bandeng serta tingkat kesegarannya secara otomatis.',
          Icons.psychology,
        ),
        _buildStepItem(
          '3',
          'Lihat Hasil',
          'Dapatkan informasi lengkap tentang kesegaran ikan, rekomendasi pengolahan, dan saran penyimpanan.',
          Icons.assessment,
        ),
        _buildStepItem(
          '4',
          'Simpan Riwayat',
          'Hasil deteksi tersimpan otomatis di halaman riwayat untuk referensi di masa mendatang.',
          Icons.history,
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return _buildSectionCard(
      title: 'Fitur Unggulan',
      icon: Icons.star_outline,
      color: Colors.orange,
      children: [
        _buildFeatureItem(
          'Deteksi Multi-Ikan',
          'Dapat mendeteksi beberapa ikan sekaligus dalam satu foto',
          Icons.scatter_plot,
        ),
        _buildFeatureItem(
          'Analisis Kesegaran',
          'Klasifikasi tingkat kesegaran: Segar, Kurang Segar, Tidak Segar',
          Icons.analytics,
        ),
        _buildFeatureItem(
          'Bounding Box Visual',
          'Visualisasi lokasi ikan yang terdeteksi dengan kotak pembatas',
          Icons.crop_free,
        ),
        _buildFeatureItem(
          'Rekomendasi Cerdas',
          'Saran pengolahan dan penyimpanan berdasarkan tingkat kesegaran',
          Icons.lightbulb_outline,
        ),
        _buildFeatureItem(
          'Riwayat Lengkap',
          'Penyimpanan hasil deteksi dengan detail waktu dan foto',
          Icons.history_edu,
        ),
        _buildFeatureItem(
          'Pengaturan Fleksibel',
          'Atur threshold deteksi dan parameter lainnya sesuai kebutuhan',
          Icons.tune,
        ),
      ],
    );
  }

  Widget _buildTipsSection() {
    return _buildSectionCard(
      title: 'Tips & Saran',
      icon: Icons.tips_and_updates,
      color: Colors.purple,
      children: [
        _buildTipItem(
          'Pencahayaan Optimal',
          'Gunakan pencahayaan yang cukup dan hindari bayangan pada ikan untuk hasil deteksi terbaik.',
          Icons.wb_sunny,
        ),
        _buildTipItem(
          'Posisi Ikan',
          'Posisikan ikan secara horizontal dan pastikan seluruh bagian ikan terlihat dalam frame.',
          Icons.straighten,
        ),
        _buildTipItem(
          'Jarak Foto',
          'Ambil foto dari jarak yang tidak terlalu dekat agar ikan tidak terpotong.',
          Icons.zoom_out,
        ),
        _buildTipItem(
          'Background Kontras',
          'Gunakan background yang kontras dengan warna ikan untuk meningkatkan akurasi deteksi.',
          Icons.contrast,
        ),
        _buildTipItem(
          'Kualitas Gambar',
          'Pastikan foto tidak blur dan memiliki resolusi yang cukup baik.',
          Icons.high_quality,
        ),
      ],
    );
  }

  Widget _buildDeveloperSection() {
    return _buildSectionCard(
      title: 'Informasi Pengembang',
      icon: Icons.code,
      color: Colors.teal,
      children: [
        _buildInfoRow('Dikembangkan oleh', 'M. Wisnu Ainun Najib'),
        _buildInfoRow('Framework', 'Flutter 3.x'),
        _buildInfoRow('AI Engine', 'TensorFlow Lite'),
        _buildInfoRow('Platform Target', 'Android'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.teal[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎯 Tujuan Aplikasi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Membantu masyarakat dalam menilai kesegaran ikan bandeng dengan teknologi AI yang mudah digunakan dan dapat diandalkan.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 12),
              const Text(
                '🔒 Privasi & Keamanan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Semua data dan foto yang Anda gunakan disimpan secara lokal di perangkat Anda. Tidak ada data yang dikirim ke server eksternal.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: AppTheme.crystallWater,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(
      String number, String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.purple[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
