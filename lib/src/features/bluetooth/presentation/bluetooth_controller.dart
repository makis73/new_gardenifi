import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/constants/bluetooth_constants.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/data/bluetooth_repository.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/domain/wifi_network.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/domain/wifi_networks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothController extends StateNotifier<AsyncValue<BluetoothDevice?>> {
  BluetoothController(this.bluetoothRepository) : super(const AsyncValue.data(null));

  final BluetoothRepository bluetoothRepository;

  BluetoothDevice? device;

  BluetoothService? service;

  BluetoothCharacteristic? mainCharacteristic;

  BluetoothCharacteristic? statusCharacteristic;

  late StreamSubscription<List<ScanResult>> _scanSubscription;

  Future<void> startScan() async => await bluetoothRepository.startScan();

  @override
  void dispose() {
    _scanSubscription.cancel();
    super.dispose();
  }

  Future<void> startScanStream() async {
    // Sent to widget a loading value
    state = const AsyncValue.loading();
    // Start coundown 10 seconds. If device not found return to widget a false value
    // TODO: Change the timer to 10 - 15 seconds
    final timer = Timer(const Duration(seconds: 5), () async {
      await bluetoothRepository.stopScan();
      state = const AsyncData(null);
    });

    // Start listening for devices
    _scanSubscription = bluetoothRepository.scanStream.listen(
      (results) async {
        if (results.isNotEmpty) {
          ScanResult result = results.last;
          // If device found: stop countdown, stop scan, cancel subscription, connect device and sent to widget the device
          if (result.device.platformName == DEVICE_NAME) {
            device = result.device;
            timer.cancel();
            await _scanSubscription.cancel();
            await bluetoothRepository.stopScan();
            await bluetoothRepository.connectDevice(device!);
            state = AsyncValue<BluetoothDevice>.data(device!);
          }
        }
      },
    );
  }

  Future<void> stopScan() async => await bluetoothRepository.stopScan();

  Future<void> connectDevice(BluetoothDevice device) async =>
      await bluetoothRepository.connectDevice(device);

  Stream<BluetoothConnectionState> watchConnectionChanges() =>
      bluetoothRepository.connectionStateGhanges(device!);

  Future<BluetoothCharacteristic?> fetchServices() async {
    var services = await bluetoothRepository.discoverServices(device!);
    for (var service in services) {
      if (service.uuid.toString() == SERVICE_UUID) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            log('Characteristic found!');
            mainCharacteristic = characteristic;
          }
          if (characteristic.uuid.toString() == STATUS_CHARASTERISTIC_UUID) {
            statusCharacteristic = characteristic;
            log('statusCharacteristic = $statusCharacteristic');
          }
        }
      }
    }
    return mainCharacteristic;
    //TODO: What if characteristic not found?
  }

  // call repository to read data from device
  Future<List<int>> readFromDevice(BluetoothCharacteristic char) async {
    if (mainCharacteristic != null) {
      var response = await bluetoothRepository.readFromCharacteristic(char);
      log('Read: ${String.fromCharCodes(response)}');
      return response;
    } else {
      log('Error while reading');
      return [];
    }
  }

  // call repository to write data to device
  Future<void> writeToDevice(String data) async {
    List<int> formatedData = utf8.encode(data);
    if (mainCharacteristic != null) {
      await bluetoothRepository.writeToCharacteristic(mainCharacteristic!, formatedData);
    } else {
      log('Error while writing');
    }
  }

  // Read networks from device
  Future<List<WifiNetwork>> fetchNetworks(
      BluetoothCharacteristic targetCharacteristic) async {
    log('fetchNetworks called');
    List<WifiNetwork> listOfWifiNetwork = [];
    List<int> page1response = [];

    // request 1st page
    var i = 1;
    var newRequest = '{"page": "$i"}';
    // send request to device
    await writeToDevice(newRequest);
    // read the response from device
    page1response = await readFromDevice(mainCharacteristic!);
    log('page1 length: ${page1response.length}');
    String stringOfWifis = String.fromCharCodes(page1response);
    log('stringOfWifis_1=$stringOfWifis');
    var networksFromJson = WifiNetworks.fromJson(stringOfWifis);
    log('pages: ${networksFromJson.pages}');
    listOfWifiNetwork += networksFromJson.nets;

    // TODO: WTF is doing this here?
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('hwId', networksFromJson.hwId);
    prefs.setString('mqtt_host', networksFromJson.mqttBroker.host);
    prefs.setInt('mqtt_port', networksFromJson.mqttBroker.port);
    prefs.setString('mqtt_user', networksFromJson.mqttBroker.user);
    prefs.setString('mqtt_pass', networksFromJson.mqttBroker.pass);

    // if there are more than one pages request them
    var pages = networksFromJson.pages;

    for (int i = 2; i <= pages; i++) {
      log('Request for page $i');
      var newRequest = '{"page": "$i"}';
      await writeToDevice(newRequest);

      List<int> newResponse = await readFromDevice(mainCharacteristic!);
      String stringOfWifis = String.fromCharCodes(newResponse);
      log('stringOfWifisPage$i = $stringOfWifis');

      var networksFromJson = WifiNetworks.fromJson(stringOfWifis);
      listOfWifiNetwork += networksFromJson.nets;
    }
    return listOfWifiNetwork;
  }

  Future<String> sendNetworkCredentialsToDevice(String ssid, String password) async {
    print('sendnetworks called');
    Map<String, String> data = {'ssid': ssid, "wifi_key": password};
    String jsonData = json.encode(data);
    await writeToDevice(jsonData);
    log('send credentials');
    var response = await readFromDevice(statusCharacteristic!);
    log('waiting for response');
    print('response from sending nets: ${String.fromCharCodes(response)}');
    return String.fromCharCodes(response);
  }
}

//-------------> PROVIDERS <--------------//

// / The provider of the BluetoothController class
final bluetoothControllerProvider =
    StateNotifierProvider<BluetoothController, AsyncValue<BluetoothDevice?>>((ref) {
  final bluetoothRepository = ref.watch(bluetoothRepositoryProvider);
  return BluetoothController(bluetoothRepository);
});

// The provider that watch the connection of the device
final connectionProvider = StreamProvider.autoDispose<BluetoothConnectionState>((ref) {
  final connectionStream =
      ref.watch(bluetoothControllerProvider.notifier).watchConnectionChanges();
  return connectionStream;
});

final wifiNetworksFutureProvider =
    FutureProvider.autoDispose<List<WifiNetwork>>((ref) async {
  // read characteristic and then ask for networks
  final char = await ref.watch(bluetoothControllerProvider.notifier).fetchServices();
  // TODO: What if characteristic not found?
  return ref.watch(bluetoothControllerProvider.notifier).fetchNetworks(char!);
});

final wifiConnectionStatusProvider = FutureProvider.family<String, WifiNetwork>((ref, network) async {
  return ref.read(bluetoothControllerProvider.notifier).sendNetworkCredentialsToDevice(network.ssid, network.password!);
});
