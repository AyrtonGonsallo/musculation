// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercice.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciceAdapter extends TypeAdapter<Exercice> {
  @override
  final int typeId = 2;

  @override
  Exercice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercice(
      id: fields[0] as int,
      titre: fields[1] as String,
      gif: fields[2] as String,
      lienVideo: fields[3] as String,
      categorie: fields[4] as String,
      sectionId: fields[5] as int,
      partieId: fields[6] as int,
      conseils: fields[7] as String,
      gif_local: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Exercice obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.titre)
      ..writeByte(2)
      ..write(obj.gif)
      ..writeByte(3)
      ..write(obj.lienVideo)
      ..writeByte(4)
      ..write(obj.categorie)
      ..writeByte(5)
      ..write(obj.sectionId)
      ..writeByte(6)
      ..write(obj.partieId)
      ..writeByte(7)
      ..write(obj.conseils)
      ..writeByte(8)
      ..write(obj.gif_local);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
