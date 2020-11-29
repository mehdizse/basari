import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:basari/chat_screen.dart';
import 'package:battery/battery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'vision.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/weather.dart';

import 'Generalinfo.dart';

class HomeScreenSplash extends StatefulWidget {
  @override
  _HomeScreenSplashState createState() => _HomeScreenSplashState();
}

class _HomeScreenSplashState extends State<HomeScreenSplash>
    with AfterLayoutMixin<HomeScreenSplash> {
  initState() {
    super.initState();
    initTts();
  }

  bool check = false;
  FlutterTts flutterTts;

  dynamic ttsState;

  initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ar");
    flutterTts.setStartHandler(() {
      setState(() {
        print("playing");
        ttsState = TtsState.playing;
      });
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });
    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _speak(String word) async {
    await flutterTts.awaitSpeakCompletion(true);
    if (ttsState == TtsState.playing) {
      var result = await flutterTts.stop();
      if (result == 1) {
        print(result);
        setState(() {
          ttsState = TtsState.stopped;
          check = true;
        });
        await new Future.delayed(const Duration(seconds: 1));
        _speak(word);
      }
    } else {
      await flutterTts.speak(word);
    }
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen1 = (prefs.getBool('seen1') ?? false);

    if (_seen1) {
      prefs.remove('seen1');
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new Home()));
    } else {
      await prefs.setBool('seen1', true);
      _speak(
          'رائعْ. لقد اَتْمَمْتَ كُلَّ الحَرَكَاتْ. و انت الان جاهزُ للذهاب الى الصفحةِ الرئيسيةْ.مرحبا بك في الصفحة الرئيسية. من هنا يمكنك الدخول لباقي صفحات التطبيقْ, عن طريق الحركات التي تعلمناها سابقا. اِسحَب عمودياً لدخول صفحة الثقافة العامةْ. وأُفُقِيًا لدخول صفحة الترفيه. أخيرا، قم بالنقر مُطوَّلاً لدخول صفحة الرسائل. يمكنك دائما العودة الى الصفحة الرئيسية بالنقر مرتين اَينما كنت. وللحصول على معلومات عن الجو والوقت وغيرها، اٌنقُر مرة في الصفحة الرئيسية. لا تَقْلَقْ في حال ما نَسيتَ كل هذه المَعلوماتْ، قم بهز الهَاتِفَ و سَنُذَكِّرُكَ بِهَا');

      Timer(Duration(seconds: 45), () {
        Navigator.of(context).pushReplacement(
            new MaterialPageRoute(builder: (context) => new Home()));
      });
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
    );
  }
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

enum TtsState {
  playing,
  stopped,
}

class HomeState extends State<Home> {
  FlutterTts flutterTts;

  dynamic ttsState;

  initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ar");
    flutterTts.setStartHandler(() {
      setState(() {
        print("playing");
        ttsState = TtsState.playing;
      });
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });
    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _speak(String word) async {
    await flutterTts.awaitSpeakCompletion(true);
    if (ttsState == TtsState.playing) {
      var result = await flutterTts.stop();
      if (result == 1) {
        print(result);
        setState(() {
          ttsState = TtsState.stopped;
          check = true;
        });
        await new Future.delayed(const Duration(seconds: 1));
        _speak(word);
      }
    } else {
      await flutterTts.speak(word);
    }
  }

  Weather w;
  WeatherFactory wf = new WeatherFactory("0159a72be3ed85ab99edbdc94dda553e",
      language: Language.ARABIC);
  final Battery _battery = Battery();
  int _batteryLevel;

  bool check = true;
  String time;
  ShakeDetector detector;
  @override
  initState() {
    super.initState();
    detector = ShakeDetector.autoStart(
        shakeThresholdGravity: 2.5,
        onPhoneShake: () {
          _speak(
              'اِسحَب عمودياً لدخول صفحة الثقافة العامةْ. وأُفُقِيًا لدخول صفحة الترفيه.  قم بالنقر مُطوَّلاً لدخول صفحة الرسائل. و اٌنقُر مرة للحصول على معلومات عن الجو والوقت وغيرها');

          print('shake home');
        });
    initPW();
    initTts();

    _speak('الصفحة الرئيسية');
  }

  initPW() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    Weather weather = await wf.currentWeatherByLocation(
        position.latitude, position.longitude);
    setState(() {
      w = weather;
    });
  }

  void dispose() {
    super.dispose();
    detector.stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        DateTime dateTime = DateTime.now();

        if (w != null) {
          _speak("الساعة الاَن هي" +
              dateTime.toString().substring(11, 16) +
              "." +
              "مستوى البطارية" +
              "$_batteryLevel" +
              "%" +
              "." +
              "الجو" +
              w.weatherDescription +
              "." +
              "و درجة الحرارة " +
              w.temperature.toString());
          _battery.batteryLevel.then((level) {
            this.setState(() {
              _batteryLevel = level;
            });
          });
        } else {
          _speak("تَأَكَّدْ اَنَّكَ مُتَّصِلٌ بالانترنت. " +
              "الساعة الاَن هي" +
              dateTime.toString().substring(11, 16) +
              "." +
              "مستوى البطارية" +
              "$_batteryLevel" +
              "%" +
              ".");
        }
        initPW();
      },
      onDoubleTap: () {
        _speak('الصفحة الرئيسية');
      },
      onLongPress: () {
        _speak('الرسائل');
        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => ChatScreen()));
        });
      },
      onHorizontalDragStart: (DragStartDetails details) {},
      onHorizontalDragEnd: (DragEndDetails details) {
        _speak('رؤيا');

        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => VSplash()));
        });
      },
      onVerticalDragStart: (DragStartDetails details) {},
      onVerticalDragEnd: (DragEndDetails details) {
        _speak('معلومات عامة');

        Timer(Duration(seconds: 3), () {
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => GISplash()));
        });
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Align(
          alignment: Alignment.center,
          child: Scaffold(),
        ),
      ),
    );
  }
}
