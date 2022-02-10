import 'dart:convert';

import 'dart:convert';

ProductModel productModelFromJson(String str) => ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
    ProductModel({
        this.nombre,
        this.descripcion,
        this.categoria_id,
        this.subcategoria_id,
        this.precio,
    });

    String nombre;
    String descripcion;
    String categoria_id;
    String subcategoria_id;
    String precio;

    factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        categoria_id: json["categoria_id"],
        subcategoria_id: json["subcategoria_id"],
        precio: json["precio"],
    );

    Map<String, dynamic> toJson() => {
        "nombre": nombre,
        "descripcion": descripcion,
        "categoria_id": categoria_id,
        "subcategoria_id": subcategoria_id,
        "precio": precio,
    };
}
