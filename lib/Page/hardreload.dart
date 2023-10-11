import 'dart:io';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../providermodel.dart';
import 'page_HomePage.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

class HardReload extends StatefulWidget {
  const HardReload({Key? key}) : super(key: key);

  @override
  State<HardReload> createState() => _HardReloadState();
}

class _HardReloadState extends State<HardReload> {

  late ProviderModel _appProvider;

  @override
  void initState() {
    final provider = Provider.of<ProviderModel>(context, listen: false);
    _appProvider = provider;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      initInApp(provider);
    });

    super.initState();
  }

  initInApp(provider) async {
    await provider.initInApp();
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      var iosPlatformAddition = _appProvider.inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _appProvider.subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedSplashScreen(
      splash: const Center(
        child: CircularProgressIndicator(
          color: Colors.white
        ),
      ),
      backgroundColor: const Color(0xFF0D3163),
      duration: 100,
      nextScreen: const HomeContainer(),
    );
  }
}
