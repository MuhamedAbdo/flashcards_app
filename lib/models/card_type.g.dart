// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardTypeAdapter extends TypeAdapter<CardType> {
  @override
  final int typeId = 3;

  @override
  CardType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CardType.programming;
      case 1:
        return CardType.math;
      case 2:
        return CardType.git;
      case 3:
        return CardType.text;
      case 4:
        return CardType.other;
      default:
        return CardType.programming;
    }
  }

  @override
  void write(BinaryWriter writer, CardType obj) {
    switch (obj) {
      case CardType.programming:
        writer.writeByte(0);
        break;
      case CardType.math:
        writer.writeByte(1);
        break;
      case CardType.git:
        writer.writeByte(2);
        break;
      case CardType.text:
        writer.writeByte(3);
        break;
      case CardType.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
