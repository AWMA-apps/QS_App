import 'package:quantum_space/features/auth/domain/entities/odoo_account.dart';

class OdooAccountModule extends OdooAccount {
  const OdooAccountModule({
    required super.url,
    required super.username,
    required super.password,
    required super.session_id,
    required super.personName,
  });

  Map<String, dynamic> toJson() {
    return {
      "url": url,
      "username": username,
      "password": password,
      "personName": personName,
      "session_id": session_id,
    };
  }

  factory OdooAccountModule.fromJSON(Map<String, dynamic> json) {
    return OdooAccountModule(
      url: json["url"],
      username: json["username"],
      password: json["password"],
      personName: json["personName"],
      session_id: json["session_id"],
    );
  }

  OdooAccountModule copyWith(
    {
    String? session_id,
    String? password,
  }) {
    return OdooAccountModule(
      url: this.url,
      username: this.username,
      password: password ?? this.password,
      personName: this.personName,
      session_id: session_id ?? this.session_id,
    );
  }
}
