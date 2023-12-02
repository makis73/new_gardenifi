import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_gardenifi_app/src/common_widgets/bluetooth_screen_upper.dart';
import 'package:new_gardenifi_app/src/common_widgets/progress_widget.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';
import 'package:new_gardenifi_app/src/constants/text_styles.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/bluetooth_controller.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/bluetooth_connection/screens/welcome_screen.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/wifi_connection/widgets/connection_wifi_success_widget.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/wifi_connection/widgets/could_not_connect_to_internet_widget.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/wifi_connection/widgets/wait_while_connecting_widget.dart';
import 'package:new_gardenifi_app/src/localization/string_hardcoded.dart';

class WifiConnectionScreen extends ConsumerStatefulWidget {
  const WifiConnectionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WifiConnectionScreenState();
}

class _WifiConnectionScreenState extends ConsumerState<WifiConnectionScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final radius = screenHeight / 4;

    // AsyncValue that watch if device connected to internet or not
    final connectionState = ref.watch(wifiConnectionStatusProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(229, 255, 255, 255),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                BluetoothScreenUpper(
                    radius: radius, showMenuButton: false, logoInTheRight: true),
                connectionState.when(
                  data: (data) {
                    return connectionState.isLoading
                        ? const WaitWhileConnectingWidget()
                        : data == '1'
                            ? ConnectionWifiSuccessWidget(context: context, ref: ref)
                            : const CouldNotConnectToInternetWidget();
                  },
                  error: (error, stackTrace) => Center(child: Text(error.toString())),
                  loading: () => const WaitWhileConnectingWidget(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

