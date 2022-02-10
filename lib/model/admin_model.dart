import 'dart:convert';

AdminModel adminModelFromJson(String str) => AdminModel.fromJson(json.decode(str));

String adminModelToJson(AdminModel data) => json.encode(data.toJson());

class AdminModel {
    AdminModel({
        this.usuario_id,
        this.correo,
        this.password,
        this.tipo,
        this.status,
        this.nombre,
        this.primer_apellido,
        this.segundo_apellido,
        this.gender,
        this.imgUrl,
        this.ubicacion,
        this.ubicacionLat,
        this.ubicacionLng,
        this.fecha_nacimiento,
        this.telefono
    });

    String usuario_id;
    String correo;
    String password;
    String tipo;
    String status;
    String nombre;
    String primer_apellido;
    String segundo_apellido;
    String gender;
    String imgUrl;
    String ubicacion;
    String ubicacionLat;
    String ubicacionLng;
    String fecha_nacimiento;
    String telefono;

    factory AdminModel.fromJson(Map<String, dynamic> json) => AdminModel(
        usuario_id: json["usuario_id"],
        correo: json["correo"],
        password: json["password"],
        tipo: json["tipo"],
        status: json["status"],
        nombre: json["nombre"],
        primer_apellido: json["primer_apellido"],
        segundo_apellido: json["segundo_apellido"],
        gender: json["gender"],
        imgUrl: json["img_url"],
        ubicacion: json["ubicacion"],
        ubicacionLat: json["ubicacion_lat"],
        ubicacionLng: json["ubicacion_lng"],
        fecha_nacimiento: json["fecha_nacimiento"],
        telefono: json["telefono"]
    );

    Map<String, dynamic> toJson() => {
        "usuario_id": usuario_id,
        "correo": correo,
        "password": password,
        "tipo": tipo,
        "status": status,
        "nombre": nombre,
        "primer_apellido": primer_apellido,
        "segundo_apellido": segundo_apellido,
        "gender": gender,
        "img_url": imgUrl,
        "ubicacion": ubicacion,
        "ubicacion_lat": ubicacionLat,
        "ubicacion_lng": ubicacionLng,
        "fecha_nacimiento": fecha_nacimiento,
        "telefono": telefono
    };
}