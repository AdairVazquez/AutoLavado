import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:adair_9ids2/Pages/Citas.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adair_9ids2/Models/CitasResponse.dart';
import 'package:adair_9ids2/Utis/Ambiente.dart';

class Listacitas extends StatefulWidget {
  const Listacitas({super.key});

  @override
  State<Listacitas> createState() => _ListacitasState();
}

class _ListacitasState extends State<Listacitas> {
  List<Citasresponse> citas = [];

  Widget _listViewCitas() {
    return ListView.builder(
      itemCount: citas.length,
      itemBuilder: (context, index) {
        var cita = citas[index];
        print(cita.id);
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Citas(idCita: cita.id),
              ),
            );
          },
          title: Text(cita.fecha.toString()),
          subtitle: Text(cita.id_auto.toString()),
        );
      },
    );
  }

  void fnObtenerCitas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    try {
      var response = await http.get(

        //Uri.parse('http://192.168.0.7:8000/api/servicios'),
        Uri.parse('${Ambiente.urlServer}/api/citas'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        Iterable mapCitas = jsonDecode(response.body);
        citas = List<Citasresponse>.from(
          mapCitas.map((model) => Citasresponse.fromJson(model)),
        );

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
    fnObtenerCitas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Citas'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) {
              fnObtenerCitas();
            },
            itemBuilder: (BuildContext context) {
              return {'Actualizar lista'}.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          ),
        ],
      ),


      body: Stack(
        children: [
          // Tu contenido principal aquí
          _listViewCitas(),
          // Primer botón flotante
          Positioned(
            bottom: 80.0,
            right: 10.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    //builder: (context) => const Servicio(idServicio: 0),
                    builder: (context) => const Citas(idCita: 0),
                  ),
                );
              },
              child: Icon(Icons.add_box_rounded),
            ),
          ),
          // Segundo botón flotante
        ],
      ),
    );
  }

}
