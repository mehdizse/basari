import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:basari/chat/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors/sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactScreen extends StatefulWidget {

  @override
  _ContactScreenState createState() => _ContactScreenState();
}
enum TtsState { playing, stopped, paused, continued }

class _ContactScreenState extends State<ContactScreen> with AfterLayoutMixin<ContactScreen> {

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
  String r="";
  var list=[];
  var messages=[];
  List<String> phone=[];
  Map<String,String> values={};
  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  final databaseReference = FirebaseFirestore.instance;
  List<String> person=[];
  bool lect=true;
  List<String> telephoneTrouve=[];
  List<String> allTelephone=[];
  RegExp regExp = new RegExp(
    r"\+(?:998|996|995|994|993|992|977|976|975|974|973|972|971|970|968|967|966|965|964|963|962|961|960|886|880|856|855|853|852|850|692|691|690|689|688|687|686|685|683|682|681|680|679|678|677|676|675|674|673|672|670|599|598|597|595|593|592|591|590|509|508|507|506|505|504|503|502|501|500|423|421|420|389|387|386|385|383|382|381|380|379|378|377|376|375|374|373|372|371|370|359|358|357|356|355|354|353|352|351|350|299|298|297|291|290|269|268|267|266|265|264|263|262|261|260|258|257|256|255|254|253|252|251|250|249|248|246|245|244|243|242|241|240|239|238|237|236|235|234|233|232|231|230|229|228|227|226|225|224|223|222|221|220|218|216|213|212|211|98|95|94|93|92|91|90|86|84|82|81|66|65|64|63|62|61|60|58|57|56|55|54|53|52|51|49|48|47|46|45|44\D?1624|44\D?1534|44\D?1481|44|43|41|40|39|36|34|33|32|31|30|27|20|7|1\D?939|1\D?876|1\D?869|1\D?868|1\D?849|1\D?829|1\D?809|1\D?787|1\D?784|1\D?767|1\D?758|1\D?721|1\D?684|1\D?671|1\D?670|1\D?664|1\D?649|1\D?473|1\D?441|1\D?345|1\D?340|1\D?284|1\D?268|1\D?264|1\D?246|1\D?242|1)\D?",
    caseSensitive: false,
    multiLine: false,
  );


  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen1 = (prefs.getBool('seen1') ?? false);
    print(_seen1);
    if (_seen1) {

      //is there away to block any interactions until the audio finishes
      // intro to home audio
    } else {
      await prefs.setBool('seen1', true);
      _speak(
          ' مرحبا بك في صفحة الرسائل. تستطيع عبر هذه الصفحة إرْسَال رسائل كتابية عن طريق تقنية طورناها خصيصا من أَجَلِك. تحتوي صفحة الرسائل على قائمة مُتَّصِلِيِك . قم بحركة سحب أُفُقِيَّة للتنقل بين االْمُتَّصِلِيِن . قم بالضغط مرة واحدة في الشاشة و سنقرأ لك الاسم كل مرة  ْ،اذا اردت ارسال رسالة لمتصل معين يكفي ان تنقر عليه مرتين و ستدخل الى شاشة المحادثة التي سنشرحها لاحقا. في حالة ما اذا وصلتك رسائل صوتية، سوف نعلمك بها و كيف يمكنك اللجوء اليها لاحقا. ْ');

    }
  }


  @override
  void initState() {
    RegExp regExp = new RegExp(
      r"\+(?:998|996|995|994|993|992|977|976|975|974|973|972|971|970|968|967|966|965|964|963|962|961|960|886|880|856|855|853|852|850|692|691|690|689|688|687|686|685|683|682|681|680|679|678|677|676|675|674|673|672|670|599|598|597|595|593|592|591|590|509|508|507|506|505|504|503|502|501|500|423|421|420|389|387|386|385|383|382|381|380|379|378|377|376|375|374|373|372|371|370|359|358|357|356|355|354|353|352|351|350|299|298|297|291|290|269|268|267|266|265|264|263|262|261|260|258|257|256|255|254|253|252|251|250|249|248|246|245|244|243|242|241|240|239|238|237|236|235|234|233|232|231|230|229|228|227|226|225|224|223|222|221|220|218|216|213|212|211|98|95|94|93|92|91|90|86|84|82|81|66|65|64|63|62|61|60|58|57|56|55|54|53|52|51|49|48|47|46|45|44\D?1624|44\D?1534|44\D?1481|44|43|41|40|39|36|34|33|32|31|30|27|20|7|1\D?939|1\D?876|1\D?869|1\D?868|1\D?849|1\D?829|1\D?809|1\D?787|1\D?784|1\D?767|1\D?758|1\D?721|1\D?684|1\D?671|1\D?670|1\D?664|1\D?649|1\D?473|1\D?441|1\D?345|1\D?340|1\D?284|1\D?268|1\D?264|1\D?246|1\D?242|1)\D?",
      caseSensitive: false,
      multiLine: false,
    );
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
      print(id);
      if (id != '') {
        if (await Permission.contacts
            .request()
            .isGranted) {
          await getAllContacts();
        }
      }
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("users").get();
        list = querySnapshot.docs;
      await databaseReference
            .collection("messages")
            .where('idTo',isEqualTo: id)
            .where('read',isEqualTo: 0)
            .get()
            .then((QuerySnapshot snapshot) {
          snapshot.docs.forEach((f) {
          databaseReference
              .collection("users")
              .where('id',isEqualTo: f.data()['idFrom'])
              .get()
              .then((QuerySnapshot snapshot) {
                snapshot.docs.forEach((s) {
                  print(s.data());
                  if(!allTelephone.contains(s.data()["phone"])){
                      allTelephone.add(s.data()["phone"]);
                  }
                  for(int i=0;i<contacts.length;i++){
                    if(contacts[i].phones.elementAt(0).value.replaceAll(regExp,'').substring(0,1).replaceAll(" ","")=="0"){
                      if(contacts[i].phones.elementAt(0).value.replaceAll(regExp,'').replaceRange(0, 1, '').replaceAll(" ","")==s.data()["phone"].replaceAll(regExp,'')){
                        if(!person.contains(contacts[i].givenName+" "+contacts[i].familyName)){
                          setState(() {
                            person.add(contacts[i].givenName+" "+contacts[i].familyName);
                            telephoneTrouve.add(s.data()["phone"]);
                          });
                        }
                      }
                    }else{
                      if(contacts[i].phones.elementAt(0).value.replaceAll(regExp,'').replaceAll(" ","")==s.data()["phone"].replaceAll(regExp,'')){
                        if(!person.contains(contacts[i].givenName+" "+contacts[i].familyName)){
                          setState(() {
                            person.add(contacts[i].givenName+" "+contacts[i].familyName);
                            telephoneTrouve.add(s.data()["phone"]);
                          });
                        }
                      }
                    }
                  }

                });
          });

        });
      });
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          var a = querySnapshot.docs[i];
          String ph=a.data()["phone"];
          setState(() {
            phone.add(ph.replaceAll(regExp,''));
            values[ph.replaceAll(regExp,'')]=a.id;
          });

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

  Future _speak(String word) async {
    await flutterTts.awaitSpeakCompletion(true);
    if (ttsState==TtsState.playing) {
      var result = await flutterTts.stop();
      if (result == 1) {
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


  Widget buildListMessage() {
    return Flexible(
      child:  StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
           print("vide");
          } else {
            listMessage.addAll(snapshot.data.documents);
            print(listMessage);
          }
          return Container();
        },
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    if(person!=null && person.length>0 && lect==true){
      List<String> difference = allTelephone.toSet().difference(telephoneTrouve.toSet()).toList();
      for(int i=0;i<person.length;i++){
        if(i==person.length-1 && difference.length==0){
          r = r + person[i] + "";
        }else if(i==person.length&&difference.length>0){
          r = r + person[i] + "  و  ";
        }
        else {
          r = r + person[i] + "  و  ";
        }
      }
      for(int i=0;i<difference.length;i++){
        if(i==difference.length-1){
          r = r + "0" + difference[i].replaceAll(regExp, '') + "";
        }else {
          r = r + "0" + difference[i].replaceAll(regExp, '') + "  و  ";
        }
      }
      _speak("لديك رسائل من"+r);

      lect=false;
    }

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
        _speak("اِسحَب عمودياً للتنقل بين المتصلين. اٌنقُر مرة للحصول على معلومات المتصل و معرفة عدد الرسائل. و قم بالنقر مرتين للدخول لصفحة المحادثة.  ");
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
                    child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      onTap: () async {
                        var result = await flutterTts.stop();
                        if (result == 1) {
                          setState(() {
                            ttsState = TtsState.stopped;
                          });
                        }
                        String nvnum=contact.phones.elementAt(0).value.replaceAll(regExp,'').replaceAll(" ", '');
                        if(nvnum.substring(0,1)=="0"){
                          nvnum=nvnum.replaceRange(0, 1, '');
                        }
                        if(values.keys.contains(nvnum)){
                          print(values[nvnum]);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => ChatScreen(peerId: values[nvnum])),
                          );
                          i=0;
                        }else{
                          _speak("الرقم الَّذِي تريد الحديث معه لا يمتلك التطبيق . يرْجَي تحفيزه لتثبيثه");
                        }

                      },
                      onLongPress: (){
                        allTelephone=[];
                        telephoneTrouve=[];
                        person=[];
                        databaseReference
                            .collection("messages")
                            .where('idTo',isEqualTo: id)
                            .where('read',isEqualTo: 0)
                            .get()
                            .then((QuerySnapshot snapshot) {
                          snapshot.docs.forEach((f) {
                            databaseReference
                                .collection("users")
                                .where('id',isEqualTo: f.data()['idFrom'])
                                .get()
                                .then((QuerySnapshot snapshot) {
                              snapshot.docs.forEach((s) {
                                print(s.data());
                                if(!allTelephone.contains(s.data()["phone"])){
                                  allTelephone.add(s.data()["phone"]);
                                }
                                for(int i=0;i<contacts.length;i++){
                                  if(contacts[i].phones.elementAt(0).value.replaceAll(regExp,'').substring(0,1).replaceAll(" ","")=="0"){
                                    if(contacts[i].phones.elementAt(0).value.replaceAll(regExp,'').replaceRange(0, 1, '').replaceAll(" ","")==s.data()["phone"].replaceAll(regExp,'')){
                                      if(!person.contains(contacts[i].givenName+" "+contacts[i].familyName)){
                                        setState(() {
                                          person.add(contacts[i].givenName+" "+contacts[i].familyName);
                                          telephoneTrouve.add(s.data()["phone"]);
                                        });
                                      }
                                    }
                                  }else{
                                    if(contacts[i].phones.elementAt(0).value.replaceAll(regExp,'').replaceAll(" ","")==s.data()["phone"].replaceAll(regExp,'')){
                                      if(!person.contains(contacts[i].givenName+" "+contacts[i].familyName)){
                                        setState(() {
                                          person.add(contacts[i].givenName+" "+contacts[i].familyName);
                                          telephoneTrouve.add(s.data()["phone"]);
                                        });
                                      }
                                    }
                                  }
                                }

                              });
                            });

                          });
                          List<String> difference = allTelephone.toSet().difference(telephoneTrouve.toSet()).toList();
                          for(int i=0;i<person.length;i++){
                            if(i==person.length-1 && difference.length==0){
                              r = r + person[i] + "";
                            }else if(i==person.length&&difference.length>0){
                              r = r + person[i] + "  و  ";
                            }
                            else {
                              r = r + person[i] + "  و  ";
                            }
                          }
                          for(int i=0;i<difference.length;i++){
                            if(i==difference.length-1){
                              r = r + "0" + difference[i].replaceAll(regExp, '') + "";
                            }else {
                              r = r + "0" + difference[i].replaceAll(regExp, '') + "  و  ";
                            }
                          }
                          print(r);
                          _speak("لديك رسائل من"+r);

                        });
                      },
                    title: Text(contact.displayName),
                    subtitle: Text(
                    contact.phones.length > 0 ? contact.phones.elementAt(0).value : ''
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
              Contact contact = contacts[index];
              _speak(contact.displayName+" رقم الهاتف "+contact.phones.elementAt(0).value);
              initPosition = index;
            },

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

