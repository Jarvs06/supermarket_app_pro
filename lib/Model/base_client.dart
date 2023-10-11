import 'package:http/http.dart' as http;

const String baseUrl = "https://source.partners/current-user/?api=E8rXHqKhwczv5Zf6mVJR!7&deviceid=";
const String baseUrlSub = "https://source.partners/user-subscription/?api=E8rXHqKhwczv5Zf6mVJR!7&deviceid=";

class BaseClients {
  var client = http.Client();

  Future<dynamic> get(String request) async {
    var url = Uri.parse(baseUrl + request);
    var response = await client.get(url);
    return response.body;
  }

  Future<dynamic> sub(String request) async {
    var url = Uri.parse(baseUrlSub + request);
    var response = await client.get(url);
    return response.body;
  }
}