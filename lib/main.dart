import 'package:flutter/material.dart';
import 'package:web_verde/model/admin_model.dart';
import 'package:web_verde/src/pages/home_page.dart';
import 'package:web_verde/src/pages/login_page.dart';
import 'package:web_verde/src/pages/newPassword_page.dart';
import 'package:web_verde/src/service/sharedPref.dart';
import 'package:web_verde/src/service/verde_service.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPrefs.init();
  VerdeService verdeService = VerdeService();
  AdminModel adminModel = AdminModel();
  String navHome = '/login';
  WidgetsFlutterBinding.ensureInitialized();
  dynamic clientToken = sharedPrefs.clientToken;

  bool tokenClient = clientToken != "" ? true : false;

  if (tokenClient) {
    navHome = '/home';
    // var jsonUser = jsonDecode(sharedPrefs.clientData);
    // adminModel = AdminModel.fromJson(jsonUser);

  }

  initializeDateFormatting().then((_) => runApp(MyApp()));
  runApp(MyApp(
    nav: navHome,
  ));
}

class MyApp extends StatefulWidget {
  final String nav;

  MyApp({Key key, this.nav}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var correo;
  var token;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Merkado Verde',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        onGenerateRoute: (settings) {
          var uri = Uri.parse(settings.name);
          if (uri.pathSegments.length == 3 &&
              uri.pathSegments.first == 'restore-password') {
            var mail = uri.pathSegments[1];
            var token = uri.pathSegments[2];
            return MaterialPageRoute(
                builder: (context) => PasswordPage(
                      mail: mail,
                      token: token,
                    ));
          }
          return MaterialPageRoute(builder: (context) => LoginPage());
        },
        // restore-password?correo=andrea.balabox%40gmail.com&token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2MTQwMjY4NjksImV4cCI6MTYxNDAzMDQ2OX0.UGj3XGwTq8NqRpEcEcWJJmq_dFwE-6Vsl1-ih5C11K4
        initialRoute: widget.nav,
        routes: {
          "/login": (context) => LoginPage(),
          "/home": (context) => HomePage(),
        });
  }
}
