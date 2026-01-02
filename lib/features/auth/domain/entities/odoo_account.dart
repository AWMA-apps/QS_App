
import 'package:equatable/equatable.dart';

class OdooAccount extends Equatable {
  final String url;
  final String username;
  final String password;
  final String sessionId;
  final String personName;
  final int uid;

  const OdooAccount({
    required this.url,
    required this.username,
    required this.password,
    required this.sessionId,
    required this.personName,
    required this.uid,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [url, username, sessionId];

}
