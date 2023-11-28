class WifiNetwork {
  final int id;
  final String ssid;

  WifiNetwork(
    this.id,
    this.ssid,
  );

  WifiNetwork.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        ssid = json['ssid'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'ssid': ssid,
      };
  @override
  String toString() {
    return '{$id, $ssid}';
  }
}
