import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'package:shake/shake.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash> with AfterLayoutMixin<Splash> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new ShakeCheck()));
    } else {
      await prefs.setBool('seen', true);

      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new HorizontalCheck()));
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black,
      body: new Center(
        child: new Text('Loading...'),
      ),
    );
  }
}

class HorizontalCheck extends StatefulWidget {
  @override
  _HorizontalCheckState createState() => _HorizontalCheckState();
}

enum TtsState {
  playing,
  stopped,
}

class _HorizontalCheckState extends State<HorizontalCheck> {
  FlutterTts flutterTts;

  dynamic ttsState;
  bool check = false;
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
    _speak(
        'ْمرحبا بك في تطبيق مدى،قبل ان تبدأ باستعمال التطبيق عليك تعلم كيفية استخدامه. هذا التطبيق مُعَدُّ خصيصا للمكفوفين و ضعيفِي البصر. سيسمح لك هذا التطبيق بالقيام بعدة اشياء ممتعة و سيساهم في تنمية ذاكرتك.  لنتعلم بعض الحركات التي ستسمح لك باستخدامه. هل انت جاهز؟. هيا بنا. اول حركَ. السَّحبُ الاُفُقِيْ.  ضع اٌصْبُعَكَ يمين الشاشة و اِسْحَبْ الى اليسار، اَوْ العكس');
  }

  Future _speak(String word) async {
    await flutterTts.awaitSpeakCompletion(true);
    if (ttsState == TtsState.playing) {
      var result = await flutterTts.stop();
      if (result == 1) {
        print(result);
        setState(() {
          ttsState = TtsState.stopped;
        });
        await new Future.delayed(const Duration(seconds: 1));
        _speak(word);
      }
    } else {
      await flutterTts.speak(word);
    }
  }

  @override
  void initState() {
    super.initState();
    initTts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        print('start horizontal drag');
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (ttsState == TtsState.stopped) {
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => new VerticalCheck()));
        } else {
          print('not yet');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
      ),
    );
  }
}

class VerticalCheck extends StatefulWidget {
  @override
  _VerticalCheckState createState() => _VerticalCheckState();
}

class _VerticalCheckState extends State<VerticalCheck> {
  FlutterTts flutterTts;

  dynamic ttsState;
  bool check = false;
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
    _speak(
        ' اَحْسَنْت. الحركة الثانية . السَّحْبُ العمودِيُّ.  ضع اُصْبُعَكَ اسفل الشاشة و اِسْحَبْ اِلَى الاَعلى، اَوْ العكس');
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

  @override
  void initState() {
    super.initState();
    initTts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        print('start horizontal drag');
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        print('update');
      },
      onVerticalDragStart: (DragStartDetails details) {
        print('start vertical drag');
      },
      onVerticalDragEnd: (DragEndDetails details) {
        if (ttsState == TtsState.stopped) {
          Navigator.of(context).pushReplacement(new MaterialPageRoute(
              builder: (context) => new LongPressCheck()));
        } else {
          print('not yet');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
      ),
    );
  }
}

class LongPressCheck extends StatefulWidget {
  @override
  _LongPressCheckState createState() => _LongPressCheckState();
}

class _LongPressCheckState extends State<LongPressCheck> {
  FlutterTts flutterTts;

  dynamic ttsState;
  bool check = false;
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
    _speak(
        ' رَائِع. الحركة الثالثة . النقر مُطَوَّلاً.  انقر مُطَوَّلاً في اي مكان في الشاشة');
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

  @override
  void initState() {
    super.initState();
    initTts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      onDoubleTap: () {},
      onLongPressStart: (LongPressStartDetails details) {
        print('long press start');
      },
      onLongPressEnd: (LongPressEndDetails details) {
        if (ttsState == TtsState.stopped) {
          Navigator.of(context).pushReplacement(new MaterialPageRoute(
              builder: (context) => new DoubleTapCheck()));
        } else {
          print('not yet');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
      ),
    );
  }
}

class DoubleTapCheck extends StatefulWidget {
  @override
  _DoubleTapCheckState createState() => _DoubleTapCheckState();
}

class _DoubleTapCheckState extends State<DoubleTapCheck> {
  FlutterTts flutterTts;

  dynamic ttsState;
  bool check = false;
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
    _speak(
        'جيد جدا. الحركة الرابعة . النقر مرتين.  انقر مرتين في اي مكان في الشاشة');
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

  @override
  void initState() {
    super.initState();
    initTts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        if (ttsState == TtsState.stopped) {
          print('oudbletap');
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => new TapCheck()));
        } else {
          print('not yet');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
      ),
    );
  }
}

class TapCheck extends StatefulWidget {
  @override
  _TapCheckState createState() => _TapCheckState();
}

class _TapCheckState extends State<TapCheck> {
  FlutterTts flutterTts;

  dynamic ttsState;
  bool check = false;
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
    _speak('عمل جيدْ. الحركة الخامسة. نَقْرَة.  انقر مرة في اي مكان في الشاشة');
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

  @override
  void initState() {
    super.initState();
    initTts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (ttsState == TtsState.stopped) {
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => new ShakeCheck()));
        } else {
          print('not yet');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
      ),
    );
  }
}

class ShakeCheck extends StatefulWidget {
  @override
  _ShakeCheckState createState() => _ShakeCheckState();
}

class _ShakeCheckState extends State<ShakeCheck> {
  FlutterTts flutterTts;

  dynamic ttsState;
  bool check = false;
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
    _speak(
        'رائعْ. تَبَقَّتْ حَرَكَةٌ واحدةْ. الحركة الاََخِيرَةُ. هَزُّ الهاتِفِ. قم بِهَزِّ الهاتف قَلِيلاً عاموديًّا او اُفُقِيَّا ');
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

  ShakeDetector detector;
  @override
  void initState() {
    super.initState();
    detector = ShakeDetector.autoStart(
        shakeThresholdGravity: 1.7,
        onPhoneShake: () {
          if (ttsState == TtsState.stopped) {
            Navigator.of(context).pushReplacement(new MaterialPageRoute(
                builder: (context) => new HomeScreenSplash()));
          } else {
            print('not yet');
          }
        });
    initTts();
  }

  @override
  void dispose() {
    super.dispose();
    detector.stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
