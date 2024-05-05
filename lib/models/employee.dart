import 'package:ofm_admin/models/role.dart';
import 'package:ofm_admin/models/shop.dart';

class Employee {
  final String name;
  final List<Shop> shops;
  final String email;
  final Role? roles;
  final bool active;
  final String? id;

  Employee({
    required this.name,
    required this.shops,
    required this.email,
    required this.active,
    this.roles,
    this.id,
  });

  static Future<Employee> fromMap(Map<String, dynamic> map) async {
    List<Shop> shopObjects = (map['shops'] as List<dynamic>)
        .map(
          (shop) => Shop(
            shop: shop["shop"],
            shopid: shop["shopid"],
          ),
        )
        .toList();

    return Employee(
        name: map['name'],
        shops: shopObjects,
        email: map['email'],
        active: map['active'],
        roles: map['roles'],
        id: map['id']);
  }

  factory Employee.fromFirebase(Map<String, dynamic> map) {
    // Correct syntax for list initialization without explicit variable assignment
    List<Shop> shopObjects = (map['shops'] as List<dynamic>).map((shop) {
      return Shop(
        shop: shop['shop'],
        shopid: shop['shopid'],
      );
    }).toList();

    return Employee(
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        active: map['active'] ?? false,
        shops: shopObjects,
        id: map['id'] ?? '');
  }
}
