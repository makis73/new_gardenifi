import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
import 'package:new_gardenifi_app/src/common_widgets/button_placeholder.dart';
import 'package:new_gardenifi_app/src/common_widgets/error_message_widget.dart';
import 'package:new_gardenifi_app/src/common_widgets/no_bluetooth_widget.dart';
import 'package:new_gardenifi_app/src/common_widgets/progress_widget.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/data/bluetooth_repository.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/bluetooth_controller.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/connection_lost_widget.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/widgets/error_fetching_networks_widget.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/widgets/refresh_networks_button.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/widgets/wait_while_fetching_widget.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class WiFiSetupScreen extends ConsumerStatefulWidget {
  const WiFiSetupScreen(this.device, {super.key});

  final BluetoothDevice device;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WiFiSetupScreenState();
}

class _WiFiSetupScreenState extends ConsumerState<WiFiSetupScreen> {
  // Future<void> fetchCharacteristic() async {
  //   final char = ref.watch(characteristicProvider).value;

  //   setState(() {
  //     characteristic = char;
  //   });
  // }

  String _currentSelectedValue = '';

  void dropdownCallback(String? selectedValue) {
    setState(() {
      _currentSelectedValue = selectedValue!;
    });
  }

  void rebuildWidget() {
    ref.invalidate(wifiNetworksFutureProvider);
    setState(() {
      _currentSelectedValue = '';
    });
  }

  @override
  void initState() {
    // fetchCharacteristic();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log('*** Build called');

    /// Variable that watch the state of the bluetooth adapter
    final bluetoothAdapterProvider = ref.watch(bluetoothAdapterStateStreamProvider);

    /// Variable that watch the state of the bluetooth connection
    final connectionState = ref.watch(connectionProvider);

    final bool isBluetoothOn =
        bluetoothAdapterProvider.value == BluetoothAdapterState.on ? true : false;

    final bool isConnected =
        connectionState.value == BluetoothConnectionState.connected ? true : false;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final radius = screenHeight / 4;

    // final char = ref.watch(characteristicProvider).value;
    // log('characteristic= $char');

    final nets = ref.watch(wifiNetworksFutureProvider);

    log('From widget: nets = $nets');

    return Scaffold(
      backgroundColor: const Color.fromARGB(229, 255, 255, 255),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                BluetoothScreenUpper(
                    radius: radius, showMenuButton: true, logoInTheRight: true),
                !isBluetoothOn
                    ? Expanded(child: NoBluetoothWidget(ref: ref))
                    : !isConnected
                        ? ConnectionLostWidget(widget.device)
                        : nets.when(
                            data: (data) {
                              // Since Riverpod 2.0 after a provider has emmited an [AsyncValue.data] or [AsyncValue.error], tha provider will no longer emit an [AsyncValue.loading]. Instead it will re-emit the latest value, but with the property [AsyncValue.isLoading] to true.
                              // So to account with this when we refresh the widget we just check if [isLoading] value is true and if it is then show a progress indicator.
                              return nets.isLoading
                                  ? const WaitWhileFetchingWidget()
                                  : Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 2,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 300,
                                                  height: 60,
                                                  child: InputDecorator(
                                                    decoration: InputDecoration(
                                                        hintText:
                                                            'Select network'.hardcoded,
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(15),
                                                            gapPadding: 1)),
                                                    isEmpty: _currentSelectedValue == '',
                                                    child: DropdownButtonHideUnderline(
                                                        child: DropdownButton<String>(
                                                      // TODO: What height it must have
                                                      menuMaxHeight: 400,
                                                      value: _currentSelectedValue == ''
                                                          ? null
                                                          : _currentSelectedValue,
                                                      onChanged: dropdownCallback,
                                                      items: data
                                                          .map((e) => DropdownMenuItem(
                                                              value: e.ssid,
                                                              child: Text(e.ssid)))
                                                          .toList(),
                                                    )),
                                                  ),
                                                ),
                                                RefreshNetworksButton(
                                                    callback: rebuildWidget)
                                              ],
                                            ),
                                          ),
                                          const ButtonPlaceholder(),
                                        ],
                                      ),
                                    );
                            },
                            error: (error, stackTrace) {
                              return nets.isLoading
                                  ? const WaitWhileFetchingWidget()
                                  : ErrorFetchingNetworksWidget(callback: rebuildWidget);
                            },
                            loading: () => const WaitWhileFetchingWidget(),
                          )
              ],
            ),
          )
        ],
      ),
    );
  }
}


