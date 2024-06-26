import 'dart:convert';

import 'package:flutter/material.dart';
import '../Models/EtapasResponse.dart';
import '../Utis/Ambiente.dart';
import 'Etapa.dart';
import 'package:http/http.dart' as http;

class Etapas extends StatefulWidget {

  final int idServicio;

  const Etapas({super.key, required this.idServicio});

  @override
  State<Etapas> createState() => _EtapasState();
}

class _EtapasState extends State<Etapas> {
  List<Etapasresponse> etapas = [];

  Widget _listViewEtapas(){
    return  ListView.builder(
        itemCount: etapas.length,
        itemBuilder: (context, index){
          var etapa = etapas[index];
          return ListTile(

            onTap: (){
              Navigator.push(
                context,

                MaterialPageRoute(builder: (context) => Etapa(idEtapa: etapa.id,id_servicio: 0)),
              );
            },
            title: Text(etapa.nombre),
            subtitle: Text(etapa.duracion.toString()),
          );
        }
    );
  }

  void fnObtenerEtapas() async{
    var response = await http.post(Uri.parse('${Ambiente.urlServer}/api/etapa/sola'),
      body: jsonEncode(<String, dynamic>{
        "id" : widget.idServicio,
      }),
      headers: <String, String>{
        'Content-Type' : 'application/json; charset=UTF-8'
      },

    );
    print(response.body);
    print(widget.idServicio);
    Iterable mapEtapas = jsonDecode(response.body);
    etapas = List<Etapasresponse>.from(mapEtapas.map((model) => Etapasresponse.fromJson(model)));

    setState(() {

    });
  }
  @override
  void initState(){
    super.initState();
    fnObtenerEtapas();
  }
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Etapas'),
        actions: <Widget>[
          PopupMenuButton<String>(
              onSelected: (String value){
                fnObtenerEtapas();
              },
              itemBuilder: (BuildContext context){
                return {'Actualizar lista'}.map((String item){
                  return PopupMenuItem<String>(
                      value: item,
                      child: Text(item)
                  );
                }).toList();
              })
        ],
      ),
      body: _listViewEtapas(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Etapa(idEtapa: 0,id_servicio: widget.idServicio)),);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
