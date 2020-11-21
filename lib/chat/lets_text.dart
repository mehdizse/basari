import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:basari/chat/chat_screen.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors/sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LetsChat extends StatefulWidget {
  @override
  _LetsChatState createState() => _LetsChatState();
}
enum TtsState { playing, stopped, paused, continued }

class _LetsChatState extends State<LetsChat> with AfterLayoutMixin<LetsChat> {

  List<Contact> contacts = [];
  bool lecture=false;
  List<Contact> contactsFiltered = [];
  Map<String, Color> contactsColorMap = new Map();
  TextEditingController searchController = new TextEditingController();
  FlutterTts flutterTts;
  dynamic ttsState;
  List<double> _userAccelerometerValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions = <StreamSubscription<dynamic>>[];
  String id = "";
  double x1=0.0,y1=0.0,z1=0.0;
  double x2=0.0,y2=0.0,z2=0.0;
  List<String> data = [];
  int initPosition = 0;
  TabController _controller;
  int i=1;

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen1 = (prefs.getBool('seen1') ?? false);

    if (_seen1) {

      //is there away to block any interactions until the audio finishes
      // intro to home audio
    } else {
      await prefs.setBool('seen1', true);
      _speak(
          ' مرحبا بك في صفحة الرسائل. تستطيع عبر هذه الصفحة إرْسَال رسائل كتابية عن طريق تقنية طورناها خصيصا من أَجَلِك. تحتوي صفحة الرسائل على قائمة مُتَّصِلِيِك . قم بحركة سحب أُفُقِيَّة للتنقل بين االْمُتَّصِلِيِن . قم بالضغط مرة واحدة في الشاشة و سنقرأ لك الاسم كل مرة  ْ،اذا اردت ارسال رسالة لمتصل معين يكفي ان تنقر عليه مرتين و ستدخل الى شاشة المحادثة التي سنشرحها لاحقا. في حالة ما اذا وصلتك رسائل صوتية، سوف نعلمك بها و كيف يمكنك اللجوء اليها لاحقا. ْ');

      //home audio(simple hello)
    }
  }


  @override
  void initState() {
    initTts();
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      id = prefs.getString('id') ?? '';
      if (id != '') {
        if (await Permission.contacts
            .request()
            .isGranted) {
          getAllContacts();
        }
      }
    });

    super.initState();
  }

  initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ar");
    flutterTts.setSpeechRate(0.72);
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

  Future _speake(String word) async {
    await flutterTts.awaitSpeakCompletion(true);
    if (lecture) {
      var result = flutterTts.stop();
    }else {
      var result = flutterTts.speak(word);
    }
    setState(() {
      lecture=!lecture;
    });

  }

  Future _speak(String word) async {
    await flutterTts.awaitSpeakCompletion(true);
    if (ttsState==TtsState.playing) {
      var result = await flutterTts.stop();
      if (result == 1) {
        print(result);
        setState(() {
          ttsState = TtsState.stopped;
        });
        await new Future.delayed(const Duration(seconds : 1));
        _speak(word);
      }

    }else {
      await flutterTts.speak(word);
    }

  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  getAllContacts() async {
    List colors = [
      Colors.green,
      Colors.indigo,
      Colors.yellow,
      Colors.orange
    ];
    int colorIndex = 0;
    List<Contact> _contacts = (await ContactsService.getContacts()).toList();
    _contacts.forEach((contact) {
      Color baseColor = colors[colorIndex];
      contactsColorMap[contact.displayName] = baseColor;
      colorIndex++;
      if (colorIndex == colors.length) {
        colorIndex = 0;
      }
    });
    setState(() {
      contacts = _contacts;
    });
  }



  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();
    x2=x1;
    y2=y1;
    z2=z1;
    if(_userAccelerometerValues!=null){
      x1=_userAccelerometerValues[0];
      y1=_userAccelerometerValues[1];
      z1=_userAccelerometerValues[2];
    }

    if(i==1){
      if(x2-x1>3.5 || y2-y1>3.5){
        _speake("اِسحَب عمودياً للتنقل بين المتصلين. اٌنقُر مرة للحصول على معلومات المتصل و معرفة عدد الرسائل. و قم بالنقر مرتين للدخول لصفحة المحادثة.  ");
      }
    }

     return Scaffold(
        body: SafeArea(
          child: CustomTabView(
            initPosition: initPosition,
            itemCount: contacts.length,
            tabBuilder: (context, index) => Tab(text: data[index]),
            pageBuilder: (context, index) {
              Contact contact = contacts[index];
              var baseColor = contactsColorMap[contact.displayName] as dynamic;
              Color color1 = baseColor[800];
              Color color2 = baseColor[400];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.grey,
                  child: GestureDetector(
                      onDoubleTap: (){
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => ChatScreen(receiver: contact.phones.elementAt(0).value,sender: id,)),
                          );
                          i=0;
                     },
                    child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      onTap: (){
                        _speak(contact.displayName+" رقم الهاتف "+contact.phones.elementAt(0).value);
                      },
                      onLongPress: (){
                        print("Long press");
                      },
                    title: Text(contact.displayName),
                    subtitle: Text(
                    contact.phones.length > 0 ? contact.phones
                                  .elementAt(0)
                                  .value : ''
                          ),
                          leading: (contact.avatar != null && contact.avatar.length > 0) ?
                          CircleAvatar(
                            backgroundImage: MemoryImage(contact.avatar),
                          ) :
                          Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                      colors: [
                                        color1,
                                        color2,
                                      ],
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight
                                  )
                              ),
                              child: CircleAvatar(
                                  child: Text(
                                      contact.initials(),
                                      style: TextStyle(
                                          color: Colors.white
                                      )
                                  ),
                                  backgroundColor: Colors.transparent
                              )
                          )
                      ),
                    ),
            ),
                ),
              );
          },
            onPositionChange: (index){
              print('current position: $index');
              initPosition = index;
            },
            onScroll: (position) => print('$position'),
          ),
        ),
    );
  }
}



class CustomTabView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder tabBuilder;
  final IndexedWidgetBuilder pageBuilder;
  final Widget stub;
  final ValueChanged<int> onPositionChange;
  final ValueChanged<double> onScroll;
  final int initPosition;

  CustomTabView({
    @required this.itemCount,
    @required this.tabBuilder,
    @required this.pageBuilder,
    this.stub,
    this.onPositionChange,
    this.onScroll,
    this.initPosition,
  });

  @override
  _CustomTabsState createState() => _CustomTabsState();
}

class _CustomTabsState extends State<CustomTabView> with TickerProviderStateMixin {
  TabController controller;
  int _currentCount;
  int _currentPosition;
  List<String> data = [];
  int initPosition = 1;

  @override
  void initState() {
    _currentPosition = widget.initPosition ?? 0;
    controller = TabController(
      length: widget.itemCount,
      vsync: this,
      initialIndex: _currentPosition,
    );
    controller.addListener(onPositionChange);
    controller.animation.addListener(onScroll);
    _currentCount = widget.itemCount;
    super.initState();
  }


  @override
  void didUpdateWidget(CustomTabView oldWidget) {
    if (_currentCount != widget.itemCount) {
      controller.animation.removeListener(onScroll);
      controller.removeListener(onPositionChange);
      controller.dispose();

      if (widget.initPosition != null) {
        _currentPosition = widget.initPosition;
      }

      if (_currentPosition > widget.itemCount - 1) {
        _currentPosition = widget.itemCount - 1;
        _currentPosition = _currentPosition < 0 ? 0 :
        _currentPosition;
        if (widget.onPositionChange is ValueChanged<int>) {
          WidgetsBinding.instance.addPostFrameCallback((_){
            if(mounted) {
              widget.onPositionChange(_currentPosition);
            }
          });
        }
      }

      _currentCount = widget.itemCount;
      setState(() {
        controller = TabController(
          length: widget.itemCount,
          vsync: this,
          initialIndex: _currentPosition,
        );
        controller.addListener(onPositionChange);
        controller.animation.addListener(onScroll);
      });
    } else if (widget.initPosition != null) {
      controller.animateTo(widget.initPosition);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.animation.removeListener(onScroll);
    controller.removeListener(onPositionChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount < 1) return widget.stub ?? Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: TabBarView(
            controller: controller,
            children: List.generate(
              widget.itemCount,
                  (index) => widget.pageBuilder(context, index),
            ),
          ),
        ),
      ],
    );
  }

  onPositionChange() {
    if (!controller.indexIsChanging) {
      _currentPosition = controller.index;
      if (widget.onPositionChange is ValueChanged<int>) {
        widget.onPositionChange(_currentPosition);
      }
    }
  }

  onScroll() {
    if (widget.onScroll is ValueChanged<double>) {
      widget.onScroll(controller.animation.value);
    }
  }
}