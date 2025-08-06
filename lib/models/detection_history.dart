import 'dart:io';

import 'package:hive/hive.dart';

part 'detection_history.g.dart';

@HiveType(typeId: 0)
class DetectionHistory extends HiveObject {
  @HiveField(0)
  String imagePath;

  @HiveField(1)
  DateTime detectedAt;

  @HiveField(2)
  String summary;

  // Optional: Add confidence score if available
  @HiveField(3)
  double? confidenceScore;

  // Optional: Add detection type/category
  @HiveField(4)
  String? detectionType;

  // Optional: Add tags for better categorization
  @HiveField(5)
  List<String> tags;

  DetectionHistory({
    required this.imagePath,
    required this.detectedAt,
    required this.summary,
    this.confidenceScore,
    this.detectionType,
    this.tags = const [],
  });

  // Helper method to get formatted date
  String get formattedDate {
    return '${detectedAt.day}/${detectedAt.month}/${detectedAt.year} ${detectedAt.hour.toString().padLeft(2, '0')}:${detectedAt.minute.toString().padLeft(2, '0')}';
  }

  // Helper method to get relative time
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(detectedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  // Helper method to get short summary
  String get shortSummary {
    final lines = summary.split('\n');
    if (lines.isNotEmpty) {
      return lines.first.length > 50
          ? '${lines.first.substring(0, 50)}...'
          : lines.first;
    }
    return summary;
  }

  // Helper method to check if image file exists
  bool get imageExists {
    try {
      return File(imagePath).existsSync();
    } catch (e) {
      return false;
    }
  }

  // Convert to JSON for backup/export
  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'detectedAt': detectedAt.toIso8601String(),
      'summary': summary,
      'confidenceScore': confidenceScore,
      'detectionType': detectionType,
      'tags': tags,
    };
  }

  // Create from JSON for restore/import
  factory DetectionHistory.fromJson(Map<String, dynamic> json) {
    return DetectionHistory(
      imagePath: json['imagePath'] as String,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      summary: json['summary'] as String,
      confidenceScore: json['confidenceScore'] as double?,
      detectionType: json['detectionType'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  @override
  String toString() {
    return 'DetectionHistory(imagePath: $imagePath, detectedAt: $detectedAt, summary: $shortSummary)';
  }
}
