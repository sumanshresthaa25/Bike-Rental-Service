class UserModel {
  final String? id;
  final String email;
  final String passwordHash;

  const UserModel({this.id, required this.email, required this.passwordHash});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"]?.toString(),
      email: json["email"] ?? "",
      passwordHash: json["password_hash"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "email": email, "password_hash": passwordHash};
  }
}
