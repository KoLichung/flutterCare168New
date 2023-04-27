import 'blog_category.dart';

class BlogPost {
  int? id;
  String? title;
  String? coverImage;
  String? publishDate;
  String? createDate;
  List<BlogCategory>? categories;

  BlogPost(
      {this.id,
        this.title,
        this.coverImage,
        this.publishDate,
        this.createDate,
        this.categories});

  BlogPost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    if( json['cover_image'] != null) {
      coverImage = json['cover_image'];
    }
    publishDate = json['publish_date'];
    createDate = json['create_date'];
    if (json['categories'] != null) {
      categories = <BlogCategory>[];
      json['categories'].forEach((v) {
        categories!.add(BlogCategory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['cover_image'] = this.coverImage;
    data['publish_date'] = this.publishDate;
    if (this.categories != null) {
      data['categories'] = this.categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}