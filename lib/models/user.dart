class User {
  final String? id;
  final String? name;
  final String? email;
  final int? age;
  final String? gender;
  final int? weight;
  final int? height;
  final String? imageUrl;

  User({
    this.id,
    this.name,
    this.email,
    this.age,
    this.gender,
    this.weight,
    this.height,
    this.imageUrl,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      age: data['age'],
      gender: data['gender'],
      weight: data['weight'],
      height: data['height'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'imageUrl': imageUrl,
    };
  }
}
