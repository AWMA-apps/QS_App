import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum_space/core/network/my_odoo_connect.dart';

class MyCoreProviders {
  final odooConnectProvider = Provider<MyOdooConnect>((ref) => MyOdooConnect("odooUrl"),);
}