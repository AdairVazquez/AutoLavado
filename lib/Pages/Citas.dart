import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:adair_9ids2/Models/AutosResponse.dart';
import 'package:adair_9ids2/Models/ServiciosResponse.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adair_9ids2/Utis/Ambiente.dart';
import 'package:quickalert/quickalert.dart';

class Citas extends StatefulWidget {
  const Citas({super.key});

  @override
  State<Citas> createState() => _CitasState();
}

class _CitasState extends State<Citas> {
  DateTime? selectedDate;
  List<Autosresponse> autos = [];
  List<Serviciosresponse> servicios = [];
  Autosresponse? auto;
  Serviciosresponse? servicio;

  void fnObtenerServicios() async {
    var response = await http.get(
      Uri.parse('${Ambiente.urlServer}/api/servicios'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    print(response.body);
    Iterable mapServicios = jsonDecode(response.body);
    servicios = List<Serviciosresponse>.from(mapServicios.map((model) => Serviciosresponse.fromJson(model)));
    setState(() {});
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
        print(response.body);
        Iterable mapAutos = jsonDecode(response.body);
        autos = List<Autosresponse>.from(mapAutos.map((model) => Autosresponse.fromJson(model)));
        setState(() {});
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching services: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fnObtenerAutos();
    fnObtenerServicios();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20,),
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
              auto = value;
              setState(() {});
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
              servicio = value;
              setState(() {});
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
                  var id_serv = servicio?.id;
                  var id_auto = auto?.id;
                  var fecha = selectedDate;

                  if (id_serv != null && id_auto != null && fecha != null) {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String? token = prefs.getString('authToken');
                    final response = await http.post(
                      Uri.parse('${Ambiente.urlServer}/api/cita/guardar'),
                      body: jsonEncode(<String, dynamic>{
                        "id_servicio": id_serv,
                        "id_auto": id_auto,
                        "fecha": fecha.toIso8601String(),
                      }),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                        'Authorization': 'Bearer $token',
                      },
                    );
                    print(response.body);
                    if (response.body == 'Ok') {
                      Navigator.pop(context);
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
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
