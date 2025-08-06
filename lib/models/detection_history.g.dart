// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetectionHistoryAdapter extends TypeAdapter<DetectionHistory> {
  @override
  final int typeId = 0;

  @override
  DetectionHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetectionHistory(
      imagePath: fields[0] as String,
      detectedAt: fields[1] as DateTime,
      summary: fields[2] as String,
      confidenceScore: fields[3] as double?,
      detectionType: fields[4] as String?,
      tags: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, DetectionHistory obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.imagePath)
      ..writeByte(1)
      ..write(obj.detectedAt)
      ..writeByte(2)
      ..write(obj.summary)
      ..writeByte(3)
      ..write(obj.confidenceScore)
      ..writeByte(4)
      ..write(obj.detectionType)
      ..writeByte(5)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
