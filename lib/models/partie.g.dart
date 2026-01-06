// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PartieAdapter extends TypeAdapter<Partie> {
  @override
  final int typeId = 1;

  @override
  Partie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Partie(
      id: fields[0] as int,
      titre: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Partie obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.titre);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
