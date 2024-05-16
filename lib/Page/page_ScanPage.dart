import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supermarket_app_pro/Widget/widget_NoticeText.dart';
import '../Model/model_BannedProduct.dart';
import '../Widget/widget_Heading.dart';
import '../Widget/widget_ParagraphText.dart';
import '../Widget/widget_SubHeading.dart';
import '../providermodel.dart';
import 'page_SubscriptionPage.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {

  bool clear = true;
  bool textScanning = false;
  bool showScanner = false;
  String scannedText = "";
  String scannedText2 = "";
  String scannedTextNextLine = "";
  File? imageFile;

  String url = "https://source.partners/app-query/?api=E8rXHqKhwczv5Zf6mVJR!7&word=";

  String loopWordsURL = "";
  List<String> loopW = [];
  List<String> strResultArray = [];

  String loopWordsURLNextL = "";
  List<String> loopWNextL = [];
  List<String> strResultArrayNextL = [];

  String requestURLQuery = "";
  String requestURLNextLQuery = "";

  @override
  void initState() {
    super.initState();
    setPurchaseDate();
    _getRequests();
  }

  String? checkDate;
  void setPurchaseDate() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    checkDate = preferences.getString('getDateToday');
    setState(() {});
  }

  _getRequests()async{}

  Future<void> getDate(String knowDate) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('getDateToday', knowDate);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderModel>(context);
    print("Scan Page Status: ${provider.goldSubscription}");

    DateTime today = DateTime.now();
    DateTime setDate;
    bool isSubscribed = false;

    var martin;

    //checkDate local database date

    if(checkDate != null) { //check if checkDate is not null, get check date and check if not expired
      setDate = DateTime.parse(checkDate!);
      isSubscribed = today.isBefore(setDate); //check if not expired
        if(isSubscribed){
          //force show scanner
          showScanner = true;
          martin = 1;
        }
        else {
          //not subscribe or expired
          showScanner = false;
          martin = 2;
        }
    }
    else if(provider.goldSubscription == false && checkDate != null){
      //delete date in local database
      getDate("");
      showScanner = false;
      martin = 5;


    }
    else if(provider.goldSubscription == true && checkDate == null){
      //save date to local database
      DateTime today = DateTime.now();
      var newDate = DateTime(today.year, today.month, today.day + 365);
      getDate(newDate.toString());

      //force show scanner
      showScanner = true;
      martin = 3;
    }
    else {
      showScanner = false;
      martin = 4;
    }


    return showScanner == true
        ? SingleChildScrollView(
              child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      const SizedBox(height: 20,),

                      const Center(child: HeadingText(text: "Scan Image"),),
                      const Center(child: ParagraphText(text: "Ensure image is clear and visible"),),

                      const SizedBox(height: 20,),

                      if(imageFile == null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.white,
                          child: const Center(
                              child: Icon(Icons.image, color: Color(0xFFe3e3e3), size: 80,)
                          ),
                        ),
                      ),

                      if(imageFile != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.white,
                            child: Center(
                              child: Image.file(File(imageFile!.path), fit: BoxFit.cover,),
                            ),
                          ),
                        ),

                      if(imageFile == null && clear == true)
                        Column(
                          children: [
                            const SizedBox(height: 20,),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50), // NEW
                                  padding: const EdgeInsets.symmetric(vertical: 15)
                              ),
                              onPressed: () => getImageFromSource(ImageSource.camera),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.camera_alt_rounded, size: 30,),
                                    Text(
                                      '   Camera',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'SourceSans',
                                      ),
                                    ),
                                  ]
                              ),
                            ),

                            const SizedBox(height: 10,),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50), // NEW
                                  padding: const EdgeInsets.symmetric(vertical: 15)
                              ),
                              onPressed: () => getImageFromSource(ImageSource.gallery),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.photo_rounded, size: 30,),
                                    Text(
                                      '   Gallery',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'SourceSans',
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 20,),

                      if(imageFile != null)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50), // NEW
                              padding: const EdgeInsets.symmetric(vertical: 10)
                          ),
                          onPressed: () {setState(() {imageFile = null;});},
                          child: const Text('Clear', style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'SourceSans',
                          ),
                          ),
                        ),

                      if(imageFile != null)
                        Column(
                          children: [
                            const SizedBox(height: 20),

                            const SubHeadingText(text: "Ingredients of Concern"),

                            const SizedBox(height: 10),

                            FutureBuilder(
                                future: getData(url+requestURLQuery+","+requestURLNextLQuery),
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
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 15,),
                                              ParagraphText(
                                                  text: requestURLQuery == ""
                                                  ? "Unable to read label, please crop image or use text-input"
                                                  : "We are not able to find any unsafe ingredients on this label*\n\n*Use text-input for a more precise result"
                                                  , alignment: TextAlign.center),
                                            ],
                                          ),
                                        );
                                      }else{
                                        var bannedProduct = data.data as List<InternetBannedProduct>;
                                        return Column(
                                          children:[
                                            const ParagraphText(text: "Below are ingredients of concern found in this product", alignment: TextAlign.center,),

                                            const SizedBox(height: 15,),

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

                                            const SizedBox(height: 20,),

                                            const NoticeText(text: "This is a text-based scan result. It will show all ingredients (sometimes, multiple times) that are present on the ingredient list.",
                                              alignment: TextAlign.center,),

                                            const SizedBox(height: 20,),

                                            const Divider(indent: 140, endIndent: 140,),

                                            const SizedBox(height: 20,),

                                            const NoticeText(text: "Note: All concerns are for ingredients that are used long-term and in high doses i.e. years of use and over the limit of the FDA’s Acceptable Daily Intakes (ADI)",
                                            alignment: TextAlign.center,),

                                            const SizedBox(height: 30,),
                                          ]

                                        );
                                      }
                                  }
                                }
                            ),

                          ],
                        ),

                    ],
                  ),
              ),
        )

        : Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 15),
              child: Column(
                children: [
                  const ParagraphText(text:"Subscription (\$4.99/yearly) is required to access this feature" , alignment: TextAlign.center,),
                  const SizedBox(height: 15,),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50), // NEW
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) => SubscriptionPage()));
                    },
                    child: const Text("Subscribe Now!",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'SourceSans',
                      ),
                    ),
                  ),

                ],
              ),
            ),
          );
  }


  void getImageFromSource (ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;

        File? cropImg = File(pickedImage.path);
        cropImg = await cropImage(cropImg);

        setState(() { imageFile = cropImg; });
        getRecognizedText(cropImg!);
      }
    }catch(e) {}
  }


  Future<File?> cropImage (File imageFile) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(sourcePath: imageFile.path);
    if(croppedImage == null) return null;
    return File(croppedImage.path);
  }

  void getRecognizedText(File image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    scannedText = "";
    scannedText2 = "";

    for(TextBlock block in recognizedText.blocks){
      for (TextLine line in block.lines){
        scannedText += line.text + " ";
        scannedText2 += line.text + "\n";
      }
    }

    strResultArray = scannedText.split(",");
    loopW = strResultArray;
    loopWordsURL = loopW.join(',').toString().toLowerCase()
        .replaceAll(";", ",")
        .replaceAll("'", "%27")
        .replaceAll("(", "%28")
        .replaceAll(")", "%29")
        .replaceAll("&", "%26")
        .replaceAll("#", "%23")
        .replaceAll(":", ",");

    requestURLQuery = loopWordsURL.toString();

    strResultArrayNextL = scannedText2.split("\n");
    loopWNextL = strResultArrayNextL;
    loopWordsURLNextL = loopWNextL.join(',').toString().toLowerCase()
        .replaceAll(";", ",")
        .replaceAll("'", "%27")
        .replaceAll("(", "%28")
        .replaceAll(")", "%29")
        .replaceAll("&", "%26")
        .replaceAll("#", "%23")
        .replaceAll(":", ",");

    requestURLNextLQuery = loopWordsURLNextL.toString();

    setState((){});

    textScanning = false;

  }

  Future<List<InternetBannedProduct>> getData(String queryURL) async {
    final response = await http.get(Uri.parse(queryURL));
    final body = json.decode(response.body);

    return body.map<InternetBannedProduct>(InternetBannedProduct.fromJson).toList();
  }
}