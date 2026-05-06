class UserModel {
  final String uid;
  final String name;
  final String email;
  final int age;
  final String gender;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
    );
  }
}
