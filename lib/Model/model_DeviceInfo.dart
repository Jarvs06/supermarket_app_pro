class DeviceInfo {
  String deviceID;
  String subscription;

  DeviceInfo({required this.deviceID, required this.subscription});

  factory DeviceInfo.fromJson(Map<String, dynamic> json){
    return DeviceInfo(deviceID: json["device"], subscription: json["subs"]);
  }
}