import 'package:basari/chat/contact_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/countries.dart';
import 'providers/phone_auth.dart';
import 'package:provider/provider.dart';
import 'firebase/auth/phone_auth/get_phone.dart';
import 'dart:io' show Platform;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FireApp());
}

class FireApp extends StatefulWidget {

  @override
  _FireAppState createState() => _FireAppState();
}

class _FireAppState extends State<FireApp> {
  String id="";
  @override
  void initState(){
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        id = prefs.getString('id') ?? '';
      });

      print(id);
      if(id!=''){
        if (await Permission.contacts.request().isGranted) {
          // Either the permission was already granted before or the user just granted it.
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CountryProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PhoneAuthDataProvider(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
          supportedLocales: [
            Locale("ar", "AE"), // OR Locale('ar', 'AE') OR Other RTL locales
          ],
          locale: Locale("ar", "AE"),
          home: id==""?PhoneAuthGetPhone():ContactScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
