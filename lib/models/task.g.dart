// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 3;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as TaskCategory,
      priority: fields[4] as TaskPriority,
      dueDate: fields[5] as DateTime?,
      isCompleted: fields[6] as bool,
      notes: fields[7] as String?,
      isRecurring: fields[8] as bool,
      recurrence: fields[9] as Recurrence?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.isRecurring)
      ..writeByte(9)
      ..write(obj.recurrence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskCategoryAdapter extends TypeAdapter<TaskCategory> {
  @override
  final int typeId = 0;

  @override
  TaskCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskCategory.all;
      case 1:
        return TaskCategory.work;
      case 2:
        return TaskCategory.personal;
      case 3:
        return TaskCategory.wishlist;
      default:
        return TaskCategory.all;
    }
  }

  @override
  void write(BinaryWriter writer, TaskCategory obj) {
    switch (obj) {
      case TaskCategory.all:
        writer.writeByte(0);
        break;
      case TaskCategory.work:
        writer.writeByte(1);
        break;
      case TaskCategory.personal:
        writer.writeByte(2);
        break;
      case TaskCategory.wishlist:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 1;

  @override
  TaskPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriority.low;
      case 1:
        return TaskPriority.medium;
      case 2:
        return TaskPriority.high;
      default:
        return TaskPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    switch (obj) {
      case TaskPriority.low:
        writer.writeByte(0);
        break;
      case TaskPriority.medium:
        writer.writeByte(1);
        break;
      case TaskPriority.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrenceAdapter extends TypeAdapter<Recurrence> {
  @override
  final int typeId = 2;

  @override
  Recurrence read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Recurrence.daily;
      case 1:
        return Recurrence.weekly;
      case 2:
        return Recurrence.monthly;
      default:
        return Recurrence.daily;
    }
  }

  @override
  void write(BinaryWriter writer, Recurrence obj) {
    switch (obj) {
      case Recurrence.daily:
        writer.writeByte(0);
        break;
      case Recurrence.weekly:
        writer.writeByte(1);
        break;
      case Recurrence.monthly:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
