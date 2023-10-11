import 'dart:io';
import 'package:flutter/material.dart';
import '/Widget/widget_NavigationItemTitle.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationItemContainer extends StatelessWidget {

  final IconData icon;
  final String text;
  final String urlT;

  const NavigationItemContainer ({Key? key, required this.icon, required this.text, required this.urlT}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        ListTile(
          leading: Icon(icon),
          onTap: () async {
            String url = urlT;
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
          },
          title: NavigationItemTitle(text: text),
        ),
      ],
    );
  }
}
