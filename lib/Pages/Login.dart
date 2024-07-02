import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adair_9ids2/Utis/Ambiente.dart';
import 'package:adair_9ids2/Models/LoginResponse.dart';
import 'package:adair_9ids2/Pages/Home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController txtUser = TextEditingController();
  TextEditingController txtPass = TextEditingController();

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('${Ambiente.urlServer}/api/login'),
      body: jsonEncode(<String, dynamic>{
        'email': txtUser.text,
        'password': txtPass.text,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      final loginResponse = Loginresponse.fromJson(responseJson);

      if (loginResponse.acceso == 'Ok') {
        print(loginResponse.token);
        final token = responseJson['token'];
        // Guarda el token en SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);

        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Transacción completada!',
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops.. !',
          text: loginResponse.error,
        );
      }
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops.. !',
        text: 'Error de servidor: ${response.statusCode}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://cdn-icons-png.freepik.com/512/5087/5087607.png',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: txtUser,
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: txtPass,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            TextButton(
              onPressed: _login,
              child: Text('Accesar'),
            ),
          ],
        ),
      ),
    );
  }
}
