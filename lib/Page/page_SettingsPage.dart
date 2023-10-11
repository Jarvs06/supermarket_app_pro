import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supermarket_app_pro/Page/page_SubscriptionStatus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Function/AdsService.dart';
import '../Widget/widget_Heading.dart';
import '../Widget/widget_TextSettingsButton.dart';
import '../providermodel.dart';
import 'page_SubscriptionPage.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  BannerAd? _bannerAd;

  late ProviderModel _appProvider;
  String? version;

  @override
  void initState() {
    super.initState();
    getVersion();
    getPurchaseDate();

    final provider = Provider.of<ProviderModel>(context, listen: false);
    _appProvider = provider;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      initInApp(provider);
    });

    _bannerAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdMobService.bannerAdUnitId!,
        listener: AdMobService.bannerAdListener,
        request: const AdRequest()
    )
      ..load();

  }

  initInApp(provider) async {
    await provider.initInApp();
  }

  getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      var iosPlatformAddition = _appProvider.inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _appProvider.subscription.cancel();

    _bannerAd?.dispose();
    super.dispose();
  }

  String? checkDate;
  void getPurchaseDate() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    checkDate = preferences.getString('getDateToday');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderModel>(context);
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const SizedBox(height: 20,),

            Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: HeadingText(text: " More about"),
                ),

                const SizedBox(height: 10,),

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    color: const Color(0XFFEFEFEF),
                    child: Column(
                      children: [
                        TextSettingsButton(text: "Definitions", onPressed: () async {
                          String url = "https://source.partners/supermarket-app-pro/definitions";
                          if(Platform.isIOS){
                          if(await canLaunch(url)){
                            await launch(
                              url,
                              forceSafariVC: true,
                              forceWebView: true,
                              enableJavaScript: true,
                              enableDomStorage: true,
                              webOnlyWindowName: '_self',
                            );
                          }
                          }else {
                            if(await canLaunch(url)){
                            await launch(url);
                            }
                          }
                        }),

                        SizedBox(height: 1, child: Container(color: Colors.black, margin: const EdgeInsets.symmetric(horizontal: 15),),),

                        TextSettingsButton(text: "Limitations", onPressed: () async {
                          String url = "https://source.partners/supermarket-app-pro/limitations/";
                          if(Platform.isIOS){
                            if(await canLaunch(url)){
                              await launch(
                                url,
                                forceSafariVC: true,
                                forceWebView: true,
                                enableJavaScript: true,
                                enableDomStorage: true,
                                webOnlyWindowName: '_self',
                              );
                            }
                          }else {
                            if(await canLaunch(url)){
                              await launch(url);
                            }
                          }
                        }),

                        SizedBox(height: 1, child: Container(color: Colors.black, margin: const EdgeInsets.symmetric(horizontal: 15),),),

                        TextSettingsButton(text: "Visit our Website", onPressed: () async {
                          String url = "https://source.partners/";
                          if(Platform.isIOS){
                            if(await canLaunch(url)){
                              await launch(
                                url,
                                forceSafariVC: true,
                                forceWebView: true,
                                enableJavaScript: true,
                                enableDomStorage: true,
                                webOnlyWindowName: '_self',
                              );
                            }
                          }else {
                            if(await canLaunch(url)){
                               await launch(url);
                            }
                          }
                        }),

                        SizedBox(height: 1, child: Container(color: Colors.black, margin: const EdgeInsets.symmetric(horizontal: 15),),),

                        TextSettingsButton(text: "Privacy Policy", onPressed: () async {
                          String url = "https://source.partners/privacy/";
                          if(Platform.isIOS){
                            if(await canLaunch(url)){
                              await launch(
                                url,
                                forceSafariVC: true,
                                forceWebView: true,
                                enableJavaScript: true,
                                enableDomStorage: true,
                                webOnlyWindowName: '_self',
                              );
                            }
                            }else {
                              if(await canLaunch(url)){
                                 await launch(url);
                              }
                            }
                        }),

                        SizedBox(height: 1, child: Container(color: Colors.black, margin: const EdgeInsets.symmetric(horizontal: 15),),),

                        TextSettingsButton(text: "Terms and Conditions", onPressed: () async {
                          String url = "https://source.partners/terms/";
                          if(Platform.isIOS){
                            if(await canLaunch(url)){
                              await launch(
                                url,
                                forceSafariVC: true,
                                forceWebView: true,
                                enableJavaScript: true,
                                enableDomStorage: true,
                                webOnlyWindowName: '_self',
                              );
                            }
                          }else {
                            if(await canLaunch(url)){
                              await launch(url);
                              }
                            }

                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30,),

            Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: HeadingText(text: " Offer"),
                ),

                const SizedBox(height: 10,),

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    color: const Color(0XFFEFEFEF),
                    child: Column(
                      children: [

                        Visibility(
                          visible: checkDate == null ? true : false,
                          child: TextSettingsButton(text: "Subscribe to Pro version", onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SubscriptionPage()),
                            );
                          }),
                        ),

                        Visibility(
                          visible: checkDate == null ? true : false,
                            child: SizedBox(height: 1, child: Container(color: Colors.black, margin: const EdgeInsets.symmetric(horizontal: 15),),)),

                        TextSettingsButton(text: "Subscription Status", onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionStatus()));
                        }),

                      ],
                    ),
                  ),
                ),
              ],
            ),


            const SizedBox(height: 30,),

            Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: HeadingText(text: " About app"),
                ),

                const SizedBox(height: 10,),

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    color: const Color(0XFFEFEFEF),
                    child: Column(
                      children: [
                        TextSettingsButton(text: "Report a problem", onPressed: () async {
                          String url = "https://source.partners/contact-us/";
                          if(Platform.isIOS){
                            if(await canLaunch(url)){
                              await launch(
                                url,
                                forceSafariVC: true,
                                forceWebView: true,
                                enableJavaScript: true,
                                enableDomStorage: true,
                                webOnlyWindowName: '_self',
                              );
                            }
                          }else {
                            if(await canLaunch(url)){
                              await launch(url);
                            }
                          }
                        }),

                        SizedBox(height: 1, child: Container(color: Colors.black, margin: const EdgeInsets.symmetric(horizontal: 15),),),

                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("App Version",
                                style: TextStyle(
                                    fontSize: 20
                                ),),
                              Text(version == null ? "" : version.toString(),
                                style: const TextStyle(
                                    fontSize: 20
                                ),),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),


            if (_bannerAd != null && provider.goldSubscription == false)
              Container(
                margin: const EdgeInsets.only(top: 20),
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd != null ? _bannerAd!.size.height.toDouble() : 0,
                child: AdWidget(ad: _bannerAd!),
              ),


          ],
        ),
      ),
    );
  }
}
