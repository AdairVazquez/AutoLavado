import 'dart:convert';

import 'package:adair_9ids2/Models/LoginResponse.dart';
import 'package:adair_9ids2/Pages/Home.dart';
import 'package:adair_9ids2/Utis/Ambiente.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController txtUser = TextEditingController();
  TextEditingController txtPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        body:
        SingleChildScrollView(
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network('https://cdn-icons-png.freepik.com/512/5087/5087607.png',
                width: 250, height: 250,),
              const SizedBox(height: 20,),
              TextField(
                controller: txtUser,
                decoration: InputDecoration(
                    labelText: 'Usuario'),
              ),
              TextField(
                controller: txtPass,
                decoration: InputDecoration(
                    labelText: 'Contraseña'
                ),
                obscureText: true,
              ),

              TextButton(onPressed: () async{
                final response =
                await http.post(Uri.parse('${Ambiente.urlServer}/api/login'),
                    body: jsonEncode(<String, dynamic>{
                      'email' : txtUser.text,
                      'password' : txtPass.text,
                    }),
                    headers: <String, String>{
                      'Content-Type' : 'application/json; charset=UTF-8'
                    }
                );
                Map<String, dynamic> responseJson = jsonDecode(response.body);
                final loginResponse = Loginresponse.fromJson(responseJson);
                //print(loginResponse);

                //Codigo del boton
                if(loginResponse.acceso == 'Ok'){
                  /*QuickAlert.show(
                      context: context,
                      type: QuickAlertType.success,
                      text: 'Transaccion completada !',
                    );*/
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()),);}
                else{
                  print(loginResponse);
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: 'Oops.. !',
                    text: loginResponse.error,
                  );}

              }, child: Text('Accesar'))
            ],
          ),
        )
    );
  }
}