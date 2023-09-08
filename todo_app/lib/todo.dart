import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Todo {
  final String? id;
  final String? title;
  final String? desc;
  final String? date;
  final String? time;

  Todo({this.title, this.desc, this.date, this.time, String? id}) : id = id  ?? uuid.v4();

  
}
