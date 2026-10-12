import 'dart:convert';
import 'dart:io';

import 'package:bike_rental_service/model/user_model.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usersFileName = "users.json";
  static const String _usersPrefsKey = "local_users";

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<UserModel?> findUserByEmail(String email) async {
    final users = await _readUsers();
    return users.cast<UserModel?>().firstWhere(
      (user) => user?.email == email,
      orElse: () => null,
    );
  }

  Future<UserModel> createUser({
    required String email,
    required String password,
  }) async {
    final users = await _readUsers();
    final user = UserModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      email: email,
      passwordHash: hashPassword(password),
    );

    users.add(user);
    await _writeUsers(users);
    return user;
  }

  bool passwordMatches(UserModel user, String password) {
    return user.passwordHash == hashPassword(password);
  }

  Future<File?> _usersFile() async {
    try {
      final directory = await getApplicationSupportDirectory();
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return File("${directory.path}/$_usersFileName");
    } catch (_) {
      return null;
    }
  }

  Future<List<UserModel>> _readUsers() async {
    final file = await _usersFile();
    if (file == null) {
      final prefs = await SharedPreferences.getInstance();
      return _decodeUsers(prefs.getString(_usersPrefsKey) ?? "[]");
    }

    if (!await file.exists()) {
      await file.writeAsString(jsonEncode(<Map<String, dynamic>>[]));
      return [];
    }

    return _decodeUsers(await file.readAsString());
  }

  Future<void> _writeUsers(List<UserModel> users) async {
    final data = jsonEncode(users.map((user) => user.toJson()).toList());
    final file = await _usersFile();
    if (file == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usersPrefsKey, data);
      return;
    }

    await file.writeAsString(data);
  }

  List<UserModel> _decodeUsers(String contents) {
    if (contents.trim().isEmpty) return [];

    final data = jsonDecode(contents);
    if (data is! List) {
      throw const FormatException("Users storage must contain a JSON list.");
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(UserModel.fromJson)
        .toList();
  }
}
