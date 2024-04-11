import 'package:ofm_admin/models/role.dart';
import 'package:ofm_admin/models/shop.dart';

class Employee {
  final String name;
  final List<Shop> shops;
  final String email;
  final Role? roles;
  final bool active;

  Employee({
    required this.name,
    required this.shops,
    required this.email,
    required this.active,
    this.roles,
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
    );
  }
}
