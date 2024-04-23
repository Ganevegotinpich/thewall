//връщане на форматирана дата

import 'package:cloud_firestore/cloud_firestore.dart';

String formatData(Timestamp timestamp) {
  //Timestamp е обектът, който получаваме от БД

  //Конвертиране на в string
  DateTime dateTime = timestamp.toDate();

//година
  String year = dateTime.year.toString();

//месец
  String month = dateTime.month.toString();

//ден
  String day = dateTime.day.toString();

  String formatedData = '$day/$month/$year';

  return formatedData;
}
