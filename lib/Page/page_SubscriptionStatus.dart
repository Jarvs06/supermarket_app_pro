import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Function/AdsService.dart';
import '../Widget/widget_Heading.dart';
import '../providermodel.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

class SubscriptionStatus extends StatefulWidget {
  const SubscriptionStatus({Key? key}) : super(key: key);

  @override
  State<SubscriptionStatus> createState() => _SubscriptionStatusState();
}

class _SubscriptionStatusState extends State<SubscriptionStatus> {

  BannerAd? _bannerAd;
  late ProviderModel _appProvider;

  @override
  void initState() {
    _bannerAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdMobService.bannerAdUnitId!,
        listener: AdMobService.bannerAdListener,
        request: const AdRequest()
    )
      ..load();

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

    _bannerAd?.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEDE7CD),
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

              Text.rich(
                const TextSpan(children: [
                  TextSpan(text: "Supermarket App Pro", style: TextStyle(fontSize: 25, fontFamily: 'SourceSans',),),
                  //TextSpan(text: "\nby Source Partners", style: TextStyle(fontSize: 18, fontFamily: 'SourceSans',),),
                ],),
                textAlign: Platform.isIOS ? TextAlign.center : TextAlign.start,
              ),
            ]),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 20,),
          const HeadingText(text: "Subscription Status", alignment: TextAlign.center,),
          const SizedBox(height: 15,),
          const Divider(),
          const SizedBox(height: 15,),
          const Text('1 Year Subscription',
            style: TextStyle(
              fontSize: 26,
              fontFamily: 'SourceSans',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10,),
          Text(
            provider.goldSubscription
                ? 'You are currently subscribe for 1 year.'
                : 'You are currently not yet subscribe for 1 year.',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'SourceSans',
              color: provider.goldSubscription ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 30,),

          if (_bannerAd != null && provider.goldSubscription == false)
            Container(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd != null ? _bannerAd!.size.height.toDouble() : 0,
              child: AdWidget(ad: _bannerAd!),
            ),


        ],
      ),
    );
  }

}
