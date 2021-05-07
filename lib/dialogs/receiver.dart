import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sharik/components/buttons.dart';
import 'package:sharik/dialogs/open_dialog.dart';
import 'package:sharik/dialogs/select_network.dart';
import 'package:sharik/logic/services/receiver_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';

import '../utils/helper.dart';

class ReceiverDialog extends StatefulWidget {
  @override
  _ReceiverDialogState createState() => _ReceiverDialogState();
}

class _ReceiverDialogState extends State<ReceiverDialog> {
  final ReceiverService receiverService = ReceiverService()..init();

  @override
  void initState() {
    if (!Platform.isLinux) {
      Wakelock.enable();
    }

    super.initState();
  }

  @override
  void dispose() {
    receiverService.kill();
    if (!Platform.isLinux) {
      Wakelock.disable();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: receiverService,
        builder: (context, _) {
          context.watch<ReceiverService>();

          return AlertDialog(
            scrollable: true,
            elevation: 0,
            insetPadding: const EdgeInsets.all(24),
            title: Text(
              'Receiver',
              style: GoogleFonts.getFont(context.l.fontComfortaa,
                  fontWeight: FontWeight.w700),
            ),
            content: receiverService.receivers.isEmpty
                ? SizedBox(
                    height: 42,
                    child: Center(
                      child: Stack(
                        children: [
                          const Center(
                            child: SizedBox(
                                height: 42,
                                width: 42,
                                child: CircularProgressIndicator()),
                          ),
                          // todo text font
                          Center(
                            child: Text(receiverService.loop.toString(),
                                style: const TextStyle(fontSize: 12)),
                          )
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      children: [
                        SizedBox(
                          height: receiverService.receivers.length * 60,
                          child: ListView.builder(
                              itemCount: receiverService.receivers.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (_, e) => ListTile(
                                    // todo text styling
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    // todo style colors
                                    title: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                            receiverService.receivers[e].name)),
                                    subtitle: SingleChildScrollView(
                                      // todo display file type as a logo
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        '${receiverService.receivers[e].os}  •  ${receiverService.receivers[e].addr.ip}:${receiverService.receivers[e].addr.port}',
                                      ),
                                    ),
                                    onTap: () {
                                      launch(
                                          'http://${receiverService.receivers[e].addr.ip}:${receiverService.receivers[e].addr.port}');
                                    },
                                  )),
                        ),
                      ],
                    ),
                  ),
            actions: [
              DialogTextButton(
                  'Network interfaces',
                  receiverService.loaded
                      ? () {
                          openDialog(context,
                              PickNetworkDialog(receiverService.ipService));
                        }
                      : null),
              DialogTextButton(context.l.generalClose, () {
                Navigator.of(context).pop();
              }),
              const SizedBox(width: 4),
            ],
          );
        });
  }
}
