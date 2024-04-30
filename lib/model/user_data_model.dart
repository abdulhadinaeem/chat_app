// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserDataModel {
  String? name;
  String? email;
  String? passWord;
  String? status;
  String? id;
  String? fcmToken;
  UserDataModel(
      {this.name,
      this.email,
      this.passWord,
      this.status,
      this.id,
      this.fcmToken});

  UserDataModel copyWith({
    String? name,
    String? email,
    String? passWord,
    String? status,
    String? id,
    String? fcmToken,
  }) {
    return UserDataModel(
      name: name ?? this.name,
      email: email ?? this.email,
      passWord: passWord ?? this.passWord,
      status: status ?? this.status,
      id: id ?? this.id,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'passWord': passWord,
      'status': status,
      'id': id,
      'fcmToken': fcmToken,
    };
  }

  factory UserDataModel.fromMap(Map<String, dynamic> map) {
    return UserDataModel(
      name: map['name'] != null ? map['name'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      passWord: map['passWord'] != null ? map['passWord'] as String : null,
      status: map['status'] != null ? map['status'] as String : null,
      id: map['id'] != null ? map['id'] as String : null,
      fcmToken: map['fcmToken'] != null ? map['fcmToken'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDataModel.fromJson(String source) =>
      UserDataModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserDataModel(name: $name, email: $email, passWord: $passWord, status: $status, id: $id, fcmToken: $fcmToken)';
  }

  @override
  bool operator ==(covariant UserDataModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.email == email &&
        other.passWord == passWord &&
        other.status == status &&
        other.id == id &&
        other.fcmToken == fcmToken;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        passWord.hashCode ^
        status.hashCode ^
        id.hashCode ^
        fcmToken.hashCode;
  }
}
