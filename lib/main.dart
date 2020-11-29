import 'package:permission_handler/permission_handler.dart';
import 'Demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {




    @override
  void initState(){
    WidgetsBinding.instance.addPostFrameCallback((_) async {
        Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.locationAlways,
      ].request();
      print(statuses[Permission.location]);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basari',
      localizationsDelegates: [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
          supportedLocales: [
            Locale("ar", "AE"), // OR Locale('ar', 'AE') OR Other RTL locales
          ],
          locale: Locale("ar", "AE"),
      theme: ThemeData(),
      home: Splash(),
    );
  }
}

