import 'package:flutter/material.dart';
import '../models/product.dart';
import '../providers/db.dart';

class ProductsDataTable extends StatefulWidget {
  final List<Product> products; // The list of products to display

  const ProductsDataTable({required this.products});

  @override
  _ProductsDataTableState createState() => _ProductsDataTableState();
}

class _ProductsDataTableState extends State<ProductsDataTable> {
  final Set<Product> selectedProducts = {}; // The set of selected products

  void _onSelectedRow(bool selected, Product product) {
    setState(() {
      if (selected) {
        selectedProducts.add(product);
      } else {
        selectedProducts.remove(product);
      }
    });
  }

  void _editSelectedProduct(BuildContext context, Product product) {
    final nameController = TextEditingController(text: product.name);
    final buyingPriceController =
        TextEditingController(text: product.buyingPrice.toString());
    final sellingPriceController =
        TextEditingController(text: product.sellingPrice.toString());
    final uomController = TextEditingController(text: product.uom);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Product"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: buyingPriceController,
                decoration: InputDecoration(labelText: "Buying Price"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: sellingPriceController,
                decoration: InputDecoration(labelText: "Selling Price"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: uomController,
                decoration: InputDecoration(labelText: "Unit of Measure"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close without saving
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Create an updated product object with new values
                final updatedProduct = Product(
                  name: nameController.text,
                  buyingPrice: double.parse(buyingPriceController.text),
                  sellingPrice: double.parse(sellingPriceController.text),
                  uom: uomController.text,
                  productid: product.productid, // Keep the original ID
                );
                print("product id : ${updatedProduct.productid}");
                // Update the product in the database
                dbService.editProduct(updatedProduct);

                selectedProducts.clear();

                Navigator.pop(context); // Close after saving
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedProduct() {
    if (selectedProducts.isNotEmpty) {
      final product = selectedProducts.first; // Get the first selected product

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Delete Product"),
            content: Text("Are you sure you want to delete ${product.name}?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close without deleting
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  //dbService.deleteProducts(selectedProducts as List<product>);  // Delete the product from the database

                  selectedProducts.clear(); // Clear the selection
                  setState(() {}); // Update the UI to reflect changes
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("Delete"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedProducts.isNotEmpty) // Display edit and delete options
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Visibility(
                visible: selectedProducts.length == 1,
                child: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    if (selectedProducts.isNotEmpty) {
                      final product = selectedProducts.first;
                      _editSelectedProduct(context, product);
                    }
                  },
                ),
              ),
              Visibility(
                visible: selectedProducts.length > 0,
                child: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _deleteSelectedProduct,
                ),
              ),
            ],
          ),
        Expanded(
          child: DataTable(
            columns: [
              DataColumn(label: Text("Name")),
              DataColumn(label: Text("Buying Price")),
              DataColumn(label: Text("Selling Price")),
              DataColumn(label: Text("UOM")),
            ],
            rows: widget.products.map((product) {
              return DataRow(
                selected: selectedProducts.contains(product),
                onSelectChanged: (selected) =>
                    _onSelectedRow(selected!, product),
                cells: [
                  DataCell(Text(product.name)),
                  DataCell(Text(product.buyingPrice.toString())),
                  DataCell(Text(product.sellingPrice.toString())),
                  DataCell(Text(product.uom!)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
