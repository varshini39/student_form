import 'dart:async';

import 'dbhelper.dart';

class Student {
  int? id;
  late String name;
  late String gender;
  late int rank;

  Student(
      {required this.id,
      required this.name,
      required this.gender,
      required this.rank});

  Student.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    gender = map['gender'];
    rank = map['rank'];
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnGender: gender,
      DatabaseHelper.columnRank: rank,
    };
  }
}
