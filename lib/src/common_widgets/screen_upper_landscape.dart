import 'package:flutter/material.dart';
import 'package:new_gardenifi_app/src/common_widgets/gardenifi_logo.dart';
import 'package:new_gardenifi_app/src/common_widgets/more_menu_button.dart';
import 'package:new_gardenifi_app/src/constants/gaps.dart';

class ScreenUpperLandscape extends StatelessWidget {
  const ScreenUpperLandscape({
    super.key,
    required this.radius,
    required this.showMenuButton,
    this.showAddRemoveMenu = false,
    this.showInitializeMenu = false,
    required this.showLogo,
    this.messageWidget,
  });

  final double radius;
  final Widget? messageWidget;
  final bool showMenuButton;
  final bool? showAddRemoveMenu;
  final bool? showInitializeMenu;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: radius,
      child: Stack(children: [
        Positioned(
          left: -radius / 1.5,
          top: -10,
          child: Container(
            width: radius,
            height: radius,
            decoration: const ShapeDecoration(
              color: Color(0x840C9823),
              shape: OvalBorder(),
            ),
          ),
        ),
        Positioned(
          left: -50,
          top: -radius / 2,
          child: Container(
            width: radius,
            height: radius,
            decoration: const ShapeDecoration(
              color: Color(0x840C9823),
              shape: OvalBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal:15.0),
          child: Column(children: [
            if (showMenuButton)
              MoreMenuButton(
                addRemoveValves: showAddRemoveMenu,
                initializeIoT: showInitializeMenu,
              ),
              gapH32,
            if (messageWidget != null) messageWidget!,
            if (showLogo)
              Align(
                alignment: Alignment.center,
                child: GardenifiLogo(
                  height: radius*2,
                  divider: 4,
                ),
              )
          ]),
        )
      ]),
    );
  }
}
