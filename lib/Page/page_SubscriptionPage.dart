import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supermarket_app_pro/Page/hardreload.dart';
import '../Widget/widget_Heading.dart';
import '../Widget/widget_ParagraphText.dart';
import '../Widget/widget_SubHeading.dart';
import '../providermodel.dart';
import 'page_HomePage.dart';

class SubscriptionPage extends StatefulWidget {

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool? showPopUp;
  late ProviderModel _appProvider;

  @override
  void initState() {
    setPurchaseDate();
    getPurchaseDate();

    final provider = Provider.of<ProviderModel>(context, listen: false);
    _appProvider = provider;
    inAppStream(provider);
    super.initState();
  }
  inAppStream(provider) async {
    await provider.inAppStream();
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

  String? checkDate;
  void getPurchaseDate() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    checkDate = preferences.getString('getDateToday');
    setState(() {});
  }

  Future<void> getPurchaseStatus(bool knowStatus) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('getKnowStatus', knowStatus);
  }
  void setPurchaseDate() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    showPopUp = preferences.getBool('getKnowStatus') ?? false;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderModel>(context);
    print("Subscription Page Status: ${provider.goldSubscription}");

    List<Widget> stack = [];
    if (provider.queryProductError == null) {
      stack.add(
        ListView(
          children: [
            _buildTitleTile(),
            _buildProductList(provider),
            _buildEarlyNotice(),
            _buildRestoreButton(provider),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(provider.queryProductError!),
      ));
    }
    if (provider.purchasePending) {
      stack.add(
        Stack(
          children: const [
            Opacity(
              opacity: 0.3,
              child: ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    // SUBSCRIPTION PAGE APP BAR
    return Scaffold(
      backgroundColor: const Color(0xFFEDE7CD),
      appBar: AppBar(
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back_ios),
          onTap: () {
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => const HardReload()));
          } ,
        ),
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
                textAlign: Platform.isIOS ? TextAlign.center : TextAlign.center,
              ),
            ]),
      ),
      body: Stack(
        children: stack,
      ),
    );
  }


  // SUBSCRIPTION PAGE HEADING
  Column _buildTitleTile() {
    return Column(
      children: const [
        SizedBox(height: 20,),
        HeadingText(text: "Subscription", alignment: TextAlign.center,),
        SizedBox(height: 15,),
      ],
    );
  }

  Visibility _buildEarlyNotice() {
    final provider = Provider.of<ProviderModel>(context);

    return Visibility(
      visible: checkDate == null && provider.showPopUpT == false
          ? true
          : false,
        child: const ParagraphText(text: "Note: Please restart the App after\npurchasing the Pro Version", alignment: TextAlign.center, color: Color(0xFf9c9c9c),)
    );
  }


  // SUBSCRIPTION PAGE RESTART NOTICE
  Visibility _buildRestartTile() {
    final provider = Provider.of<ProviderModel>(context);

      return Visibility(
        visible: checkDate == null && provider.showPopUpT == true
            ? true
            : false,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),),
          margin: const EdgeInsets.only(
              left: 10, top: 10, right: 10, bottom: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const Text(
                    "Successfully Purchased", textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SourceSans',
                    ),
                  ),
                  const SizedBox(height: 10,),
                  const SubHeadingText(
                      text: "Thank you for purchasing the PRO version. The App needs to restart. Click Continue",
                      alignment: TextAlign.center),
                  const SizedBox(height: 15,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50), // NEW
                        padding: const EdgeInsets.symmetric(vertical: 15)
                    ),
                    onPressed: () {
                      setState(() {
                        getPurchaseStatus(false);
                      });
                      Phoenix.rebirth(context);
                    },
                    child: const Text("Continue",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'SourceSans',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildRestoreButton(provider) {
    if (provider.loading) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // NEW
                padding: const EdgeInsets.symmetric(vertical: 15)
            ),
            child: const Text("Restore Purchase",
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'SourceSans',
              ),
            ),

            onPressed: () => provider.inAppPurchase.restorePurchases(),

          )
        ],
      ),
    );
  }

  Card _buildProductList(provider) {
    if (provider.loading) {
      return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
          margin: const EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 10),
          child: const ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              leading: CircularProgressIndicator(),
              title: Text('Fetching products...')));
    }
    if (!provider.isAvailable) {
      return const Card();
    }

    
    List<Card> productList = <Card>[];
    if (provider.notFoundIds.isNotEmpty) {
      productList.add(
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
            margin: const EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 10),
            elevation: 3,
            child: const ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                title: SubHeadingText(text:'No subscription found'),
                subtitle: Text('Our system is under maintenance. Please try again later.')),
          )
      );
    }


    Map<String, PurchaseDetails> purchasesIn = Map.fromEntries(purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        provider.inAppPurchase.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    productList.addAll(products.map((ProductDetails productDetails) {
        PurchaseDetails? previousPurchase = purchasesIn[productDetails.id];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),),
          margin: const EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 10),
          elevation: 3,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            title: HeadingText(text:productDetails.title, alignment: TextAlign.center,),
              subtitle: Column(
                children: [
                  const SizedBox(height: 10,),
                  ParagraphText(text:productDetails.description, alignment: TextAlign.center,),
                  const SizedBox(height: 20,),

                  previousPurchase != null
                      ? IconButton(
                      onPressed: () => provider.confirmPriceChange(context),
                      icon: const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 40,
                      ))
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50), // NEW
                            padding: const EdgeInsets.symmetric(vertical: 15)
                        ),
                        child: Text("Subscribe for ${productDetails.price}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'SourceSans',
                          ),
                        ),

                        onPressed: () {
                          late PurchaseParam purchaseParam;

                          if (Platform.isAndroid) {
                            final oldSubscription = provider.getOldSubscription(productDetails, purchasesIn);

                            purchaseParam = GooglePlayPurchaseParam(
                                productDetails: productDetails,
                                applicationUserName: null,
                                changeSubscriptionParam: (oldSubscription != null)
                                    ? ChangeSubscriptionParam(
                                  oldPurchaseDetails: oldSubscription,
                                  prorationMode: ProrationMode
                                      .immediateWithTimeProration,
                                )
                                    : null);
                          } else {
                            purchaseParam = PurchaseParam(
                              productDetails: productDetails,
                              applicationUserName: null,
                            );
                          }

                          if (productDetails.id == kConsumableId) {
                            provider.inAppPurchase.buyConsumable(
                                purchaseParam: purchaseParam,
                                autoConsume: kAutoConsume || Platform.isIOS);
                          } else {
                            provider.inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
                          }


                        },
                      )
                ],
              ),
          ),
        );
      },
    ));

    return Card(
        color: Colors.transparent,
        elevation: 0,
        child: Column(children: productList)
    );
  }
}