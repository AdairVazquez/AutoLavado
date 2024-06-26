import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:adair_9ids2/Pages/Auto.dart';
import 'package:http/http.dart' as http;
import 'package:adair_9ids2/Models/AutosResponse.dart';
import 'package:adair_9ids2/Utis/Ambiente.dart';


class ListaAutos extends StatefulWidget {
  const ListaAutos({super.key});


  @override
  State<ListaAutos> createState() => _ListaAutosState();
}

class _ListaAutosState extends State<ListaAutos> {
  List<Autosresponse> autos = [];

  Widget _listViewAutos() {
    return ListView.builder(
      itemCount: autos.length,
      itemBuilder: (context, index) {
        var auto = autos[index];
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Auto(idAuto: auto.id),
              ),
            );
          },
          title: Text(auto.matricula.toString()),
          subtitle: Text(auto.modelo),
        );
      },
    );
  }

  void fnObtenerAutos() async {
    try {
      var response = await http.get(
        //Uri.parse('http://192.168.0.7:8000/api/servicios'),
        Uri.parse('${Ambiente.urlServer}/api/autos'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);

        Iterable mapAutos = jsonDecode(response.body);
        autos = List<Autosresponse>.from(
          mapAutos.map((model) => Autosresponse.fromJson(model)),
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
    fnObtenerAutos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Autos'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String value) {
              fnObtenerAutos();
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
          _listViewAutos(),
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
                    builder: (context) => const Auto(idAuto: 0),
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
