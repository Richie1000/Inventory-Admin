import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:rxdart/subjects.dart';

Connection connectionService = Connection();

class Connection {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  final connected = BehaviorSubject<bool>();

  Connection() {
    hasInternet();
  }

  void hasInternet() {
    try {
      _subscription = Connectivity().onConnectivityChanged.listen(
        (List<ConnectivityResult> results) async {
          var connectivityResult = results.first;
          if (connectivityResult != ConnectivityResult.none) {
            connected.add(await InternetConnectionChecker().hasConnection);
          } else {
            connected.add(false);
          }
        },
      );
    } catch (e) {
      print("-------------------------");
      print("error connection.dart 27");
      print(e);
      throw e;
    }
  }

  void dispose() {
    _subscription.cancel();
    connected.close();
  }
}
