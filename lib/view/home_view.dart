import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:libphonenumber/libphonenumber.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  final _textFormFieldContraller = TextEditingController();
  late String? codeCountry = '';
  String _validationMessage = '';

  String? systemcontry = WidgetsBinding.instance.platformDispatcher.locale.countryCode;
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkClipboard();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      _checkClipboard();
    }
  }

  Future<void> _validatePhoneNumber(String phoneNumber) async {
    try {
      bool? isValid = await PhoneNumberUtil.isValidPhoneNumber(
        phoneNumber: phoneNumber,
        isoCode: 'BR',
      );
      setState(() {
        _validationMessage = isValid!
            ? 'The phone number is valid'
            : 'The phone number is invalid';
      });
    } catch (e) {
      setState(() {
        _validationMessage = 'Error validating phone number: $e';
      });
    }
  }

  Future<void> _checkClipboard() async {
    var data = await Clipboard.getData(Clipboard.kTextPlain);
    if(data != null && data.text != null){
      print("*************************************************");
      String phoneNumber = data.text!.replaceAll(RegExp(r'[()\s-+]'), '');
      print(phoneNumber);
      bool? isValid = await PhoneNumberUtil.isValidPhoneNumber(phoneNumber: phoneNumber, isoCode: 'BR');
      print("*************************************************");
      if(isValid!){
        _textFormFieldContraller.text = phoneNumber;
        openWhatsApp();
      } else {
        ScaffoldMessengerState _scaffoldMessengerState =
        ScaffoldMessenger.of(context);
        _scaffoldMessengerState.showSnackBar(SnackBar(
          content: Text('Não é um numero válido para ir direto para o Whatsapp'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.green,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                'WhatsApp Paste ',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                'Cole o número do telefone ',
                style: TextStyle(fontSize: 23, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: SizedBox(
          //       width: double.infinity,
          //       child: TextFormField(
          //         controller: _textFormFieldContraller,
          //         decoration: InputDecoration(
          //             fillColor: Colors.white,
          //             enabledBorder: OutlineInputBorder(
          //                 borderSide:
          //                     BorderSide(width: 1, color: Colors.white))),
          //       )),
          // ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CountryCodePicker(
                  onChanged: (element) => {
                    codeCountry = element.toLongString().split(' ')[0]
                  },
                  onInit: (code) => codeCountry = code?.dialCode,
                  // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                  initialSelection: systemcontry,
                  favorite: const ['+55', 'BR'],
                  showFlag: true,
                  showFlagMain: true,
                ),
                Expanded(
                  child: TextFormField(
                    controller: _textFormFieldContraller,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(width: 1, color: Colors.white))),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => openWhatsApp(),
                  child: Text('Abrir'),
                )),
          ),
        ],
      ),
    );
  }

  openWhatsApp() async {
    print(_textFormFieldContraller.text);
    String teste =
        _textFormFieldContraller.text.replaceAll(RegExp(r'[()\s-+]'), '');
    String url = (Platform.isIOS == true)
        ? 'https://wa.me/$teste'
        : 'whatsapp://send?phone=$teste';

    ScaffoldMessengerState _scaffoldMessengerState =
        ScaffoldMessenger.of(context);

    try {
      await launchUrlString(url);
    } on Exception catch (e) {
      print(e);
      _scaffoldMessengerState.showSnackBar(SnackBar(
        content: Text('Whatsapp não instalado'),
        backgroundColor: Colors.red,
      ));
    }
    print(url);
  }
}
