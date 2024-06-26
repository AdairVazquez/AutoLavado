class Etapasresponse{
  final int id;
  final int id_servicio;
  final String nombre;
  final double duracion;


  Etapasresponse(this.id,
      this.id_servicio,
      this.nombre,
      this.duracion);

  Etapasresponse.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        id_servicio = json['id_servicio'],
        nombre = json['nombre'],
        duracion = double.parse(json['duracion']);
}