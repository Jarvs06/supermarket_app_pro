import 'dart:io' show Platform;
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supermarket_app_pro/providermodel.dart';
import 'Page/page_HomePage.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }

  runApp(Phoenix(
    child: ChangeNotifierProvider(
        create: (context) => ProviderModel(),
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Supermarket App Pro',
            theme: ThemeData(
                primaryColor: const Color(0XFF0D3163),
                primarySwatch: const MaterialColor(0xFF0D3163, <int, Color>{
                  50:  Color(0xFFe0e0e0),
                  100: Color(0xFFb3b3b3),
                  200: Color(0xFF808080),
                  300: Color(0xFF4d4d4d),
                  400: Color(0xFF262626),
                  500: Color(0xFF262626),
                  600: Color(0xFF000000),
                  700: Color(0xFF000000),
                  800: Color(0xFF000000),
                  900: Color(0xFF000000),
                })
            ),
            home: const SplashScreen(),
          )
      ),
  )
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  late ProviderModel _appProvider;
  String? version;

  @override
  void initState() {
    final provider = Provider.of<ProviderModel>(context, listen: false);
    _appProvider = provider;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      initInApp(provider);
    });

    getVersion();

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

  getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    setVersion(version.toString());
  }

  Future<void> setVersion(String version) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('getVersion', version);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderModel>(context);
    print("Subscription Splash Status: ${provider.goldSubscription}");

    return AnimatedSplashScreen(
      splash: Center(
        child: Column(
            children: [
              Container (
                  child: Image.asset('assets/images/super_logo.png', width: 320,)
              ),
            ],
          ),
      ),

      backgroundColor: const Color(0xFF0D3163),
      duration: 3000,
      splashTransition: SplashTransition.fadeTransition,
      splashIconSize: 200,
      nextScreen: const HomeContainer(),
    );
  }
}

