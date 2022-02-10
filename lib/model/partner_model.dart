import 'dart:convert';

PartnerModel partnerModelFromJson(String str) => PartnerModel.fromJson(json.decode(str));

String partnerModelToJson(PartnerModel data) => json.encode(data.toJson());

class PartnerModel {
    PartnerModel({
        this.primer_apellido,
        this.segundo_apellido,
        this.nombre,
        this.correo,
        this.created_at,
        this.updatedAt,
        this.deletedAt,
        this.password,
        this.fecha_nacimiento,
        this.sexo,
        this.telefono,
        this.imgUrl,
        this.tipo,
        this.ubicacion,
        this.id,
        this.usuario_id,
    });

    String primer_apellido;
    String segundo_apellido;
    String nombre;
    String correo;
    dynamic created_at;
    String updatedAt;
    dynamic deletedAt;
    dynamic password;
    String fecha_nacimiento;
    dynamic sexo;
    String telefono;
    dynamic imgUrl;
    String tipo;
    String ubicacion;
    dynamic id;
    String usuario_id;

    factory PartnerModel.fromJson(Map<String, dynamic> json) => PartnerModel(
        primer_apellido: json["primer_apellido"],
        segundo_apellido: json["segundo_apellido"],
        nombre: json["nombre"],
        correo: json["correo"],
        created_at: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
        password: json["password"],
        fecha_nacimiento: json["fecha_nacimiento"],
        sexo: json["sexo"],
        telefono: json["telefono"],
        imgUrl: json["img_url"],
        tipo: json["tipo"],
        ubicacion: json["ubicacion"],
        id: json["id"],
        usuario_id: json["usuario_id"],
    );

    Map<String, dynamic> toJson() => {
        "primer_apellido": primer_apellido,
        "segundo_apellido": segundo_apellido,
        "nombre": nombre,
        "correo": correo,
        "created_at": created_at,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
        "password": password,
        "fecha_nacimiento": fecha_nacimiento,
        "sexo": sexo,
        "telefono": telefono,
        "img_url": imgUrl,
        "tipo": tipo,
        "ubicacion": ubicacion,
        "id": id,
        "usuario_id": usuario_id,
    };
}