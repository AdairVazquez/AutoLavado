class Autosresponse{
  final int id;
  final String matricula;
  final String color;
  final String modelo;
  final String marca;

  Autosresponse(this.id,
      this.matricula,
      this.color,
      this.modelo,
      this.marca);

  Autosresponse.fromJson(Map<String, dynamic> json)
      :   id = json['id'],
        matricula = json['matricula'],
        color = json['color'],
        modelo = json['modelo'],
        marca = json['marca'];
}

