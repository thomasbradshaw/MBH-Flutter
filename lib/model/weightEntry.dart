import 'dart:io';

///
///
///
class WeightEntry {
  DateTime dateTime;
  double weight;
  String note;
  File image;

  // Ctor
  WeightEntry(this.dateTime, this.weight, this.note, this.image);
}