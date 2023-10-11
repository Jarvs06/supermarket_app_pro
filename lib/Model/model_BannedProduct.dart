import 'dart:convert';
import 'package:http/http.dart' as http;

class InternetBannedProduct {
  final String product;
  final String reason;

  const InternetBannedProduct({
    required this.product,
    required this.reason,
  });

  static InternetBannedProduct fromJson(json) => InternetBannedProduct(
      product: json['product'],
      reason: json['reason']
  );
}

Future<List<InternetBannedProduct>> getData(String queryURL) async {
  final response = await http.get(Uri.parse(queryURL));
  final body = json.decode(response.body);

  return body.map<InternetBannedProduct>(InternetBannedProduct.fromJson).toList();
}