import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofm_admin/providers/auth.dart';
import 'package:rxdart/subjects.dart';
import '../models/employee.dart';
import '../models/shop.dart';
import '../models/stock.dart';
import '../models/sale.dart';
import '../models/waste.dart';
import '../models/product.dart';
import './connection.dart';

DatabaseProvider dbService = DatabaseProvider();

class DatabaseProvider {
  FirebaseFirestore _db = FirebaseFirestore.instance;
  final shops = BehaviorSubject<List<Shop>>();
  final employees = BehaviorSubject<List<Employee>>();
  final products = BehaviorSubject<List<Product>>();
  final items = BehaviorSubject<QuerySnapshot>();
  final stock = BehaviorSubject<List<Stock>>();
  final sales = BehaviorSubject<List<Sale>>();
  final monthsales = BehaviorSubject<List<Sale>>();
  final waste = BehaviorSubject<List<Waste>>();
  final monthwaste = BehaviorSubject<List<Waste>>();

  DatabaseProvider() {
    _db.collection('shops').snapshots().listen((QuerySnapshot shopsSnapshot) {
      shops.add(
        shopsSnapshot.docs
            .map(
              (document) => Shop(
                shop: (document.data() as Map<String, dynamic>)["shop"],
                shopid: (document.data() as Map<String, dynamic>)["shopid"],
              ),
            )
            .toList(),
      );
    });

    _db
        .collection('employees')
        .snapshots()
        .listen((QuerySnapshot employeesSnapshot) {
      List<Employee> employees = [];
      employeesSnapshot.docs.forEach((document) {
        dynamic data = document.data();
        List<Map<String, dynamic>> rawShops = data["shops"] ?? [];

        List<Shop> shops = rawShops.map((shop) {
          return Shop(
            shop: shop["shop"],
            shopid: shop["shopid"],
          );
        }).toList(); // Convert to list of Shop

        employees.add(
          Employee(
            name: data["name"] ?? "",
            email: data["email"] ?? "",
            active: data["active"] ?? false,
            shops: shops, // Now a list of Shop
          ),
        );
      });
    });

    _db
        .collection('products')
        .snapshots()
        .listen((QuerySnapshot productsSnapshot) {
      products.add(
        productsSnapshot.docs
            .map((document) => Product(
                  name: (document.data() as Map<String, dynamic>)["name"],
                  productid:
                      (document.data() as Map<String, dynamic>)["productId"],
                  buyingPrice:
                      (document.data() as Map<String, dynamic>)["buyingPrice"],
                  sellingPrice:
                      (document.data() as Map<String, dynamic>)["sellingPrice"],
                  uom: (document.data() as Map<String, dynamic>)["uom"],
                ))
            .toList(),
      );
    });

    getMonthSales();
    getMonthWaste();
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    var currentUser = authService.auth.currentUser;
    if (currentUser != null) {
      var userDocument =
          await _db.collection("users").doc(currentUser.email).get();
      return userDocument.data() ??
          {}; // Provide an empty map as default value if data is null
    } else {
      throw Exception(
          "No current user"); // Or handle this case according to your application logic
    }
  }

  Future<void> addShop(String shop) async {
    if (connectionService.connected.value) {
      try {
        DocumentReference added = await _db.collection('shops').add({
          "shop": shop,
        });

        return await added.update({
          "shopid": added.id,
        });
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> deleteShop(String shopid) async {
    if (connectionService.connected.value) {
      try {
        return await _db.collection('shops').doc(shopid).delete();
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> addProduct(Product product) async {
    if (connectionService.connected.value) {
      try {
        DocumentReference added = await _db.collection('products').add({
          "name": product.name,
          "buyingPrice": product.buyingPrice,
          "sellingPrice": product.sellingPrice,
          "uom": product.uom,
        });

        return await added.update({
          "productid": added.id,
        });
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> deleteProducts(List<Product> products) async {
    if (connectionService.connected.value) {
      try {
        int deleted = 0;
        for (var product in products) {
          print(product.productid);
          await _db.collection('products').doc(product.productid).delete();
          deleted++;
          if (deleted == products.length) {
            return;
          }
        }
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> editProduct(Product product) async {
    if (connectionService.connected.value) {
      try {
        return await _db.collection('products').doc(product.productid).update({
          "name": product.name,
          "uom": product.uom,
          "buyingPrice": product.buyingPrice,
          "sellingPrice": product.sellingPrice,
        });
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> addEmployee(Employee employee) async {
    if (connectionService.connected.value) {
      try {
        return await _db.collection('employees').doc(employee.email).set({
          "name": employee.name,
          "email": employee.email,
          "shops": employee.shops
              .map((shop) => {
                    "shop": shop.shop,
                    "shopid": shop.shopid,
                  })
              .toList(),
          "roles": {
            "admin": false,
            "editor": true,
          },
          "active": employee.active
        });
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> editEmployee(Employee employee) async {
    if (connectionService.connected.value) {
      try {
        return await _db.collection('employees').doc(employee.email).update({
          "name": employee.name,
          "shops": employee.shops
              .map((shop) => {
                    "shop": shop.shop,
                    "shopid": shop.shopid,
                  })
              .toList(),
          "active": employee.active,
        });
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> deleteEmployees(List<Employee> employees) async {
    if (connectionService.connected.value) {
      try {
        try {
          for (var employee in employees) {
            // Ensure it loops over all employees
            await _db.collection('employees').doc(employee.email).delete();
          }
        } catch (e) {
          throw Exception("Error deleting employees: $e");
        }
      } catch (e) {
        throw e;
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<void> deleteEmployee(Employee employee) async {
    if (connectionService.connected.value) {
      // Check internet connection
      try {
        // Delete the employee from the collection using the unique identifier
        await _db.collection('employees').doc(employee.email).delete();
      } catch (e) {
        throw Exception("Error deleting employee: $e");
      }
    } else {
      throw Exception("NOINTERNET");
    }
  }

  Future<List<Shop>> getShops() async {
    try {
      QuerySnapshot res = await _db.collection('shops').get();
      return res.docs
          .map(
            (shop) => Shop(
              shop: (shop.data() as Map<String, dynamic>)[
                  "shop"], // Invoke data() method to get the map
              shopid: (shop.data() as Map<String, dynamic>)[
                  "shopId"], // Similarly, invoke data() here
            ),
          )
          .toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  void getShopSales(String date, Shop shop) {
    sales.add([]);
    _db
        .collection('sales')
        .where("shop", isEqualTo: {
          "shop": shop.shop,
          "shopid": shop.shopid,
        })
        .where("dateadded", isEqualTo: date.toString())
        .snapshots()
        .listen(
          (QuerySnapshot salesSnapshot) {
            sales.add(
              salesSnapshot.docs
                  .map((document) => Sale(
                        product: Product(
                          name: (document.data()
                              as Map<String, dynamic>)["product"]["name"],
                          uom: (document.data()
                              as Map<String, dynamic>)["product"]["uom"],
                          buyingPrice: (document.data()
                                  as Map<String, dynamic>)["product"]
                              ["buyingPrice"],
                          sellingPrice: (document.data()
                                  as Map<String, dynamic>)["product"]
                              ["sellingPrice"],
                          productid: (document.data()
                              as Map<String, dynamic>)["product"]["productid"],
                        ),
                        // Other properties of Sale class

                        // Other properties of Sale class
                        // Other properties of Sale class

                        shop: Shop(
                          shop: (document.data()
                              as Map<String, dynamic>)["shop"]["shop"],
                          shopid: (document.data()
                              as Map<String, dynamic>)["shop"]["shopid"],
                        ),
                        stockid: (document.data()
                            as Map<String, dynamic>)["stockid"],
                        salesid: (document.data()
                            as Map<String, dynamic>)["salesid"],
                        dateadded: (document.data()
                            as Map<String, dynamic>)["dateadded"],
                        timestamp: (document.data()
                            as Map<String, dynamic>)["timestamp"],
                        quantity: (document.data()
                            as Map<String, dynamic>)["quantity"],
                      ))
                  .toList(),
            );
          },
        );
  }

  void getMonthSales() {
    var now = DateTime.now();
    var startMonth = DateTime.utc(now.year, now.month, 1);

    _db
        .collection('sales')
        .where("timestamp",
            isGreaterThanOrEqualTo: startMonth.millisecondsSinceEpoch)
        .where("timestamp", isLessThanOrEqualTo: now.millisecondsSinceEpoch)
        .snapshots()
        .listen(
      (QuerySnapshot salesSnapshot) {
        monthsales.add(
          salesSnapshot.docs
              .map((document) => Sale(
                    product: Product(
                      name: (document.data() as Map<String, dynamic>)["product"]
                          ["name"],
                      uom: (document.data() as Map<String, dynamic>)["product"]
                          ["uom"],
                      buyingPrice: (document.data()
                          as Map<String, dynamic>)["product"]["buyingPrice"],
                      sellingPrice: (document.data()
                          as Map<String, dynamic>)["product"]["sellingPrice"],
                      productid: (document.data()
                          as Map<String, dynamic>)["product"]["productid"],
                    ),
                    shop: Shop(
                      shop: (document.data() as Map<String, dynamic>)["shop"]
                          ["shop"],
                      shopid: (document.data() as Map<String, dynamic>)["shop"]
                          ["shopid"],
                    ),
                    stockid:
                        (document.data() as Map<String, dynamic>)["stockid"],
                    salesid:
                        (document.data() as Map<String, dynamic>)["salesid"],
                    dateadded:
                        (document.data() as Map<String, dynamic>)["dateadded"],
                    timestamp:
                        (document.data() as Map<String, dynamic>)["timestamp"],
                    quantity:
                        (document.data() as Map<String, dynamic>)["quantity"],
                  ))
              .toList(),
        );
      },
    );
  }

  Future<List<Sale>> getShopMonthSales(Shop shop) async {
    var now = DateTime.now();
    var startMonth = DateTime.utc(now.year, now.month, 1);

    var salesSnapshot = await _db
        .collection('sales')
        .where("shop", isEqualTo: {
          "shop": shop.shop,
          "shopid": shop.shopid,
        })
        .where("timestamp",
            isGreaterThanOrEqualTo: startMonth.millisecondsSinceEpoch)
        .where("timestamp", isLessThanOrEqualTo: now.millisecondsSinceEpoch)
        .get();

    return salesSnapshot.docs
        .map((document) => Sale(
              product: Product(
                name: (document.data())["product"]["name"],
                uom: (document.data())["product"]["uom"],
                buyingPrice: (document.data())["product"]["buyingPrice"],
                sellingPrice: (document.data())["product"]["sellingPrice"],
                productid: (document.data())["product"]["productid"],
              ),
              shop: Shop(
                shop: (document.data())["shop"]["shop"],
                shopid: (document.data())["shop"]["shopid"],
              ),
              stockid: (document.data())["stockid"],
              salesid: (document.data())["salesid"],
              dateadded: (document.data())["dateadded"],
              timestamp: (document.data())["timestamp"],
              quantity: (document.data())["quantity"],
            ))
        .toList();
  }

  void getShopWaste(String date, Shop shop) {
    waste.add([]);
    _db
        .collection('waste')
        .where("shop", isEqualTo: {
          "shop": shop.shop,
          "shopid": shop.shopid,
        })
        .where("dateadded", isEqualTo: date.toString())
        .snapshots()
        .listen(
          (QuerySnapshot salesSnapshot) {
            waste.add(
              salesSnapshot.docs
                  .map((document) => Waste(
                        product: Product(
                          name: (document.data()
                              as Map<String, dynamic>)["product"]["name"],
                          uom: (document.data()
                              as Map<String, dynamic>)["product"]["uom"],
                          buyingPrice: (document.data()
                                  as Map<String, dynamic>)["product"]
                              ["buyingPrice"],
                          sellingPrice: (document.data()
                                  as Map<String, dynamic>)["product"]
                              ["sellingPrice"],
                          productid: (document.data()
                              as Map<String, dynamic>)["product"]["productid"],
                        ),
                        shop: Shop(
                          shop: (document.data()
                              as Map<String, dynamic>)["shop"]["shop"],
                          shopid: (document.data()
                              as Map<String, dynamic>)["shop"]["shopid"],
                        ),
                        stockid: (document.data()
                            as Map<String, dynamic>)["stockid"],
                        wasteid: (document.data()
                            as Map<String, dynamic>)["wasteid"],
                        dateadded: (document.data()
                            as Map<String, dynamic>)["dateadded"],
                        timestamp: (document.data()
                            as Map<String, dynamic>)["timestamp"],
                        quantity: (document.data()
                            as Map<String, dynamic>)["quantity"],
                      ))
                  .toList(),
            );
          },
        );
  }

  void getMonthWaste() {
    var now = DateTime.now();
    var startMonth = DateTime.utc(now.year, now.month, 1);

    _db
        .collection('waste')
        .where("timestamp",
            isGreaterThanOrEqualTo: startMonth.millisecondsSinceEpoch)
        .where("timestamp", isLessThanOrEqualTo: now.millisecondsSinceEpoch)
        .snapshots()
        .listen(
      (QuerySnapshot wasteSnapshot) {
        monthwaste.add(
          wasteSnapshot.docs
              .map((document) => Waste(
                    product: Product(
                      name: (document.data() as Map<String, dynamic>)["product"]
                          ["name"],
                      uom: (document.data() as Map<String, dynamic>)["product"]
                          ["uom"],
                      buyingPrice: (document.data()
                          as Map<String, dynamic>)["product"]["buyingPrice"],
                      sellingPrice: (document.data()
                          as Map<String, dynamic>)["product"]["sellingPrice"],
                      productid: (document.data()
                          as Map<String, dynamic>)["product"]["productid"],
                    ),
                    shop: Shop(
                      shop: (document.data() as Map<String, dynamic>)["shop"]
                          ["shop"],
                      shopid: (document.data() as Map<String, dynamic>)["shop"]
                          ["shopid"],
                    ),
                    stockid:
                        (document.data() as Map<String, dynamic>)["stockid"],
                    wasteid:
                        (document.data() as Map<String, dynamic>)["wasteid"],
                    dateadded:
                        (document.data() as Map<String, dynamic>)["dateadded"],
                    timestamp:
                        (document.data() as Map<String, dynamic>)["timestamp"],
                    quantity:
                        (document.data() as Map<String, dynamic>)["quantity"],
                  ))
              .toList(),
        );
      },
    );
  }

  Future<List<Waste>> getShopMonthWaste(Shop shop) async {
    var now = DateTime.now();
    var startMonth = DateTime.utc(now.year, now.month, 1);

    var wasteSnapshot = await _db
        .collection('waste')
        .where("shop", isEqualTo: {
          "shop": shop.shop,
          "shopid": shop.shopid,
        })
        .where("timestamp",
            isGreaterThanOrEqualTo: startMonth.millisecondsSinceEpoch)
        .where("timestamp", isLessThanOrEqualTo: now.millisecondsSinceEpoch)
        .get();

    return wasteSnapshot.docs
        .map((document) => Waste(
              product: Product(
                name: (document.data())["product"]["name"],
                uom: (document.data())["product"]["uom"],
                buyingPrice: (document.data())["product"]["buyingPrice"],
                sellingPrice: (document.data())["product"]["sellingPrice"],
                productid: (document.data())["product"]["productid"],
              ),
              shop: Shop(
                shop: (document.data())["shop"]["shop"],
                shopid: (document.data())["shop"]["shopid"],
              ),
              stockid: (document.data())["stockid"],
              wasteid: (document.data())["wasteid"],
              dateadded: (document.data())["dateadded"],
              timestamp: (document.data())["timestamp"],
              quantity: (document.data())["quantity"],
            ))
        .toList();
  }

  void getShopStock(Shop shop) {
    stock.add([]);
    _db
        .collection('stock')
        .where("shop", isEqualTo: {
          "shop": shop.shop,
          "shopid": shop.shopid,
        })
        .snapshots()
        .listen((QuerySnapshot stockSnapshot) {
          stock.add(
            stockSnapshot.docs
                .map((document) => Stock(
                      product: Product(
                          name: (document.data()
                              as Map<String, dynamic>)["product"]["name"],
                          uom: (document.data()
                              as Map<String, dynamic>)["product"]["uom"],
                          buyingPrice: (document.data()
                                  as Map<String, dynamic>)["product"]
                              ["buyingPrice"],
                          sellingPrice: (document.data()
                                  as Map<String, dynamic>)["product"]
                              ["sellingPrice"],
                          productid: (document.data()
                              as Map<String, dynamic>)["product"]["productid"]),
                      shop: Shop(
                        shop: (document.data() as Map<String, dynamic>)["shop"]
                            ["shop"],
                        shopid: (document.data()
                            as Map<String, dynamic>)["shop"]["shopid"],
                      ),
                      dateadded: (document.data()
                          as Map<String, dynamic>)["dateadded"],
                      quantity:
                          (document.data() as Map<String, dynamic>)["quantity"],
                      stockid:
                          (document.data() as Map<String, dynamic>)["stockid"],
                    ))
                .toList(),
          );
        });
  }

  dispose() {
    shops.close();
    products.close();
    employees.close();
    items.close();
    stock.close();
    waste.close();
    monthwaste.close();
    sales.close();
    monthsales.close();
  }
}

final FirebaseFirestore _firestoree = FirebaseFirestore.instance;

Stream<List<Employee>> getItemsStream(String collectionPath) {
  return _firestoree
      .collection(collectionPath)
      .snapshots()
      .map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      return Employee.fromFirebase(doc.data() as Map<String, dynamic>);
    }).toList();
  });
}
