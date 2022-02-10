import 'dart:convert';

ServiceModel serviceModelFromJson(String str) => ServiceModel.fromJson(json.decode(str));

String serviceModelToJson(ServiceModel data) => json.encode(data.toJson());

class ServiceModel {
    ServiceModel({
        this.nombre,
        this.descripcion,
        this.ubicacion,
        this.nombreContacto,
        this.telefonoContacto,
        this.emailContacto,
        this.imagenes,
    });

    String nombre;
    String descripcion;
    String ubicacion;
    String nombreContacto;
    String telefonoContacto;
    String emailContacto;
    String imagenes;

    factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        ubicacion: json["ubicacion"],
        nombreContacto: json["nombre_contacto"],
        telefonoContacto: json["telefono_contacto"],
        emailContacto: json["email_contacto"],
        imagenes: json["imagenes"],
    );

    Map<String, dynamic> toJson() => {
        "nombre": nombre,
        "descripcion": descripcion,
        "ubicacion": ubicacion,
        "nombre_contacto": nombreContacto,
        "telefono_contacto": telefonoContacto,
        "email_contacto": emailContacto,
        "imagenes": imagenes,
    };
}
