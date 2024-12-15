import 'package:example/src/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:simli_client/models/simli_state.dart';
import 'package:simli_client/simli_client.dart';

class SimliAvatarView extends StatelessWidget {
  const SimliAvatarView(
      {super.key,
      this.size = 512,
      required this.simliClient,
      required this.placeholder,
      required this.loadingWidget});
  final double size;
  final SimliClient simliClient;
  final Widget placeholder;
  final Widget loadingWidget;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [],
          border:
              Border.all(width: 6, color: context.secondary.withOpacity(.5))),
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: ValueListenableBuilder(
            valueListenable: simliClient.stateNotifier,
            builder: (context, state, child) {
              return AnimatedSwitcher(
                duration: Durations.medium2,
                child: Builder(
                  key: ValueKey(state),
                  builder: (context) {
                    switch (state) {
                      case SimliState.ideal:
                        return placeholder;
                      case SimliState.connecting:
                        return Stack(
                          children: [
                            Positioned.fill(child: placeholder),
                            Container(
                              decoration: BoxDecoration(
                                  color: context.primary.withOpacity(.5)),
                              child: Center(child: loadingWidget),
                            ),
                          ],
                        );
                      case SimliState.connected || SimliState.rendering:
                        return Stack(
                          children: [
                            if (state != SimliState.rendering)
                              Positioned.fill(child: placeholder),
                            Container(
                              decoration: BoxDecoration(
                                  color: context.primary.withOpacity(.5)),
                              child: Center(child: loadingWidget),
                            ),
                            if (state != SimliState.rendering)
                              Positioned.fill(
                                child: RTCVideoView(
                                  simliClient.videoRenderer!,
                                  mirror: false,
                                  placeholderBuilder: (context) => placeholder,
                                ),
                              )
                          ],
                        );

                      case SimliState.failed:
                        return Container(
                          color: Colors.red,
                        );
                    }
                  },
                ),
              );
            }),
      ),
    );
  }
}
