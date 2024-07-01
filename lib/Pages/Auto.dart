import 'dart:convert';
import 'package:adair_9ids2/Models/AutosResponse.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:adair_9ids2/Utis/Ambiente.dart';
import 'package:quickalert/quickalert.dart';
import 'package:adair_9ids2/Pages/ListaAutos.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auto extends StatefulWidget {
  final int idAuto;
  const Auto({super.key, required this.idAuto});
  //const Auto({super.key});

  @override
  State<Auto> createState() => _AutoState();
}

class _AutoState extends State<Auto> {
  final _formKey = GlobalKey<FormState>();


  TextEditingController txtMatricula = TextEditingController();
  TextEditingController txtColor = TextEditingController();
  TextEditingController txtModelo = TextEditingController();
  TextEditingController txtMarca = TextEditingController();

  void fnDatosAuto() async {
    final response = await http.post(
      //Ver API de LARAVEL
      Uri.parse('${Ambiente.urlServer}/api/auto'),
      body: jsonEncode(<String, dynamic>{
        "id": widget.idAuto,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );

    Map<String, dynamic> responseJson = jsonDecode(response.body);
    final autoResponse = Autosresponse.fromJson(responseJson);
    txtMatricula.text = autoResponse.matricula;
    txtColor.text = autoResponse.color;
    txtModelo.text = autoResponse.modelo;
    txtMarca.text = autoResponse.marca;
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.idAuto != 0) {
      fnDatosAuto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auto Nuevo"),
      ),
      //backgroundColor: Color(0xFF00836E), // Color de fondo del AppBar
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: txtMatricula,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Matricula'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor llene este campo!';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: txtColor,
                decoration: InputDecoration(labelText: 'Color'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor llene este campo!';
                  }
                },
              ),
              TextFormField(
                controller: txtModelo,
                decoration: InputDecoration(labelText: 'Modelo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor llene este campo!';
                  }
                },
              ),
              TextFormField(
                controller: txtMarca,
                decoration: InputDecoration(labelText: 'Marca'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor llene este campo!';
                  }
                },
              ),

              /////////////////BOTON DE ACTUALIZAR//////////////////////
              TextButton(
                onPressed: () async {

                  if (_formKey.currentState!.validate()) {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String? token = prefs.getString('authToken');
                    //try {   //Este Try es para cachar el error
                    final response = await http.post(
                      //Uri.parse('${Ambiente.urlServer}/api/servicio/guardar'),
                      Uri.parse('${Ambiente.urlServer}/api/auto/guardar'),
                      body: jsonEncode(<String, dynamic>{
                        "id": widget.idAuto,
                        "matricula": txtMatricula.text,
                        "color": txtColor.text,
                        "modelo": txtModelo.text,
                        "marca": txtMarca.text,
                      }),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                        'Accept': 'application/json',
                        'Authorization': 'Bearer $token'
                      },
                    );

                    print(response.body);

                    // Verifica que el código de estado sea 200 y el cuerpo de la respuesta contenga 'Ok'
                    if (response.statusCode == 200 &&
                        response.body.trim() == 'Ok') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ListaAutos()),);
                    } else {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: 'Ooops...!',
                        text: 'Error al guardar tu auto',
                      );
                    }
                  }
                },
                child: Text('Guardar'),
              ),




              /////////////////BOTON DE BORRAR//////////////////////

              Visibility(
                visible: widget.idAuto != 0,
                child: TextButton(
                  onPressed: () async {
                    final response = await http.delete(
                      Uri.parse('${Ambiente.urlServer}/api/auto/eliminar/${widget.idAuto}'),
                      body: jsonEncode(<String, dynamic>{
                        'id': widget.idAuto
                      }),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                        'Accept': 'application/json',
                      },
                    );

                    print(response.body);

                    if (response.statusCode == 200 && response.body.trim() == 'Ok') {
                      Navigator.pop(context);
                    } else {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: 'Ooops...!',
                        text: 'Error al borrar: ${response.body}',
                      );
                    }

                  },
                  child: Text('Borrar'),
                ),
              ),

            ],
          ),

        ),
      ),
    );
  }


}
