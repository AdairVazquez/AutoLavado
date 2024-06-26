class Loginresponse{
  final String acceso;
  final String error;
  final String token;
  final int idUsuario;
  final String nombreUsuario;

  Loginresponse(this.acceso,
      this.error,
      this.token,
      this.idUsuario,
      this.nombreUsuario);

  Loginresponse.fromJson(Map<String, dynamic> json)
      : acceso = json['acceso'],
        error = json['error'],
        token = json['token'],
        idUsuario = json['idUsuario'],
        nombreUsuario = json['nombreUsuario'];
}