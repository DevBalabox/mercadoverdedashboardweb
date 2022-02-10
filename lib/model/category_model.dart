import 'dart:convert';

CategoryModel categoryModelFromJson(String str) => CategoryModel.fromJson(json.decode(str));

String categoryModelToJson(CategoryModel data) => json.encode(data.toJson());

class CategoryModel {
    CategoryModel({
        this.categoryId,
        this.name,
        this.fatherCategoryId,
        this.imgUrl,
    });

    String categoryId;
    String name;
    String fatherCategoryId;
    String imgUrl;

    factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        categoryId: json["category_id"],
        name: json["name"],
        fatherCategoryId: json["father_category_id"],
        imgUrl: json["img_url"],
    );

    Map<String, dynamic> toJson() => {
        "category_id": categoryId,
        "name": name,
        "father_category_id": fatherCategoryId,
        "img_url": imgUrl,
    };
}
