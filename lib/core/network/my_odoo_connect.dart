import 'package:odoo_rpc/odoo_rpc.dart';

class MyOdooConnect {
  final OdooClient _odooClient;
  final String odooUrl;

  MyOdooConnect(this.odooUrl) : _odooClient = OdooClient(odooUrl);

  OdooClient get odooClient => _odooClient;
}
