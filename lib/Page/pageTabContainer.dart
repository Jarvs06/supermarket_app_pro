import 'dart:io';
import 'package:flutter/material.dart';
import 'page_InputPage.dart';
import 'page_ScanPage.dart';
import 'page_SettingsPage.dart';

class PageTabContainer extends StatefulWidget {
  const PageTabContainer({Key? key}) : super(key: key);

  @override
  State<PageTabContainer> createState() => _PageTabContainerState();
}

class _PageTabContainerState extends State<PageTabContainer> {

  final textStyle = const TextStyle(
      fontSize: 12.0,
      color: Colors.white,
      fontFamily: 'OpenSans',
      fontWeight: FontWeight.w600);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          color: const Color(0xFFEDE7CD),
          child: const TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                InputPage(),
                ScanPage(),
                //SettingsPage(),
              ]),
        ),

        bottomNavigationBar: TabBar(
            labelColor: const Color(0xFF343434),
            labelStyle: textStyle.copyWith(
                fontSize: 15,
                color: const Color(0xFFc9c9c9),
                fontWeight: FontWeight.w700),
            unselectedLabelColor: const Color(0xFFc9c9c9),
            unselectedLabelStyle: textStyle.copyWith(
                fontSize: 15,
                color: const Color(0xFFc9c9c9),
                fontWeight: FontWeight.w700),
            indicatorColor: Colors.transparent,
            tabs: [
              Tab(
                height: Platform.isAndroid ? 85 : 95,
                child: Container(
                  padding: const EdgeInsets.only(top: 15),
                  child: Column(
                    children: const [
                      Icon(Icons.search, color: Color(0xFF0D3163), size: 34,),
                      Text("Search")
                    ],
                  ),
                ),
              ),

              Tab(
                height: Platform.isAndroid ? 85 : 95,
                child: Container(
                  padding: const EdgeInsets.only(top: 15),
                  child: Column(
                    children: const [
                      Icon(Icons.document_scanner, color: Color(0xFF0D3163), size: 34,),
                      Text("Scanner")
                    ],
                  ),
                ),
              ),

              /*Tab(
                height: Platform.isAndroid ? 85 : 95,
                child: Container(
                  padding: const EdgeInsets.only(top: 15),
                  child: Column(
                    children: const [
                      Icon(Icons.menu_rounded, color: Color(0xFF0D3163), size: 34,),
                      Text("More")
                    ],
                  ),
                ),
              ),*/


            ]),
      ),
    );
  }
}
