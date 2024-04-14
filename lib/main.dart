import 'package:flutter/material.dart';
import 'package:ofm_admin/pages/add_shop.dart';
import './pages/tabs.dart';
import './pages/login.dart';
import './pages/register.dart';
import './pages/splash.dart';
import './pages/verify.dart';
import './providers/db.dart';
import './providers/connection.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    connectionService.connected.listen((connected) {
      print(connected);
    });
    super.initState();
  }

  @override
  void dispose() {
    dbService.dispose();
    connectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (BuildContext context) => SplashScreen(),
        "/login": (BuildContext context) => LoginPage(),
        "/register": (BuildContext context) => RegisterPage(),
        "/verify": (BuildContext context) => VerifyPage(),
        "/home": (BuildContext context) => TabsPage(),
        "/addShopPage": (BuildContext context) => AddShopPage()
      },
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        hintColor: Colors.pinkAccent,
      ),
    );
  }
}
