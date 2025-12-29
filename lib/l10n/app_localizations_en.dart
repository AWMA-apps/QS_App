// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get server_address => 'Server Address';

  @override
  String get username => 'Email/Username';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get or_select_another_account => 'Or select another account';

  @override
  String get no_accounts_left => 'No accounts left';

  @override
  String get server_is_required => 'Server Address is Required';

  @override
  String get username_is_required => 'Email/Username is Required';

  @override
  String get password_is_required => 'Password is Required';

  @override
  String get press_back_again_to_exit => 'Press back again to exit';

  @override
  String get re_login => 'Re-login';

  @override
  String get open => 'OPEN';

  @override
  String get file_saved_in_downloads_folder =>
      'File saved in Download/Quantum Space folder';
}
