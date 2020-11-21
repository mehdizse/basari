import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../phone_auth/select_country.dart';
import '../phone_auth/verify.dart';
import '../../../providers/countries.dart';
import '../../../providers/phone_auth.dart';
import 'package:provider/provider.dart';
import '../../../utils/widgets.dart';



class PhoneAuthGetPhone extends StatefulWidget {

  final Color cardBackgroundColor = Color(0xFF6874C2);
  final String logo = "assets/images/eyes.png";
  final String appName = "بصري";

  @override
  _PhoneAuthGetPhoneState createState() => _PhoneAuthGetPhoneState();
}

class _PhoneAuthGetPhoneState extends State<PhoneAuthGetPhone> {

  double _height, _width, _fixedPadding;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final scaffoldKey = GlobalKey<ScaffoldState>(
      debugLabel: "scaffold-get-phone");

  @override
  Widget build(BuildContext context) {

    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _fixedPadding = _height * 0.025;
    final countriesProvider = Provider.of<CountryProvider>(context);
    final loader = Provider
        .of<PhoneAuthDataProvider>(context)
        .loading;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white.withOpacity(0.95),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: SingleChildScrollView(
                child: _getBody(countriesProvider),
              ),
            ),
            loader ? CircularProgressIndicator() : SizedBox()
          ],
        ),
      ),
    );
  }


  Widget _getBody(CountryProvider countriesProvider) =>
      Card(
        color: widget.cardBackgroundColor,
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: SizedBox(
          height: _height * 8 / 10,
          width: _width * 8 / 10,
          child: countriesProvider.countries.length > 0
              ? _getColumnBody(countriesProvider)
              : Center(child: CircularProgressIndicator()),
        ),
      );

  Widget _getColumnBody(CountryProvider countriesProvider) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          //  Logo: scaling to occupy 2 parts of 10 in the whole height of device
          Padding(
            padding: EdgeInsets.all(_fixedPadding),
            child: PhoneAuthWidgets.getLogo(
                logoPath: widget.logo, height: _height * 0.2),
          ),

          // AppName:
          Text(widget.appName,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700)),

          Row(
           children: [
             Padding(
               padding: EdgeInsets.only(top: _fixedPadding, right: _fixedPadding),
               child: SubTitle(text: 'اختر بلدك'),
             ),
           ],
          ),

          Padding(
              padding:
              EdgeInsets.only(left: _fixedPadding, right: _fixedPadding),
              child: ShowSelectedCountry(
                country: countriesProvider.selectedCountry,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SelectCountry()),
                  );
                },
              )),

          //  Subtitle for Enter your phone
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.0, right: _fixedPadding),
                child: SubTitle(text: 'أدخل هاتفك'),
              ),
            ],
          ),
          //  PhoneNumber TextFormFields
          Padding(
            padding: EdgeInsets.only(
                left: _fixedPadding,
                right: _fixedPadding,
                bottom: _fixedPadding),
            child: PhoneNumberField(
              controller:
              Provider
                  .of<PhoneAuthDataProvider>(context, listen: false)
                  .phoneNumberController,
              prefix: countriesProvider.selectedCountry.dialCode ?? "+213",
            ),
          ),

          /*
           *  Some informative text
           */
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(width: _fixedPadding),
              Icon(Icons.info, color: Colors.white, size: 20.0),
              SizedBox(width: 10.0),
              Expanded(
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'نحن سوف نرسل',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w400)),
                  TextSpan(
                      text: ' كلمة السر لمرة واحدة',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700)),
                  TextSpan(
                      text: ' إلى رقم الهاتف المحمول هذا',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w400)),
                ])),
              ),
              SizedBox(width: _fixedPadding),
            ],
          ),


          SizedBox(height: _fixedPadding * 1.5),
          RaisedButton(
            elevation: 16.0,
            onPressed: startPhoneAuth,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'ارسال التاكيد',
                style: TextStyle(
                    color: widget.cardBackgroundColor, fontSize: 18.0),
              ),
            ),
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
          ),
        ],
      );

  _showSnackBar(String text) {
    final snackBar = SnackBar(
      content: Text('$text'),
    );
//    if (mounted) Scaffold.of(context).showSnackBar(snackBar);
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  startPhoneAuth() async {
    final phoneAuthDataProvider = Provider.of<PhoneAuthDataProvider>(context, listen: false);
    phoneAuthDataProvider.loading = true;
    var countryProvider = Provider.of<CountryProvider>(context, listen: false);
    print(countryProvider.selectedCountry.dialCode);
    print(phoneAuthDataProvider.phone);
    bool validPhone = await phoneAuthDataProvider.instantiate(
        dialCode: countryProvider.selectedCountry.dialCode,
        onCodeSent: () {
          Navigator.of(context).pushReplacement(CupertinoPageRoute(
              builder: (BuildContext context) => PhoneAuthVerify()));
        },
        onFailed: () {
          _showSnackBar(phoneAuthDataProvider.message);
        },
        onError: () {
          _showSnackBar(phoneAuthDataProvider.message);
        });
    if (!validPhone) {
      phoneAuthDataProvider.loading = false;
      _showSnackBar("اسف! الرقم يبدو غير صحيح");
      return;
    }
  }
}
