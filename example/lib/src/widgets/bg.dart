import 'package:flutter/material.dart';

class Bg extends StatelessWidget {
  const Bg({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        colors: [Color(0xff000000), Color(0xff002e5d), Color(0xff000000)],
        stops: [0, 0.5, 1],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      )

          //     LinearGradient(
          //   colors: [Color(0xff152331), Color(0xff000000)],
          //   stops: [0, 1],
          //   begin: Alignment.bottomRight,
          //   end: Alignment.topLeft,
          // )

          //     gradient: LinearGradient(
          //   colors: [Color(0xff16222a), Color(0xff3a6073)],
          //   stops: [0, 1],
          //   begin: Alignment.bottomRight,
          //   end: Alignment.topLeft,
          // )

          //     gradient: SweepGradient(
          //   colors: [Color(0xff091e3a), Color(0xff2f80ed), Color(0xff2d9ee0)],
          //   stops: [0, 0.5, 1],
          //   center: Alignment.topLeft,
          // )

          ),
      child: child,
    );
  }
}
