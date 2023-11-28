import 'package:flutter/material.dart';
import 'package:new_gardenifi_app/src/common_widgets/button_placeholder.dart';
import 'package:new_gardenifi_app/src/common_widgets/error_message_widget.dart';
import 'package:new_gardenifi_app/src/features/bluetooth/presentation/widgets/refresh_networks_button.dart';

class ErrorFetchingNetworksWidget extends StatelessWidget {
  const ErrorFetchingNetworksWidget({
    super.key,
    required this.callback,
  });

  final Function() callback;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ErrorMessageWidget('Oups ... something went wrong'),
                RefreshNetworksButton(callback: callback),
              ],
            ),
          ),
          const Flexible(
            flex: 1,
            child: ButtonPlaceholder(),
          )
        ],
      ),
    );
  }
}
