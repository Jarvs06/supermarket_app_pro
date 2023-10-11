import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String? get bannerAdUnitId {
    if(Platform.isAndroid){
      return 'ca-app-pub-5344220072540545/4488894099';
    }else if (Platform.isIOS){
      return 'ca-app-pub-5344220072540545/9002854173';
      //return 'ca-app-pub-3940256099942544/2934735716';
    }

    return null;
  }

  static String? get interstitialAdUnitId {
    if(Platform.isAndroid){
      return 'ca-app-pub-5344220072540545/1671159065';
    }else if (Platform.isIOS){
      return 'ca-app-pub-5344220072540545/8811282484';
      //return 'ca-app-pub-3940256099942544/4411468910';
    }

    return null;
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => debugPrint('Ad loaded.'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint('Ad failed to load: $error');
    },
    onAdOpened: (ad) => debugPrint('Ad opened.'),
    onAdClosed: (ad) => debugPrint('Ad closed.'),
  );
}