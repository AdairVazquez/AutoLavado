import 'dart:convert';
// aqui se hacen las importaciones correspondientes
import 'package:adair_9ids2/Models/EtapasResponse.dart';
import 'package:adair_9ids2/Models/ServiciosResponse.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import '../Utis/Ambiente.dart';

class Etapa extends StatefulWidget {
  final int idEtapa, id_servicio;
  const Etapa({super.key, required this.idEtapa, required this.id_servicio});

  @override
  State<Etapa> createState() => _EtapaState();
}

class _EtapaState extends State<Etapa> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController txtServicio = TextEditingController();
  TextEditingController txtNombre = TextEditingController();
  TextEditingController txtDuracion = TextEditingController();

  //Editar
  void fnDatosEtapas() async{
    final response = await http.post(Uri.parse('${Ambiente.urlServer}/api/etapa'),
      body: jsonEncode(<String, dynamic>{
        "id" : widget.idEtapa,
      }),
      headers: <String, String>{
        'Content-Type' : 'application/json; charset=UTF-8'
      },
    );

    Map<String, dynamic> responseJson = jsonDecode(response.body);
    final etapaResponse = Etapasresponse.fromJson(responseJson);

    txtServicio.text = etapaResponse.id_servicio.toString();
    txtNombre.text = etapaResponse.nombre;
    txtDuracion.text = etapaResponse.duracion.toString();

  }

  @override
  void initState(){

    super.initState();
    if(widget.idEtapa != 0){
      fnDatosEtapas();
    }else{
      txtServicio.text = widget.id_servicio.toString();
    }

  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Etapa Nuevo"),),
      body: Form(
        key: _formKey,
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20,),
            TextFormField(
              controller: txtServicio,

              enabled: false,
              decoration: InputDecoration(labelText: 'Servicio'),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Por favor llene este campo!';
                }
              },
            ),
            TextFormField(
              controller: txtNombre,
              decoration: InputDecoration(labelText: 'Nombre'),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Por favor llene este campo!';
                }
              },
            ),
            TextFormField(
              controller: txtDuracion,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Duracion en horas'),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Por favor llene este campo!';
                }
              },
            ),
            TextButton(onPressed: () async {
              if(_formKey.currentState!.validate()){
                final response = await http.post(Uri.parse('${Ambiente.urlServer}/api/etapa/guardar'),
                  body: jsonEncode(<String, dynamic>{
                    "id" : widget.idEtapa,
                    "id_servicio" : txtServicio.text,
                    "nombre" : txtNombre.text,
                    "duracion" : txtDuracion.text,
                  }),
                  headers: <String, String>{
                    'Content-Type' : 'application/json; charset=UTF-8'
                  },
                );
                print(response.body);
                if(response.body == 'Ok'){
                  Navigator.pop(context);
                } else{
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: 'Ooops...!',
                    text: response.body,
                  );
                }
              }
            }, child: Text('Guardar'),
            ),
            Visibility(
              visible: widget.idEtapa != 0,
              child:
              TextButton(
                onPressed: () async {
                  final response = await http.post(Uri.parse('${Ambiente.urlServer}/api/etapa/eliminar'),
                    body: jsonEncode(<String, dynamic>{
                      "id" : widget.idEtapa,}),
                    headers: <String, String>{
                      'Content-Type' : 'application/json; charset=UTF-8'
                    },);
                  if(response.body == 'Ok'){
                    Navigator.pop(context);
                  } else{
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'Ooops...!',
                      text: response.body,
                    );
                  }
                }, child: Text('Eliminar'),
              ),
            )],
        ),
      ),
    );
  }
}
