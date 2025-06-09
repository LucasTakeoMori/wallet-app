import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String name;

  Category({required this.name}) : id = const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(name: map['name'] as String);
  }
}
