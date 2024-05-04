import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/db.dart';
import '../providers/auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late double monthsales;
  late double monthwaste;
  Map<String, dynamic> user = {};

  @override
  void initState() {
    monthsales = 0;
    monthwaste = 0;
    getUser();

    dbService.monthsales.listen((sales) {
      sales.forEach((sale) {
        setState(() {
          monthsales += sale.product!.sellingPrice - sale.product!.buyingPrice;
        });
      });
    });
    dbService.monthwaste.listen((waste) {
      waste.forEach((wasted) {
        setState(() {
          monthwaste +=
              wasted.product!.sellingPrice - wasted.product!.buyingPrice;
        });
      });
    });

    super.initState();
  }

  void showToast(String message) {
    HapticFeedback.vibrate();
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
        title: const Text('Profile'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            user.containsKey("username")
                ? Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.person,
                        size: 50.0,
                      ),
                      title: Text(user["username"]),
                      subtitle: Text(user["email"]),
                      trailing: IconButton(
                        icon: Icon(Icons.exit_to_app),
                        tooltip: "Logout",
                        onPressed: () {
                          authService.logout().then((_) {
                            Navigator.pushReplacementNamed(context, "/login");
                          }).catchError((error) {
                            if (error.toString().contains("NOINTERNET")) {
                              showToast("You dont have an internet connection");
                            } else {
                              print(error);
                              showToast("Something is wrong");
                            }
                          });
                        },
                      ),
                    ),
                  )
                : Card(
                    child: ListTile(
                      leading: Shimmer.fromColors(
                        baseColor: Colors.black12,
                        highlightColor: Colors.black26,
                        child: Container(
                          height: 20.0,
                          width: 20.0,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                          ),
                        ),
                      ),
                      title: Shimmer.fromColors(
                        baseColor: Colors.black12,
                        highlightColor: Colors.black26,
                        child: Container(
                          height: 10.0,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                          ),
                        ),
                      ),
                      subtitle: Shimmer.fromColors(
                        baseColor: Colors.black12,
                        highlightColor: Colors.black26,
                        child: Container(
                          height: 10.0,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                          ),
                        ),
                      ),
                      trailing: Shimmer.fromColors(
                        baseColor: Colors.black12,
                        highlightColor: Colors.black26,
                        child: Container(
                          height: 20.0,
                          width: 20.0,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
            Card(
              child: ListTile(
                title: Text('Sales this month'),
                trailing: AnimatedDefaultTextStyle(
                  child: Text("GHC ${monthsales.toString()}"),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Waste this month'),
                trailing: AnimatedDefaultTextStyle(
                  child: Text("GHC ${monthwaste.toString()}"),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Profit margin'),
                trailing: AnimatedDefaultTextStyle(
                  child: Text("GHC ${(monthsales - monthwaste).toString()}"),
                  style: monthsales > monthwaste
                      ? TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )
                      : TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getUser() async {
    var _user = await dbService.getCurrentUser();
    if (mounted)
      setState(() {
        user = _user;
      });
  }
}
