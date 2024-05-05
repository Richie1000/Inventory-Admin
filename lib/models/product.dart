class Product {
  final String name;
  final String? productid;
  final String? uom;
  final double buyingPrice;
  final double sellingPrice;

  const Product({
    required this.name,
    required this.buyingPrice,
    required this.sellingPrice,
    this.uom,
    this.productid,
    //required this.quantity
  });

  Map<String, dynamic> get map {
    return {
      "name": name,
      "productid": productid,
      "uom": uom,
      "buyingPrice": buyingPrice,
      "sellingPrice": sellingPrice,
    };
  }

  factory Product.fromFirebase(Map<String, dynamic> map) {
    // Correct syntax for list initialization without explicit variable assignment
    return Product(
        name: map['name'] ?? '',
        buyingPrice: map['buyingPrice'] ?? '',
        sellingPrice: map['sellingPrice'] ?? false,
        uom: map['uom'],
        productid: map['productid'] ?? '');
  }
}
