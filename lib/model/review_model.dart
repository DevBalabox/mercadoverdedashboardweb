import 'dart:convert';

ReviewModel reviewModelFromJson(String str) => ReviewModel.fromJson(json.decode(str));

String reviewModelToJson(ReviewModel data) => json.encode(data.toJson());

class ReviewModel {
    ReviewModel({
        this.vendedor_id,
        this.descripcion,
        this.puntuacion,
    });

    String vendedor_id;
    String descripcion;
    double puntuacion;

    factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        vendedor_id: json["vendedor_id"],
        descripcion: json["descripcion"],
        puntuacion: json["puntuacion"],
    );

    Map<String, dynamic> toJson() => {
        "vendedor_id": vendedor_id,
        "descripcion": descripcion,
        "puntuacion": puntuacion,
    };
}
