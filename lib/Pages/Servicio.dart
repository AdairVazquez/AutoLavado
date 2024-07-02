import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:adair_9ids2/Models/ServiciosResponse.dart';
import 'package:adair_9ids2/Pages/Etapas.dart';
import 'package:adair_9ids2/Pages/Etapa.dart';
import 'package:adair_9ids2/Pages/Auto.dart';
import 'package:adair_9ids2/Pages/Citas.dart';
import 'package:adair_9ids2/Pages/ListaCitas.dart';
import 'package:adair_9ids2/Utis/Ambiente.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';

class Servicio extends StatefulWidget {

  final int idServicio;
  const Servicio({super.key, required this.idServicio});

  @override
  State<Servicio> createState() => _ServicioState();
}

class _ServicioState extends State<Servicio> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController txtCodigo = TextEditingController();
  TextEditingController txtNombre = TextEditingController();
  TextEditingController txtDescripcion = TextEditingController();
  TextEditingController txtPrecio = TextEditingController();

  //Editar
  void fnDatosServicio() async{
    final response = await http.post(Uri.parse('${Ambiente.urlServer}/api/servicio'),
      body: jsonEncode(<String, dynamic>{
        "id" : widget.idServicio,
      }),
      headers: <String, String>{
        'Content-Type' : 'application/json; charset=UTF-8'
      },
    );

    Map<String, dynamic> responseJson = jsonDecode(response.body);
    final servicioResponse = Serviciosresponse.fromJson(responseJson);

    txtCodigo.text = servicioResponse.codigo.toString();
    txtNombre.text = servicioResponse.nombre;
    txtDescripcion.text = servicioResponse.descripcion;
    txtPrecio.text = servicioResponse.precio.toString();
  }

  @override
  void initState(){
    super.initState();
    if(widget.idServicio != 0){
      fnDatosServicio();
    }

  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Servicio Nuevo"),),
      body: Form(
        key: _formKey,
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20,),
            TextFormField(
              controller: txtCodigo,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Codigo'),
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
              controller: txtDescripcion,
              decoration: InputDecoration(labelText: 'Descripcion'),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Por favor llene este campo!';
                }
              },
            ),
            TextFormField(
              controller: txtPrecio,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Precio'),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Por favor llene este campo!';
                }
              },
            ),
            TextButton(onPressed: () async {
              if(_formKey.currentState!.validate()){
                final response = await http.post(Uri.parse('${Ambiente.urlServer}/api/servicio/guardar'),
                  body: jsonEncode(<String, dynamic>{
                    "id" : widget.idServicio,
                    "codigo" : txtCodigo.text,
                    "nombre" : txtNombre.text,
                    "descripcion" : txtDescripcion.text,
                    "precio" : txtPrecio.text,
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
              visible: widget.idServicio != 0,
              child:
              TextButton(
                onPressed: () async {
                  final response = await http.post(Uri.parse('${Ambiente.urlServer}/api/servicio/eliminar'),
                    body: jsonEncode(<String, dynamic>{
                      "id" : widget.idServicio,}),
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
            ),
            Visibility(
              visible: widget.idServicio != 0,
              child: TextButton(
                onPressed: () async {
                  final response = await http.post(Uri.parse('${Ambiente.urlServer}/api/servicioI'),
                    body: jsonEncode(<String, dynamic>{
                      "id" : widget.idServicio,}),
                    headers: <String, String>{
                      'Content-Type' : 'application/json; charset=UTF-8'
                    },);
                  if(response.body == 'Ok'){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Etapas(idServicio: widget.idServicio),
                      ),
                    );
                  } else{
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.confirm,
                      text: 'No existen etapas aqui, ¿Deseas agregar una nueva etapa?',
                      confirmBtnText: 'Si',
                      cancelBtnText: 'No',
                      confirmBtnColor: Colors.green,

                      onConfirmBtnTap: () async{
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Etapa(idEtapa: 0, id_servicio: widget.idServicio)),);
                      }
                    );
                  }
                }, child: Text('Ver etapas'),
              ),
            ),
            Visibility(
              visible: widget.idServicio != 0,
              child:
              TextButton(
                onPressed: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Auto(idAuto: 0)),);
                  }, child: Text('Agregr Auto'),
              ),
            ),
            Visibility(
              visible: widget.idServicio != 0,
              child:
              TextButton(
                onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Citas(idCita: 0)),);
                }, child: Text('Agregr Cita'),
              ),
            ),
            Visibility(
              visible: widget.idServicio != 0,
              child:
              TextButton(
                onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Listacitas()),);
                }, child: Text('ver Citas'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
