import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:libphonenumber/libphonenumber.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  String maskNumber = '(00) 0000-0000';
  late MaskedTextController textFormFieldController;
  late String? codeCountry = '';
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  String? systemcontry =
      WidgetsBinding.instance.platformDispatcher.locale.countryCode;
  @override
  void initState() {
    super.initState();
    textFormFieldController = MaskedTextController(mask: maskNumber);
    WidgetsBinding.instance.addObserver(this);
    _checkClipboard();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboard();
    }
  }

  Future<void> _checkClipboard() async {
    var data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      String phoneNumber = data.text!.replaceAll(RegExp(r'[()\s-+]'), '');
      bool? isValid = await PhoneNumberUtil.isValidPhoneNumber(
          phoneNumber: phoneNumber, isoCode: 'BR');
      if (!mounted) return;

      if (isValid!) {
        textFormFieldController.text = phoneNumber;
        return openWhatsApp();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Não é um número válido para ir direto para o Whatsapp',
          style: TextStyle(color: Theme.of(context).colorScheme.onError),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.green,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                'WhatsApp Paste ',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.onPrimary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                'Cole o número do telefone ',
                style: TextStyle(fontSize: 23, color: theme.onPrimary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CountryCodePicker(
                  onChanged: (element) =>
                      {codeCountry = element.toLongString().split(' ')[0]},
                  onInit: (code) => codeCountry = code?.dialCode,
                  // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                  initialSelection: systemcontry,
                  favorite: const ['+55', 'BR'],
                  showFlag: true,
                  showFlagMain: true,
                  textStyle: TextStyle(color: theme.onPrimary),
                ),
                Expanded(
                  child: TextFormField(
                    focusNode: _focusNode,
                    controller: textFormFieldController,
                    style: TextStyle(
                      color: theme.onPrimary, // cor do texto digitado
                    ),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: theme.onPrimary, // cor do label
                        fontWeight:
                            _isFocused ? FontWeight.bold : FontWeight.normal,
                      ),
                      focusColor: theme.onPrimary,
                      labelText: 'Telefone',
                      hintText: maskNumber,
                      hintStyle: TextStyle(
                        color: theme.tertiary, // cor do placeholder
                      ),
                      hoverColor: theme.error,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: theme.onPrimary, // cor da borda
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 1, color: theme.onPrimary),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => openWhatsApp(),
                  child: const Text('Abrir'),
                )),
          ),
        ],
      ),
    );
  }

  openWhatsApp() async {
    String telNumber =
        textFormFieldController.text.replaceAll(RegExp(r'[()\s-+]'), '');
    String url = (Platform.isIOS == true)
        ? 'https://wa.me/$telNumber'
        : 'whatsapp://send?phone=$telNumber';

    try {
      await launchUrlString(url);
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Whatsapp não instalado'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
