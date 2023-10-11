import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:new_version/new_version.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supermarket_app_pro/Page/page_SubscriptionPage.dart';
import 'package:supermarket_app_pro/Page/page_SubscriptionStatus.dart';
import '../Widget/NavigationItemContainer.dart';
import '../Widget/widget_NavigationItemTitle.dart';
import '../providermodel.dart';
import 'pageContainer.dart';
import 'pageTabContainer.dart';

class HomeContainer extends StatefulWidget {
  const HomeContainer({Key? key}) : super(key: key);

  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {

  late StreamSubscription connection;
  var isDeviceConnected = false;
  bool isAlertSet = false;


  @override
  void initState() {
    super.initState();

    getConnectivity();
    getAds();

    final newVersion = NewVersion(
      iOSId: 'com.ingredients.supermarketAppPro',
      androidId: 'com.ingredients.supermarket_app_pro',
    );

    const simpleBehavior = true;

    if (simpleBehavior) {
      basicStatusCheck(newVersion);
    }
  }

  getConnectivity() =>
      connection = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
        isDeviceConnected = await InternetConnectionChecker().hasConnection;
        if (!isDeviceConnected && isAlertSet == false) {
          if (Platform.isAndroid) {
            showDialogBoxA();
          } else {
            showDialogBoxI();
          }
          setState(() => isAlertSet = true);
        }
      });

  @override
  void dispose() {
    connection.cancel();
    super.dispose();
  }

  showDialogBoxI() {
    showCupertinoDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            CupertinoAlertDialog(
              title: const Text("No Connection"),
              content: const Text("Please check your internet connectivity"),
              actions: [
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context, 'Cancel');
                      setState(() => isAlertSet = false);
                      isDeviceConnected =
                      await InternetConnectionChecker().hasConnection;
                      if (!isDeviceConnected) {
                        showDialogBoxI();
                        setState(() => isAlertSet = true);
                      }
                    },
                    child: const Text("OK"))
              ],
            )
    );
  }

  showDialogBoxA() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) =>
            AlertDialog(
              title: const Text("No Connection"),
              content: const Text("Please check your internet connectivity"),
              actions: [
                TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx, 'Cancel');
                      setState(() => isAlertSet = false);
                      isDeviceConnected =
                      await InternetConnectionChecker().hasConnection;
                      if (!isDeviceConnected) {
                        showDialogBoxA();
                        setState(() => isAlertSet = true);
                      }
                    },
                    child: const Text("OK"))
              ],
            )
    );
  }

  getAds() async {await MobileAds.instance.initialize();}

  basicStatusCheck(NewVersion newVersion) {
    newVersion.showAlertIfNecessary(context: context);
  }

  advancedStatusCheck(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      newVersion.showUpdateDialog(
          context: context,
          versionStatus: status,
          dismissAction: (){
            SystemNavigator.pop();
          }
      );
    }
  }


  Future<void> getPurchaseStatus(bool knowStatus) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('getKnowStatus', knowStatus);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderModel>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 75,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.only(top: 5, right: 8),
                child: Image.asset('assets/images/fav.png', width: 22,)
            ),

            const Text.rich(
              TextSpan(children: [
                TextSpan(text: "Supermarket App Pro", style: TextStyle(fontSize: 25, fontFamily: 'SourceSans',),),
                //TextSpan(text: "\nby Source Partners", style: TextStyle(fontSize: 18, fontFamily: 'SourceSans',),),
              ],),
              textAlign: TextAlign.center,
            ),
        ]),
      ),

      body: const PageTabContainer(),

      drawer: const NavigationDrawer(),
    );
  }
}


class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  String? version;
  void setVersion() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    version = preferences.getString('getVersion');
    setState(() {});
  }

  String? checkDate;
  void getPurchaseDate() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    checkDate = preferences.getString('getDateToday');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    setVersion();
    getPurchaseDate();
  }

  @override
  Widget build(BuildContext context) =>
      Drawer(
        child: SingleChildScrollView(
          child: Container(
            color: const Color(0XFF0D3163),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildHeader(context),
                buildItemMenu(context),
              ],
            ),
          ),
        ),
      );

  Widget buildHeader(BuildContext context) =>
      Container(
        color: const Color(0XFF0D3163),
        padding: EdgeInsets.only(top: 18 + MediaQuery.of(context).padding.top, bottom: 24),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:[
              Container(
                  margin: const EdgeInsets.only(top: 5, right: 8),
                  child: Image.asset('assets/images/fav.png', width: 20,)
              ),

              const Text.rich(
              TextSpan(children: [
                TextSpan(text: "Supermarket App Pro", style: TextStyle(fontSize: 22, fontFamily: 'SourceSans', color: Colors.white),),
                //TextSpan(text: "\nby Source Partners", style: TextStyle(fontSize: 16, fontFamily: 'SourceSans', color: Colors.white),),
              ],),
              textAlign: TextAlign.center,
            ),
          ]),
      );

  Widget buildItemMenu(BuildContext context) =>
      Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 20,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text("More about",
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'SourceSans',
                    fontWeight: FontWeight.w500,),
                ),
              ),
            ),
            const SizedBox(height: 5,),
            const NavigationItemContainer(icon: Icons.chevron_right_sharp, text: "References", urlT: "https://source.partners/supermarket-app-pro/references/"),
            const NavigationItemContainer(icon: Icons.chevron_right_sharp, text: "Definitions", urlT: "https://source.partners/supermarket-app-pro/definitions/"),
            const NavigationItemContainer(icon: Icons.chevron_right_sharp, text: "Limitations", urlT: "https://source.partners/supermarket-app-pro/limitations/"),
            const NavigationItemContainer(icon: Icons.chevron_right_sharp, text: "Disclaimer", urlT: "https://source.partners/disclaimer/"),
            const NavigationItemContainer(icon: Icons.chevron_right_sharp, text: "Visit Website", urlT: "https://source.partners/"),
            const NavigationItemContainer(icon: Icons.chevron_right_sharp, text: "Privacy Policy", urlT: "https://source.partners/privacy/"),
            const NavigationItemContainer(icon: Icons.chevron_right_sharp, text: "Terms and Conditions", urlT: "https://source.partners/privacy/"),
            const Divider(),

            const SizedBox(height: 20,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text("Offer",
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'SourceSans',
                    fontWeight: FontWeight.w500,),
                ),
              ),
            ),
            const SizedBox(height: 5,),
            Visibility(
              visible: checkDate == null ? true : false,
              child: Column(
                children: [
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.chevron_right_sharp),
                    title: const NavigationItemTitle(
                        text: "Subscribe to Pro Version"),
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) => SubscriptionPage()));
                    },
                  ),
                ],
              ),
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.chevron_right_sharp),
              title: const NavigationItemTitle(text: "Subscription Status"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const SubscriptionStatus()));
              },
            ),
            const Divider(),

            const SizedBox(height: 20,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text("About App",
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'SourceSans',
                    fontWeight: FontWeight.w500,),
                ),
              ),
            ),

            const SizedBox(height: 5,),
            const NavigationItemContainer(icon: Icons.chevron_right_sharp, text: "Quick Fixes (FAQs)", urlT: "https://source.partners/quick-fixes-faqs/"),
            const NavigationItemContainer(icon: Icons.chevron_right_sharp, text: "Report a problem", urlT: "https://source.partners/contact-us/"),
            const Divider(),

            ListTile(
              title: const NavigationItemTitle(text: "App Version"),
              trailing: NavigationItemTitle(text: version == null ? "" : version.toString()),
            ),
            const Divider(),
          ],
        ),
      );
  }
