import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/detection_history.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryDetailPage extends StatefulWidget {
  final DetectionHistory history;
  const HistoryDetailPage({Key? key, required this.history}) : super(key: key);

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  bool _isDeleting = false;

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.history.summary));
    _showSuccessSnackBar('Ringkasan deteksi disalin ke clipboard');
  }

  Color _getFreshnessColor(String summary) {
    if (summary.toLowerCase().contains('segar') &&
        !summary.toLowerCase().contains('kurang')) {
      return Colors.green;
    } else if (summary.toLowerCase().contains('kurang segar')) {
      return Colors.orange;
    } else if (summary.toLowerCase().contains('tidak segar')) {
      return Colors.red;
    }
    return Colors.grey;
  }

  IconData _getStatusIcon(String summary) {
    if (summary.toLowerCase().contains('segar') &&
        !summary.toLowerCase().contains('kurang')) {
      return Icons.check_circle;
    } else if (summary.toLowerCase().contains('kurang segar')) {
      return Icons.warning;
    } else if (summary.toLowerCase().contains('tidak segar')) {
      return Icons.dangerous;
    }
    return Icons.help;
  }

  String _getMainStatus(String summary) {
    if (summary.toLowerCase().contains('segar') &&
        !summary.toLowerCase().contains('kurang')) {
      return 'IKAN SEGAR';
    } else if (summary.toLowerCase().contains('kurang segar')) {
      return 'KURANG SEGAR';
    } else if (summary.toLowerCase().contains('tidak segar')) {
      return 'TIDAK SEGAR';
    }
    return 'STATUS TIDAK DIKETAHUI';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Riwayat Deteksi'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Salin hasil deteksi',
            onPressed: _copyToClipboard,
          ),
          PopupMenuButton<String>(
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'delete' && !_isDeleting) {
                await _confirmDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                enabled: !_isDeleting,
                child: Row(
                  children: [
                    Icon(Icons.delete,
                        color: _isDeleting ? Colors.grey : Colors.red),
                    const SizedBox(width: 8),
                    Text(_isDeleting ? 'Menghapus...' : 'Hapus riwayat',
                        style: TextStyle(
                            color: _isDeleting ? Colors.grey : Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator card at top
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _getFreshnessColor(widget.history.summary)
                      .withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getFreshnessColor(widget.history.summary),
                      _getFreshnessColor(widget.history.summary)
                          .withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getStatusIcon(widget.history.summary),
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status Deteksi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getMainStatus(widget.history.summary),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _formatDateTime(widget.history.detectedAt),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Hero image dengan enhanced styling
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: double.infinity,
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[100],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Hero(
                      tag: 'history_image_${widget.history.detectedAt}',
                      child: Image.file(
                        File(widget.history.imagePath),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.grey[200]!, Colors.grey[300]!],
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Gambar tidak ditemukan',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'File mungkin telah dihapus atau dipindahkan',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Overlay dengan info
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.image,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Foto Deteksi',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Results section dengan improved layout
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.assignment_turned_in,
                            color: Colors.blue[700],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Hasil Analisis Deteksi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.copy,
                              size: 18,
                              color: Colors.blue[600],
                            ),
                          ),
                          onPressed: _copyToClipboard,
                          tooltip: 'Salin hasil deteksi',
                        ),
                      ],
                    ),
                  ),

                  // Content section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Hasil:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._buildEnhancedSummaryWidgets(widget.history.summary),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aksi Cepat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.copy,
                            label: 'Salin Hasil',
                            color: Colors.blue,
                            onTap: _copyToClipboard,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.share,
                            label: 'Bagikan',
                            color: Colors.green,
                            onTap: () {
                              // TODO: Implement share functionality
                              _showSuccessSnackBar(
                                  'Fitur bagikan akan segera tersedia');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.download,
                            label: 'Simpan Gambar',
                            color: Colors.orange,
                            onTap: () {
                              // TODO: Implement download functionality
                              _showSuccessSnackBar(
                                  'Fitur simpan gambar akan segera tersedia');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.delete_outline,
                            label: 'Hapus',
                            color: Colors.red,
                            onTap: _confirmDelete,
                            isDestructive: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Riwayat'),
          ],
        ),
        content: const Text(
            'Apakah Anda yakin ingin menghapus riwayat deteksi ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isDeleting = true);
      try {
        final box = await Hive.openBox<DetectionHistory>('history');
        final key = box.keys.firstWhere(
          (k) => box.get(k) == widget.history,
          orElse: () => null,
        );
        if (key != null) {
          await box.delete(key);
          if (mounted) {
            Navigator.of(context).pop();
            _showSuccessSnackBar('Riwayat berhasil dihapus');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus riwayat: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Hari ini, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Kemarin, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // Helper untuk parsing dan menampilkan summary dengan enhanced UI
  List<Widget> _buildEnhancedSummaryWidgets(String summary) {
    final lines = summary.split('\n');
    List<Widget> widgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Main fish detection result
      if (line.contains('Ikan') || line.contains('IKAN')) {
        widgets.add(_buildMainResultCard(line));
      }
      // Recommendations
      else if (line.startsWith('- Ikan dalam kondisi') ||
          line.startsWith('- Ikan kurang segar') ||
          line.startsWith('- Ikan tidak segar')) {
        widgets.add(_buildRecommendationCard(
          line.substring(2),
          Icons.psychology,
          Colors.blue[600]!,
          'Rekomendasi',
        ));
      }
      // Processing suggestions
      else if (line.startsWith('- Saran pengolahan:')) {
        widgets.add(_buildRecommendationCard(
          line.substring(2).replaceFirst('Saran pengolahan: ', ''),
          Icons.restaurant_menu,
          Colors.orange[600]!,
          'Cara Pengolahan',
        ));
      }
      // Storage suggestions
      else if (line.startsWith('- Saran penyimpanan:')) {
        widgets.add(_buildRecommendationCard(
          line.substring(2).replaceFirst('Saran penyimpanan: ', ''),
          Icons.kitchen,
          Colors.purple[600]!,
          'Cara Penyimpanan',
        ));
      }
      // Other bullet points
      else if (line.startsWith('- ')) {
        widgets.add(_buildSimpleInfoRow(line.substring(2)));
      }
      // Regular text
      else if (line.isNotEmpty) {
        widgets.add(_buildSimpleInfoRow(line));
      }
    }

    return widgets;
  }

  Widget _buildMainResultCard(String content) {
    final color = _getFreshnessColorFromLine(content);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.pets,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hasil Deteksi Utama',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
      String content, IconData icon, Color color, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Text(
          content.length > 60 ? '${content.substring(0, 60)}...' : content,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInfoRow(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: _isDeleting && isDestructive ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: (_isDeleting && isDestructive)
              ? Colors.grey[200]
              : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (_isDeleting && isDestructive)
                ? Colors.grey[300]!
                : color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isDeleting && isDestructive)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey[500],
                ),
              )
            else
              Icon(
                icon,
                color: color,
                size: 18,
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                (_isDeleting && isDestructive) ? 'Menghapus...' : label,
                style: TextStyle(
                  color:
                      (_isDeleting && isDestructive) ? Colors.grey[500] : color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFreshnessColorFromLine(String line) {
    if (line.toLowerCase().contains('segar') &&
        !line.toLowerCase().contains('kurang')) {
      return Colors.green;
    } else if (line.toLowerCase().contains('kurang segar')) {
      return Colors.orange;
    } else if (line.toLowerCase().contains('tidak segar')) {
      return Colors.red;
    }
    return Colors.blue;
  }
}
