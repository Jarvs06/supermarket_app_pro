import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'consumable_store.dart';

List<PurchaseDetails> purchases = [];
List<ProductDetails> products = [];
const bool kAutoConsume = true;
const String kConsumableId = '';
const String kUpgradeId = '';
const String kSilverSubscriptionId = '';
const String kGoldSubscriptionId = 'sa_one_year';
const List<String> _kProductIds = <String>[
  //kConsumableId,
  //kUpgradeId,
  //kSilverSubscriptionId,
  kGoldSubscriptionId,
];

class ProviderModel with ChangeNotifier {
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> subscription;
  List<String> notFoundIds = [];
  List<String> consumables = [];
  bool isAvailable = false;
  bool purchasePending = false;
  bool showPopUpT = false;
  bool loading = true;
  String? queryProductError;

  int count = 0;

  Future<void> getPurchaseStatus(bool knowStatus) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('getKnowStatus', knowStatus);
  }

  Future<void> getDate(String knowDate) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('getDateToday', knowDate);
  }

  Future<void> initInApp() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated = inAppPurchase.purchaseStream;
    subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    await initStoreInfo();
    await verifyPreviousPurchases();
  }
  Future<void> inAppStream() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated = inAppPurchase.purchaseStream;
    subscription = purchaseUpdated.listen((purchaseDetailsList) {

    }, onDone: () {
      subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });

  }
  verifyPreviousPurchases() async {
    await inAppPurchase.restorePurchases();
    await Future.delayed(const Duration(milliseconds: 100), () {
      for (var pur in purchases) {

        /* if (pur.productID.contains('non_consumable')) {
          removeAds = true;
          notifyListeners();
        }
        if (pur.productID.contains('SA_one_month')) {
          silverSubscription = true;
          notifyListeners();
        }*/

         if (pur.productID.contains('sa_one_year')) {
          goldSubscription = true;
          notifyListeners();
        }
      }

      finishedLoad = true;
    });
  }

  bool _removeAds = false;
  bool get removeAds => _removeAds;
  set removeAds(bool value) {
    _removeAds = value;
    notifyListeners();
  }

  bool _silverSubscription = false;
  bool get silverSubscription => _silverSubscription;
  set silverSubscription(bool value) {
    _silverSubscription = value;
    notifyListeners();
  }

  bool _goldSubscription = false;
  bool get goldSubscription => _goldSubscription;
  set goldSubscription(bool value) {
    _goldSubscription = value;
    notifyListeners();
  }

  bool _finishedLoad = false;
  bool get finishedLoad => _finishedLoad;
  set finishedLoad(bool value) {
    _finishedLoad = value;
    notifyListeners();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailableStore = await inAppPurchase.isAvailable();
    if (!isAvailableStore) {
      isAvailable = isAvailableStore;
      products = [];
      purchases = [];
      notFoundIds = [];
      consumables = [];
      purchasePending = false;
      loading = false;
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition = inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    ProductDetailsResponse productDetailResponse =
    await inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      queryProductError = productDetailResponse.error!.message;
      isAvailable = isAvailableStore;
      products = productDetailResponse.productDetails;
      purchases = [];
      notFoundIds = productDetailResponse.notFoundIDs;
      consumables = [];
      purchasePending = false;
      loading = false;
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      queryProductError = null;
      isAvailable = isAvailableStore;
      products = productDetailResponse.productDetails;
      purchases = [];
      notFoundIds = productDetailResponse.notFoundIDs;
      consumables = [];
      purchasePending = false;
      loading = false;
      return;
    }

    List<String> consumableProd = await ConsumableStore.load();
    isAvailable = isAvailableStore;
    products = productDetailResponse.productDetails;
    notFoundIds = productDetailResponse.notFoundIDs;
    consumables = consumableProd;
    purchasePending = false;
    loading = false;
    notifyListeners();
  }

  Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumableProd = await ConsumableStore.load();
    consumables = consumableProd;
    notifyListeners();
  }

  void showPendingUI() {
    purchasePending = true;
    notifyListeners();
  }


  void showThankYou() {
    showPopUpT = true;
    notifyListeners();
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    if (purchaseDetails.productID == kConsumableId) {
      await ConsumableStore.save(purchaseDetails.purchaseID!);
      List<String> consumableProd = await ConsumableStore.load();
      purchasePending = false;
      consumables = consumableProd;
    } else {
      purchases.add(purchaseDetails);
      purchasePending = false;
    }
  }

  void handleError(IAPError error) {
    purchasePending = false;
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();

      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);

        } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {

            deliverProduct(purchaseDetails);

            //var now = today.isBefore(newDate);
            //String dateStr = "${today.month}-${today.day}-${today.year}";

            if(purchaseDetails.status == PurchaseStatus.purchased){
              DateTime today = DateTime.now();
              var newDate = DateTime(today.year, today.month, today.day + 365);
              getDate(newDate.toString());

              getPurchaseStatus(true);
              showThankYou();

            }

          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!kAutoConsume && purchaseDetails.productID == kConsumableId) {
            final InAppPurchaseAndroidPlatformAddition androidAddition = inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await inAppPurchase.completePurchase(purchaseDetails);
          if (purchaseDetails.productID == 'consumable_product') {
            //print('================================You got coins');
          }

          verifyPreviousPurchases();
        }
      }
    });
  }

  Future<void> confirmPriceChange(BuildContext context) async {
    if (Platform.isAndroid) {
      final InAppPurchaseAndroidPlatformAddition androidAddition = inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      var priceChangeConfirmationResult = await androidAddition.launchPriceChangeConfirmationFlow(
        sku: 'purchaseId',
      );
      if (priceChangeConfirmationResult.responseCode == BillingResponse.ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Price change accepted'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            priceChangeConfirmationResult.debugMessage ??
                "Price change failed with code ${priceChangeConfirmationResult.responseCode}",
          ),
        ));
      }
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition = inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }

  GooglePlayPurchaseDetails? getOldSubscription(ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    GooglePlayPurchaseDetails? oldSubscription;
    if (productDetails.id == kSilverSubscriptionId && purchases[kGoldSubscriptionId] != null) {
      oldSubscription = purchases[kGoldSubscriptionId] as GooglePlayPurchaseDetails;
    } else if (productDetails.id == kGoldSubscriptionId && purchases[kSilverSubscriptionId] != null) {
      oldSubscription = purchases[kSilverSubscriptionId] as GooglePlayPurchaseDetails;
    }
    return oldSubscription;
  }

}


class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}