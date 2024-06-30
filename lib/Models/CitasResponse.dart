class Citasresponse{
  final int id;
  final String id_usuario;
  final String id_servicio;
  final String id_auto;
  final String fecha;
  final String hora;

  Citasresponse(this.id,
      this.id_usuario,
      this.id_servicio,
      this.id_auto,
      this.fecha,
      this.hora
  );

  Citasresponse.fromJson(Map<String, dynamic> json)
      :   id = json['id'],
        id_usuario = json['id_usuario'],
        id_servicio = json['id_servicio'],
        id_auto = json['id_auto'],
        fecha = json['fecha'];
        hora = json['hora'];
}
//Hola, comentario de Yoss(～￣▽￣)～

