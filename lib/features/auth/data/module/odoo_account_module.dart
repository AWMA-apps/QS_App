import 'package:quantum_space/features/auth/domain/entities/odoo_account.dart';

class OdooAccountModule extends OdooAccount {
  const OdooAccountModule({
    required super.url,
    required super.username,
    required super.password,
    required super.sessionId,
    required super.personName,
    required super.uid,
  });

  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "username": username,
      "password": password,
      "personName": personName,
      "session_id": sessionId,
      "uid": uid,
    };
  }

  factory OdooAccountModule.fromJSON(Map<String, dynamic> json) {
    return OdooAccountModule(
      url: json["url"],
      username: json["username"],
      password: json["password"],
      personName: json["personName"],
      sessionId: json["session_id"],
      uid: json["uid"],
    );
  }

  OdooAccountModule copyWith({String? sessionId, String? password}) {
    return OdooAccountModule(
      url: url,
      username: username,
      password: password ?? this.password,
      personName: personName,
      sessionId: sessionId ?? this.sessionId,
      uid: uid,
    );
  }
}
