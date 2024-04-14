import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../providers/db.dart';

class AddShopPage extends StatelessWidget {
  final TextEditingController _shopController = TextEditingController();

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
        title: Text('Add Shop'),
        // Adding a back button to the app bar
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(
                context, '/home'); // Navigate back to previous screen
          },
        ),
      ),
      body: Container(
        color: Color(0xFF737373),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10.0),
              topRight: const Radius.circular(10.0),
            ),
          ),
          child: Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: TextField(
                  controller: _shopController,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Shop Name",
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.black54,
                    ),
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                  ),
                ),
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
                            _shopController.clear();
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
                            if (_shopController.text.isNotEmpty) {
                              dbService
                                  .addShop(
                                _shopController.text,
                              )
                                  .then((_) {
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                                _shopController.clear();
                              }).catchError((error) {
                                if (error.toString().contains("NOINTERNET")) {
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
      ),
    );
  }
}
