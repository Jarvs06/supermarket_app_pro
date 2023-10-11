import 'dart:convert';
import 'dart:io' show Platform;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supermarket_app_pro/Widget/widget_NoticeText.dart';
import '../Function/AdsService.dart';
import '../Model/model_BannedProduct.dart';
import '../Widget/widget_Heading.dart';
import '../Widget/widget_ParagraphText.dart';
import '../Widget/widget_SubHeading.dart';
import '../providermodel.dart';

class InputPage extends StatefulWidget {


  const InputPage({Key? key}) : super(key: key);

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {

  String inputData = "";
  final textController = TextEditingController();

  String url = "https://source.partners/app-query-search/?api=E8rXHqKhwczv5Zf6mVJR!7&word=";

  String loopWordsURL = "";
  List<String> loopW = [];
  List<String> strResultArray = [];

  String requestURLQuery = "";

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdMobService.bannerAdUnitId!,
        listener: AdMobService.bannerAdListener,
        request: const AdRequest()
    )
      ..load();
    _createInterstitialAd();

  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null,
      ),
    );
  }
  void _showInterstitialAd() {
    if(_interstitialAd != null){
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _createInterstitialAd();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _createInterstitialAd();
          }
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderModel>(context);
    print("Input Page Status: ${provider.goldSubscription}");

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
            children: [

              const SizedBox(height: 20,),

              const Center(child: HeadingText(text: "Search"),),
              const Center(child: ParagraphText(text: "Search ingredients to see if \nit is unsafe (for products found in Supermarkets)", alignment: TextAlign.center,),),
              
              const SizedBox(height: 20,),

              TextField(
                controller: textController,
                decoration: InputDecoration(
                    hintText: "Enter Ingredient Name/Keyword",
                    hintStyle: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'SourceSans',
                        color: Color(0xFF595959)
                      ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: (){
                        textController.clear();
                        setState(() {
                          inputData = "";
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                ),
              ),

              const SizedBox(height: 15,),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50), // NEW
                    padding: const EdgeInsets.symmetric(vertical: 15)
                ),
                onPressed: (){
                  setState(() {
                    FocusManager.instance.primaryFocus?.unfocus();

                    inputData = textController.text;
                    getInputText(inputData.trim());

                    if (_interstitialAd != null && provider.goldSubscription == false){
                      _showInterstitialAd();
                    }
                  });
                },
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.search, size: 30,),
                      Text(
                        '   Get Result',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'SourceSans',
                        ),
                      ),
                    ]
                ),
              ),

              const SizedBox(height: 20,),

              if(inputData != "")
                Column(
                  children: [
                    const SubHeadingText(
                      text: "Unsafe Ingredients Results",
                      alignment: TextAlign.left,
                    ),

                    const SizedBox(height: 20,),

                    FutureBuilder(
                        future: getData(url+requestURLQuery),
                        builder: (context, data) {
                          switch(data.connectionState){
                            case ConnectionState.waiting:
                              return Column(
                                  children: const [
                                    SizedBox(height: 15,),
                                    Center(child: CircularProgressIndicator(),),
                                ]
                              );
                            default:
                              if(data.hasError){
                                return const Center(child: ParagraphText(text:"We are not able to find this ingredient in our Unsafe database", alignment: TextAlign.center,),);
                              }else{
                                var bannedProduct = data.data as List<InternetBannedProduct>;
                                return Column(
                                  children: [
                                    ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        primary: false,
                                        itemCount: bannedProduct.length,
                                        itemBuilder: (context, index) {
                                          return Card(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                                            margin: const EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 10),
                                            elevation: 3,
                                            child: ListTile(
                                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                              title: Text(bannedProduct[index].product,
                                                style: TextStyle(
                                                  fontFamily: Platform.isAndroid ? 'Gotham' : null,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Text(bannedProduct[index].reason,
                                                style: TextStyle(
                                                  fontFamily: Platform.isAndroid ? 'Gotham' : null,
                                                  fontSize: 14,
                                                ),
                                              ),

                                            ),
                                          );
                                        }
                                    ),

                                    const SizedBox(height: 10,),

                                    const NoticeText(text: "Note:  All concerns are for ingredients that are used long-term and in high doses i.e. years of use and over the limit of the FDA’s Acceptable Daily Intakes (ADI)",
                                      alignment: TextAlign.center,),

                                    const SizedBox(height: 20,),
                                  ],
                                );
                              }
                            }
                        }
                    ),

                  ],
                ),

              if (_bannerAd != null && provider.goldSubscription == false)
                Container(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd != null ? _bannerAd!.size.height.toDouble() : 0,
                  child: AdWidget(ad: _bannerAd!),
                ),

            ],
          ),
      ),

    );
  }

  void getInputText(String inputText) {
    strResultArray = inputText.split(",");
    loopW = strResultArray;
    loopWordsURL = loopW.join(',').toString().toLowerCase()
        .replaceAll(";", "")
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll("'", "")
        .replaceAll(".", "")
        .replaceAll("&", "%26")
        .replaceAll("#", "%23")
        .replaceAll(":", "");

    requestURLQuery = loopWordsURL.toString();

    setState((){});
  }

  Future<List<InternetBannedProduct>> getData(String queryURL) async {
    final response = await http.get(Uri.parse(queryURL));
    final body = json.decode(response.body);

    return body.map<InternetBannedProduct>(InternetBannedProduct.fromJson).toList();
  }


}