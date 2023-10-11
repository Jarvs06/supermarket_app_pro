import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'page_InputPage.dart';
import 'page_ScanPage.dart';
import 'page_SettingsPage.dart';

class PageContainer extends StatefulWidget {
  const PageContainer({Key? key}) : super(key: key);

  @override
  State<PageContainer> createState() => _PageContainerState();
}

class _PageContainerState extends State<PageContainer> {

   final List<Widget> pages = const [
    InputPage(),
    ScanPage(),
    //SettingsPage()
  ];

   int currentIndex = 0;
   void onTap (int index){
     setState(() {
       currentIndex = index;
     });
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE7CD),
      body: IndexedStack(index: currentIndex, children: pages,),
      bottomNavigationBar: SizedBox(
        height: Platform.isAndroid ? 70 : 100,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 50,
          type: BottomNavigationBarType.fixed,
          iconSize: 30,
          unselectedItemColor: Colors.grey.withOpacity(0.5),
          onTap: onTap,
          currentIndex: currentIndex,
          items: const [
            BottomNavigationBarItem(label: "Search", icon: Icon(Icons.search)),
            BottomNavigationBarItem(label: "Scan", icon: Icon(Icons.document_scanner)),
            //BottomNavigationBarItem(label: "More", icon: Icon(Icons.menu_rounded)),
          ],
        ),
      ),
    );
  }
}
