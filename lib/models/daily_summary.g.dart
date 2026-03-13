// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_summary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailySummaryAdapter extends TypeAdapter<DailySummary> {
  @override
  final int typeId = 1;

  @override
  DailySummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailySummary(
      date: fields[0] as DateTime,
      waterCups: fields[1] as int,
      sleepHours: fields[2] as double,
      calories: fields[3] as int,
      steps: fields[4] as int,
      synced: fields[5] as bool,
      yogaSessions: fields[6] as int,
      plankMinutes: fields[7] as int,
      runningKm: fields[8] as double,
      meditationMinutes: fields[9] as int,
      sugarFreeDays: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailySummary obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.waterCups)
      ..writeByte(2)
      ..write(obj.sleepHours)
      ..writeByte(3)
      ..write(obj.calories)
      ..writeByte(4)
      ..write(obj.steps)
      ..writeByte(5)
      ..write(obj.synced)
      ..writeByte(6)
      ..write(obj.yogaSessions)
      ..writeByte(7)
      ..write(obj.plankMinutes)
      ..writeByte(8)
      ..write(obj.runningKm)
      ..writeByte(9)
      ..write(obj.meditationMinutes)
      ..writeByte(10)
      ..write(obj.sugarFreeDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
