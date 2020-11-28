import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier, VoidCallback;
import 'package:flutter/widgets.dart' show TextEditingController;
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase/auth/auth.dart';

enum PhoneAuthState {
  Started,
  CodeSent,
  CodeResent,
  Verified,
  Failed,
  Error,
  AutoRetrievalTimeOut
}

class PhoneAuthDataProvider with ChangeNotifier {
  VoidCallback onStarted,
      onCodeSent,
      onCodeResent,
      onVerified,
      onFailed,
      onError,
      onAutoRetrievalTimeout;

  bool _loading = false;

  final TextEditingController _phoneNumberController = TextEditingController();

  PhoneAuthState _status;
  var _authCredential;
  String _actualCode;
  String _phone, _message;

  setMethods(
      {VoidCallback onStarted,
      VoidCallback onCodeSent,
      VoidCallback onCodeResent,
      VoidCallback onVerified,
      VoidCallback onFailed,
      VoidCallback onError,
      VoidCallback onAutoRetrievalTimeout}) {
    this.onStarted = onStarted;
    this.onCodeSent = onCodeSent;
    this.onCodeResent = onCodeResent;
    this.onVerified = onVerified;
    this.onFailed = onFailed;
    this.onError = onError;
    this.onAutoRetrievalTimeout = onAutoRetrievalTimeout;
  }

  Future<bool> instantiate(
      {String dialCode,
      VoidCallback onStarted,
      VoidCallback onCodeSent,
      VoidCallback onCodeResent,
      VoidCallback onVerified,
      VoidCallback onFailed,
      VoidCallback onError,
      VoidCallback onAutoRetrievalTimeout}) async {
    this.onStarted = onStarted;
    this.onCodeSent = onCodeSent;
    this.onCodeResent = onCodeResent;
    this.onVerified = onVerified;
    this.onFailed = onFailed;
    this.onError = onError;
    this.onAutoRetrievalTimeout = onAutoRetrievalTimeout;
    if (phoneNumberController.text.length < 9) {
      return false;
    }
    phone = dialCode + phoneNumberController.text;
    print(phone);
    _startAuth();
    return true;
  }

  _startAuth() async {
    await Firebase.initializeApp();
    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      actualCode = verificationId;
      _addStatusMessage("\nEnter the code sent to " + phone);
      _addStatus(PhoneAuthState.CodeSent);
      if (onCodeSent != null) onCodeSent();
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      actualCode = verificationId;
      _addStatusMessage("\nانتهاء وقت تسجيل الدخول ");
      _addStatus(PhoneAuthState.AutoRetrievalTimeOut);
      if (onAutoRetrievalTimeout != null) onAutoRetrievalTimeout();
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      _addStatusMessage('${authException.message}');
      _addStatus(PhoneAuthState.Failed);
      if (onFailed != null) onFailed();
      if (authException.message.contains('not authorized'))
        _addStatusMessage('تطبيق غير مسموح');
      else if (authException.message.contains('Network'))
        _addStatusMessage(
            'يرجى التحقق من اتصالك بالإنترنت وحاول مرة أخرى');
      else
        _addStatusMessage('حدث خطأ ما ، يرجى المحاولة لاحقًا' );
    };

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential auth) {
      _addStatusMessage('Auto retrieving verification code');

      FireBase.auth.signInWithCredential(auth).then((UserCredential value) {
        if (value.user != null) {
          _addStatusMessage('تم تسجيل الدخول بنجاح');
          _addStatus(PhoneAuthState.Verified);
          if (onVerified != null) onVerified();
        } else {
          if (onFailed != null) onFailed();
          _addStatus(PhoneAuthState.Failed);
          _addStatusMessage('كلمة السر خاطئة او خطا في تسجيل الدخول');
        }
      }).catchError((error) {
        if (onError != null) onError();
        _addStatus(PhoneAuthState.Error);
        _addStatusMessage('حدث خطأ ما ، يرجى المحاولة لاحقًا');
      });
    };

    _addStatusMessage('بدا تسجيل الدخول');
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth
        .verifyPhoneNumber(
            phoneNumber: phone.toString(),
            timeout: Duration(seconds: 60),
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: codeAutoRetrievalTimeout)
        .then((value) {
      if (onCodeSent != null) onCodeSent();
      _addStatus(PhoneAuthState.CodeSent);
      _addStatusMessage('Code sent');
    }).catchError((error) {
      if (onError != null) onError();
      _addStatus(PhoneAuthState.Error);
      _addStatusMessage(error.toString());
    });
  }

  void verifyOTPAndLogin({String smsCode}) async {
    _authCredential = PhoneAuthProvider.credential(
        verificationId: actualCode, smsCode: smsCode);

    FirebaseAuth _auth = FirebaseAuth.instance;

        _auth.signInWithCredential(_authCredential)
          .then((UserCredential result) async {
      _addStatusMessage('تسجيل الدخول بنجاح');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('id', "${result.user.uid}");
      _addStatus(PhoneAuthState.Verified);
      if (onVerified != null) onVerified();
    }).catchError((error) {
      if (onError != null) onError();
      _addStatus(PhoneAuthState.Error);
      _addStatusMessage(
          'حدث خطأ ما ، يرجى المحاولة لاحقًا');
    });
  }

  _addStatus(PhoneAuthState state) {
    status = state;
  }

  void _addStatusMessage(String s) {
    message = s;
  }

  get authCredential => _authCredential;

  set authCredential(value) {
    _authCredential = value;
    notifyListeners();
  }

  get actualCode => _actualCode;

  set actualCode(String value) {
    _actualCode = value;
    notifyListeners();
  }

  get phone => _phone;

  set phone(String value) {
    _phone = value;
    notifyListeners();
  }

  get message => _message;

  set message(String value) {
    _message = value;
    notifyListeners();
  }

  PhoneAuthState get status => _status;

  set status(PhoneAuthState value) {
    _status = value;
    notifyListeners();
  }

  bool get loading => _loading;

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  TextEditingController get phoneNumberController => _phoneNumberController;
}
