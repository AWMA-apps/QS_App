// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get server_address => 'عنوان الخادم';

  @override
  String get username => 'اسم المستخدم/البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get or_select_another_account => 'أو اختر حساب آخر';

  @override
  String get no_accounts_left => 'لا يوجد حسابات بعد';

  @override
  String get server_is_required => 'عنوان الخادم مطلوب';

  @override
  String get username_is_required => 'ادخل اسم المستخدم او البريد الالكتروني';

  @override
  String get password_is_required => 'ادخل كلمة المرور';

  @override
  String get press_back_again_to_exit => 'اضغط مرة اخرى للخروج';

  @override
  String get re_login => 'سجل دخول';

  @override
  String get open => 'OPEN';

  @override
  String get file_saved_in_downloads_folder =>
      'File saved in Download/Quantum Space folder';
}
