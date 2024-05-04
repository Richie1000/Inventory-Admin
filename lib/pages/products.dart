import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ofm_admin/widgets/custom_bottom_modal_sheet.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/db.dart';
import '../widgets/bottom_sheet.dart';
import '../models/product.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late List<Product> _selectedProducts;

  final _nameController = TextEditingController();
  final _uom = TextEditingController();
  final _sPrice = TextEditingController();
  final _bPrice = TextEditingController();

  @override
  void initState() {
    _selectedProducts = [];
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _uom.dispose();
    _sPrice.dispose();
    _bPrice.dispose();
    super.dispose();
  }

  void showToast(String message) {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          OverflowBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                icon: Icon(
                  Icons.add_circle,
                  color: Theme.of(context).primaryColor,
                ),
                label: Text(
                  'Add',
                ),
                onPressed: () {
                  _addProduct(context);
                },
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(30.0),
                // ),
              ),
              Visibility(
                visible: _selectedProducts.length == 1,
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Edit',
                  ),
                  onPressed: () {
                    _editProduct(context, _selectedProducts[0]);
                  },
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(30.0),
                  // ),
                ),
              ),
              Visibility(
                visible: _selectedProducts.length > 0,
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Delete',
                  ),
                  onPressed: () {
                    dbService.deleteProducts(_selectedProducts).then((res) {
                      setState(() {
                        _selectedProducts = [];
                      });
                    }).catchError((error) {
                      if (error.toString().contains("NOINTERNET")) {
                        showToast(
                            "You don't seem to have an active internet connection");
                      } else {
                        print(error);
                        showToast(
                            "There seems to be a problem. Please try again later.");
                      }
                    });
                  },
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(30.0),
                  // ),
                ),
              )
            ],
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                SingleChildScrollView(
                  child: StreamBuilder<List<Product>>(
                      stream: dbService.products.stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Product>> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Container(
                                width: (MediaQuery.of(context).size.width),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: List<Widget>.filled(
                                    5,
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 8.0),
                                      child: Shimmer.fromColors(
                                        baseColor: Colors.black12,
                                        highlightColor: Colors.black26,
                                        child: Container(
                                          width: (MediaQuery.of(context)
                                              .size
                                              .width),
                                          height: 20.0,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    growable: false,
                                  ),
                                ),
                              );
                            default:
                              return DataTable(
                                columns: [
                                  DataColumn(
                                      label: Text("Name"),
                                      numeric: false,
                                      tooltip: "This is the product's name"),
                                  DataColumn(
                                      label: Text("UOM"),
                                      numeric: false,
                                      tooltip:
                                          "This is the product's Unit of Measurement"),
                                  DataColumn(
                                      label: Text("Buying Price"),
                                      numeric: true,
                                      tooltip:
                                          "This is the products's Buying Price"),
                                  DataColumn(
                                    label: Text("Selling Price"),
                                    numeric: true,
                                    tooltip:
                                        "This is the product's Selling Price",
                                  ),
                                  DataColumn(
                                      label: Text("Profit"),
                                      numeric: true,
                                      tooltip: "This is the Profit margin"),
                                ],
                                rows: snapshot.data!
                                    .map(
                                      (Product product) => DataRow(
                                        selected:
                                            _selectedProducts.contains(product),
                                        onSelectChanged: (selected) {
                                          _onSelectedRow(selected!, product);
                                        },
                                        cells: [
                                          DataCell(
                                            Text(
                                              product.name,
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              product.uom!,
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              product.buyingPrice.toString(),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              product.sellingPrice.toString(),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              (product.sellingPrice -
                                                      product.buyingPrice)
                                                  .toString(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              );
                          }
                        }
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSelectedRow(bool selected, Product product) async {
    setState(() {
      if (selected) {
        _selectedProducts.add(product);
      } else {
        _selectedProducts.remove(product);
      }
    });
  }

  void _editProduct(BuildContext context, Product product) {
    _nameController.text = product.name;
    _uom.text = product.uom!;
    _sPrice.text = product.sellingPrice.toString();
    _bPrice.text = product.buyingPrice.toString();
    showModalBottomSheet(
      context: context,
      //isScrollControlled: true,
      builder: (BuildContext bc) {
        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          color: Color(0xFF737373),
          child: Container(
            height: MediaQuery.of(context).size.height / 1.7,
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
              ),
            ),
            child: Wrap(
              children: <Widget>[
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      width: (MediaQuery.of(context).size.width) * 0.5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: TextField(
                          controller: _nameController,
                          //autofocus: true,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Product Name",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: (MediaQuery.of(context).size.width) * 0.5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: TextField(
                          controller: _uom,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "UOM",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      width: (MediaQuery.of(context).size.width) * 0.5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: TextField(
                          controller: _bPrice,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: "Buying Price",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: (MediaQuery.of(context).size.width) * 0.5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: TextField(
                          controller: _sPrice,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: "Selling Price",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 8.0,
                    left: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(
                        Icons.add_circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      OverflowBar(
                        children: <Widget>[
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                              _nameController.clear();
                              _uom.clear();
                              _sPrice.clear();
                              _bPrice.clear();
                              _selectedProducts.clear();
                            },
                          ),
                          TextButton(
                            child: Text(
                              "Save",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            onPressed: () {
                              if (_nameController.text.isNotEmpty &&
                                  _sPrice.text.isNotEmpty &&
                                  _bPrice.text.isNotEmpty &&
                                  _uom.text.isNotEmpty) {
                                dbService
                                    .editProduct(
                                  Product(
                                    name: _nameController.text,
                                    uom: _uom.text,
                                    sellingPrice: double.parse(_sPrice.text),
                                    buyingPrice: double.parse(_bPrice.text),
                                    productid: product.productid,
                                  ),
                                )
                                    .then((_) {
                                  Navigator.pop(context);
                                  _nameController.clear();
                                  _uom.clear();
                                  _sPrice.clear();
                                  _bPrice.clear();
                                  _selectedProducts.clear();
                                }).catchError((error) {
                                  if (error.toString().contains("NOINTERNET")) {
                                    showToast(
                                        "You dont have Internet Connection");
                                  } else {
                                    print(error);
                                    showToast("Sorry, Something occured");
                                  }
                                });
                              }
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addProduct(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) => CustomModalBottomSheet(
                child: Container(
              color: Color(0xFF737373),
              child: Container(
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(10.0),
                    topRight: const Radius.circular(10.0),
                  ),
                ),
                child: Wrap(
                  children: <Widget>[
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          width: (MediaQuery.of(context).size.width) * 0.5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            child: TextField(
                              controller: _nameController,
                              //autofocus: true,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: "Product Name",
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: (MediaQuery.of(context).size.width) * 0.5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            child: TextField(
                              controller: _uom,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: "UOM",
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          width: (MediaQuery.of(context).size.width) * 0.5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: TextField(
                              controller: _bPrice,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                hintText: "Buying Price",
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: (MediaQuery.of(context).size.width) * 0.5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: TextField(
                              controller: _sPrice,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                hintText: "Selling Price",
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        bottom: 8.0,
                        left: 16.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.add_circle,
                            color: Theme.of(context).primaryColor,
                          ),
                          OverflowBar(
                            children: <Widget>[
                              TextButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _nameController.clear();
                                  _uom.clear();
                                  _sPrice.clear();
                                  _bPrice.clear();
                                },
                              ),
                              TextButton(
                                child: Text(
                                  "Save",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onPressed: () {
                                  if (_nameController.text.isNotEmpty &&
                                      _sPrice.text.isNotEmpty &&
                                      _bPrice.text.isNotEmpty &&
                                      _uom.text.isNotEmpty) {
                                    dbService
                                        .addProduct(
                                      Product(
                                        name: _nameController.text,
                                        uom: _uom.text,
                                        sellingPrice:
                                            double.parse(_sPrice.text),
                                        buyingPrice: double.parse(_bPrice.text),
                                      ),
                                    )
                                        .then((_) {
                                      Navigator.pop(context);
                                      _nameController.clear();
                                      _uom.clear();
                                      _sPrice.clear();
                                      _bPrice.clear();
                                    }).catchError((error) {
                                      if (error
                                          .toString()
                                          .contains("NOINTERNET")) {
                                        showToast(
                                            "There seems to be a problem. Please try again later.");
                                      } else {
                                        print(error);
                                        showToast(
                                            "There seems to be a problem. Please try again later.");
                                      }
                                    });
                                  }
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
