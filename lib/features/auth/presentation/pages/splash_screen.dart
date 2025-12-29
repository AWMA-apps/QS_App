import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quantum_space/features/auth/presentation/provider/account_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkLastSignedAccount();
  }

  void _checkLastSignedAccount() async{
    final account =await ref.read(accountsProvider.notifier).getLastActiveAccount();
    if(!mounted) return;
    if(account !=null){
      context.pushReplacement("/inappwebview",extra: account);
    }else{
      context.pushReplacement("/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Center(
          child: Image.asset("assets/images/odoo_logo.png", width: 120),
        ),
      ),
    );
  }
}
