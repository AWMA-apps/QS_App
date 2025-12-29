import 'package:equatable/equatable.dart';

class OdooAccount extends Equatable {
  final String url;
  final String username;
  final String password;
  final String session_id;
  final String personName;

  const OdooAccount({
    required this.url,
    required this.username,
    required this.password,
    required this.session_id,
    required this.personName,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [url, username, session_id];

}
