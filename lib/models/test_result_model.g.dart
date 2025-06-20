// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TestResultAdapter extends TypeAdapter<TestResult> {
  @override
  final int typeId = 2;

  @override
  TestResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestResult(
      id: fields[0] as String,
      deckId: fields[1] as String,
      correctAnswers: fields[3] as int,
      totalQuestions: fields[4] as int,
      testDate: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TestResult obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.deckId)
      ..writeByte(2)
      ..write(obj.testDate)
      ..writeByte(3)
      ..write(obj.correctAnswers)
      ..writeByte(4)
      ..write(obj.totalQuestions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
