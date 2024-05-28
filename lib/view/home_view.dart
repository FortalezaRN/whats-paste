import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _textFormFieldContraller = TextEditingController();
  @override
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
            child: Text('WhatsApp Paste ', style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ), textAlign: TextAlign.center,),
          ),
        ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: Text('Cole o número do telefone ', style: TextStyle(
                  fontSize: 23,
                  color: Colors.white
              ), textAlign: TextAlign.center,),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: TextFormField(
                controller: _textFormFieldContraller,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.white)
                  )
                ),
              )
            ),),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => openWhatsApp(),
                child: Text('Abrir'),
              )
            ),
          ),
      ],),
    );
  }

  openWhatsApp() async{
    print(_textFormFieldContraller.text);
    String teste = _textFormFieldContraller.text.replaceAll(RegExp(r'[()\s-+]'), '');
    String url = (Platform.isIOS == true) ?
    'https://wa.me/$teste'
    :
    'whatsapp://send?phone=$teste';

    ScaffoldMessengerState _scaffoldMessengerState = ScaffoldMessenger.of(context);

    try{
      await launchUrlString(url);
    } on Exception catch(e){
      print(e);
      _scaffoldMessengerState.showSnackBar(
        SnackBar(
          content: Text('Whatsapp não instalado'),
          backgroundColor: Colors.red,
        )
      );
    }
    print(url);
  }
}

