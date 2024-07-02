import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quickalert/quickalert.dart';
import 'package:adair_9ids2/Models/AutosResponse.dart';
import 'package:adair_9ids2/Models/ServiciosResponse.dart';
import 'package:adair_9ids2/Models/CitasResponse.dart';
import 'package:adair_9ids2/Pages/ListaCitas.dart';
import 'package:adair_9ids2/Utis/Ambiente.dart';

class Citas extends StatefulWidget {
  final int idCita;
  const Citas({super.key, required this.idCita});

  @override
  State<Citas> createState() => _CitasState();
}

class _CitasState extends State<Citas> {
  DateTime? selectedDate;
  List<Autosresponse> autos = [];
  List<Serviciosresponse> servicios = [];
  Autosresponse? auto;
  Serviciosresponse? servicio;

  @override
  void initState() {
    super.initState();
    fnObtenerAutos();
    fnObtenerServicios();
    if (widget.idCita != 0) {
      fnDatosCita();
    }
  }

  void fnDatosCita() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    final response = await http.post(
      Uri.parse('${Ambiente.urlServer}/api/cita'),
      body: jsonEncode(<String, dynamic>{
        "id": widget.idCita,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      final citasResponse = Citasresponse.fromJson(responseJson);

      // Encuentra los objetos de auto y servicio correspondientes
      auto = autos.firstWhere((a) => a.id == citasResponse.id_auto);
      servicio = servicios.firstWhere((s) => s.id == citasResponse.id_servicio);
      selectedDate = DateTime.parse(citasResponse.fecha);

      setState(() {});
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  void fnObtenerServicios() async {
    var response = await http.get(
      Uri.parse('${Ambiente.urlServer}/api/servicios'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      Iterable mapServicios = jsonDecode(response.body);
      setState(() {
        servicios = List<Serviciosresponse>.from(mapServicios.map((model) => Serviciosresponse.fromJson(model)));
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  void fnObtenerAutos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    try {
      var response = await http.get(
        Uri.parse('${Ambiente.urlServer}/api/autosCliente'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Iterable mapAutos = jsonDecode(response.body);
        setState(() {
          autos = List<Autosresponse>.from(mapAutos.map((model) => Autosresponse.fromJson(model)));
        });
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching autos: $e');
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                selectedDate = await showOmniDateTimePicker(context: context);
                setState(() {});
              },
              child: Text(selectedDate == null ? 'Selecciona la fecha y hora' : 'Fecha: $selectedDate'),
            ),
            DropdownButtonFormField<Autosresponse>(
              value: auto,
              onChanged: (Autosresponse? value) {
                setState(() {
                  auto = value;
                });
              },
              items: autos.map<DropdownMenuItem<Autosresponse>>((Autosresponse value) {
                return DropdownMenuItem<Autosresponse>(
                  value: value,
                  child: Text(value.matricula),
                );
              }).toList(),
            ),
            Text(auto == null ? 'Selecciona tu auto' : auto!.matricula),
            DropdownButtonFormField<Serviciosresponse>(
              value: servicio,
              onChanged: (Serviciosresponse? value) {
                setState(() {
                  servicio = value;
                });
              },
              items: servicios.map<DropdownMenuItem<Serviciosresponse>>((Serviciosresponse value) {
                return DropdownMenuItem<Serviciosresponse>(
                  value: value,
                  child: Text(value.nombre),
                );
              }).toList(),
            ),
            Text(servicio == null ? 'Selecciona el servicio deseado' : servicio!.nombre),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (selectedDate != null && auto != null && servicio != null) {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String? token = prefs.getString('authToken');
                    final response = await http.post(
                      Uri.parse('${Ambiente.urlServer}/api/cita/guardar'),
                      body: jsonEncode(<String, dynamic>{
                        "id_servicio": servicio!.id,
                        "id_auto": auto!.id,
                        "fecha": selectedDate!.toIso8601String(),
                      }),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                        'Authorization': 'Bearer $token',
                      },
                    );
                    if (response.body == 'Ok') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Listacitas()),
                      );
                    } else {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: 'Ooops...!',
                        text: response.body,
                      );
                    }
                  } else {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'Faltan Datos',
                      text: 'Por favor selecciona una fecha, un auto y un servicio',
                    );
                  }
                } else {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: 'Faltan Datos',
                    text: 'Por favor selecciona una fecha, un auto y un servicio',
                  );
                }
              },
              child: const Text('Guardar'),
            ),
            Visibility(
              visible: widget.idCita != 0,
              child:
              TextButton(
                onPressed: () async {
                  final response = await http.post(Uri.parse('${Ambiente.urlServer}/api/cita/eliminar'),
                    body: jsonEncode(<String, dynamic>{
                      "id" : widget.idCita,}),
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
          ],
        ),
      ),
    );
  }
}