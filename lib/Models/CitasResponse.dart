class Citasresponse{
  final int id;
  final int id_usuario;
  final int id_servicio;
  final int id_auto;
  final String fecha;

  Citasresponse(this.id,
      this.id_usuario,
      this.id_servicio,
      this.id_auto,
      this.fecha
  );

  Citasresponse.fromJson(Map<String, dynamic> json)
      :   id = json['id'],
        id_usuario = json['id_usuario'],
        id_servicio = json['id_servicio'],
        id_auto = json['id_auto'],
        fecha = json['fecha'];
}
//Hola, comentario de Yoss(～￣▽￣)～

