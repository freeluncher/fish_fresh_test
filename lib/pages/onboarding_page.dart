import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../config/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingPage({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardContent> _pages = [
    _OnboardContent(
      title: 'Selamat Datang di FishFresh',
      subtitle: 'Solusi Cerdas untuk Memilih Ikan Segar',
      description:
          'Aplikasi AI yang membantu Anda mendeteksi kesegaran ikan bandeng secara otomatis hanya dengan foto.',
      features: [
        'Deteksi instan dengan AI',
        'Akurasi tinggi',
        'Mudah digunakan',
      ],
      image: Icons.waves,
      color: AppTheme.primaryBlue,
      backgroundColor: AppTheme.primaryBlue,
    ),
    _OnboardContent(
      title: 'Fitur Unggulan',
      subtitle: 'Teknologi AI untuk Analisis Ikan',
      description:
          'Dapatkan analisis komprehensif tentang ikan bandeng Anda dengan teknologi machine learning terdepan.',
      features: [
        'Deteksi otomatis ikan bandeng',
        'Analisis tingkat kesegaran',
        'Saran pengolahan & penyimpanan',
        'Riwayat deteksi tersimpan',
      ],
      image: Icons.auto_awesome,
      color: AppTheme.freshMint,
      backgroundColor: AppTheme.freshMint,
    ),
    _OnboardContent(
      title: 'Cara Menggunakan',
      subtitle: 'Mudah dalam 3 Langkah',
      description:
          'Proses yang sederhana untuk mendapatkan hasil analisis yang akurat dan terpercaya.',
      features: [
        '📷 Ambil foto ikan atau pilih dari galeri',
        '🤖 AI menganalisis kesegaran secara otomatis',
        '📊 Lihat hasil dan rekomendasi lengkap',
      ],
      image: Icons.psychology,
      color: AppTheme.warningOrange,
      backgroundColor: AppTheme.warningOrange,
    ),
    _OnboardContent(
      title: 'Privasi & Keamanan',
      subtitle: 'Data Anda Aman Bersama Kami',
      description:
          'Komitmen kami untuk menjaga privasi dan keamanan data Anda dengan standar terbaik.',
      features: [
        '🔒 Data hanya tersimpan di perangkat Anda',
        '🚫 Tidak ada pengiriman data ke server',
        '✅ Proses deteksi offline 100%',
        '🛡️ Privasi terjamin sepenuhnya',
      ],
      image: Icons.security,
      color: AppTheme.oceanDeep,
      backgroundColor: AppTheme.oceanDeep,
    ),
  ];

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationPage()),
      (route) => false,
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
      String text, bool isPrimary, VoidCallback onPressed) {
    return Container(
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.white : Colors.transparent,
          foregroundColor:
              isPrimary ? _pages[_currentPage].color : Colors.white,
          elevation: isPrimary ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: Colors.white, width: 2),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background dengan gradient berdasarkan page saat ini
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _pages[_currentPage].backgroundColor,
                  _pages[_currentPage].backgroundColor.withOpacity(0.8),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FishFresh',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_currentPage < _pages.length - 1)
                        TextButton(
                          onPressed: _finishOnboarding,
                          child: const Text(
                            'Lewati',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Main content
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, i) {
                      final page = _pages[i];
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),

                            // Icon dengan animated container
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: i == 0
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.asset(
                                        'assets/icon-launcher.png',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : Icon(
                                      page.image,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                            ),

                            const SizedBox(height: 30),

                            // Title
                            Text(
                              page.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),

                            // Subtitle
                            Text(
                              page.subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 20),

                            // Description
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                page.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Features list
                            ...page.features
                                .map((feature) => _buildFeatureItem(feature))
                                .toList(),

                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Page indicators
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: _buildNavigationButton(
                            'Kembali',
                            false,
                            () {
                              _controller.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 16),
                      Expanded(
                        child: _buildNavigationButton(
                          _currentPage == _pages.length - 1
                              ? 'Mulai Sekarang'
                              : 'Lanjut',
                          true,
                          _currentPage == _pages.length - 1
                              ? _finishOnboarding
                              : () {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                        ),
                      ),
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
}

class _OnboardContent {
  final String title;
  final String subtitle;
  final String description;
  final List<String> features;
  final IconData image;
  final Color color;
  final Color backgroundColor;

  const _OnboardContent({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.image,
    required this.color,
    required this.backgroundColor,
  });
}
