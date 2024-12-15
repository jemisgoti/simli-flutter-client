import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:example/src/core/extensions/context_extension.dart';
import 'package:example/src/core/routes/router.dart';
import 'package:example/src/core/utils/logger.dart';
import 'package:example/src/widgets/bg.dart';
import 'package:example/src/widgets/simli_avatar_selector.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';

class AvatarSelectionPage extends StatefulWidget {
  const AvatarSelectionPage({super.key, required this.showFollow});
  final bool showFollow;
  @override
  State<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  ValueNotifier<String?> name = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    logInfo(widget.showFollow);
    Future.delayed(Durations.long2).then(
      (value) {
        if (widget.showFollow) {
          _showFollowMe();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var names = characterIds.keys.toList();

    return Scaffold(
      backgroundColor: Colors.black45,
      body: Bg(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Please select an agent for the conversation.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 36,
                          height: 0.9,
                          fontWeight: FontWeight.w500,
                          color: context.secondary),
                    ),
                    const Gap(16),
                    Text(
                      "Choose an agent to initiate the conversation. Simli supports more than 20 faces for seamless interaction.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: context.secondary),
                    ),
                  ],
                ),
              ),
              const Gap(36),
              LayoutBuilder(
                builder: (context, constraints) {
                  var size = constraints.biggest;
                  var avatarSize = 320;

                  if (size.width > avatarSize * 3 - 32) {
                    avatarSize = 420;
                    return ValueListenableBuilder<String?>(
                        valueListenable: name,
                        builder: (context, selectedName, child) {
                          return Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16,
                            runSpacing: 16,
                            children: names
                                .map(
                                  (name) => Card(
                                    elevation: 0.5,
                                    borderOnForeground: false,
                                    child: Hero(
                                      tag: name,
                                      child: SimliAvatarSelectionView(
                                        name: name,
                                        size: 320,
                                        isActive: selectedName == name,
                                        onSelect: () {
                                          this.name.value = name;
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        });
                  } else {
                    double avatarSize = 320;
                    return ValueListenableBuilder<String?>(
                        valueListenable: name,
                        builder: (context, selectedName, child) {
                          return CarouselSlider(
                            options: CarouselOptions(
                                height: avatarSize,
                                aspectRatio: 1,
                                viewportFraction: 0.7,
                                initialPage: 0,
                                enableInfiniteScroll: true,
                                reverse: false,
                                autoPlay: false,
                                onPageChanged: (index, reason) {
                                  name.value = names[index];
                                },
                                autoPlayInterval: const Duration(seconds: 3),
                                autoPlayAnimationDuration:
                                    const Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                enlargeCenterPage: true,
                                enlargeFactor: 0.25,
                                scrollDirection: Axis.horizontal,
                                padEnds: true,
                                pageSnapping: true),
                            items: names
                                .map(
                                  (name) => Card(
                                    elevation: 0.5,
                                    borderOnForeground: false,
                                    child: Hero(
                                      tag: name,
                                      child: SimliAvatarSelectionView(
                                        name: name,
                                        size: avatarSize,
                                        isActive: selectedName == name,
                                        onSelect: () {
                                          this.name.value = name;
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        });
                  }
                },
              ),
              const Gap(24),
              InkWell(
                onTap: () {
                  AppRouter.goToConversation<bool>(name.value!);
                },
                child: Container(
                  height: 45,
                  width: 420,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(45),
                      color: context.secondary),
                  child: const Center(
                    child: Text("Select Avatar",
                        style: TextStyle(color: Colors.black, fontSize: 20)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFollowMe() {
    showDialog(
      context: context,
      builder: (context) => Center(child: FollowMeForm()),
    );
  }
}

class SimliAvatarSelectionView extends StatefulWidget {
  const SimliAvatarSelectionView(
      {super.key,
      required this.name,
      this.isActive = false,
      this.size = 200,
      this.onSelect});
  final String name;
  final VoidCallback? onSelect;
  final double size;
  final bool isActive;
  @override
  State<SimliAvatarSelectionView> createState() =>
      _SimliAvatarSelectionViewState();
}

class _SimliAvatarSelectionViewState extends State<SimliAvatarSelectionView> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onSelect?.call();
        hovered = false;
        setState(() {});
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) {
          setState(() {
            hovered = true;
          });
        },
        onExit: (event) {
          setState(() {
            hovered = false;
          });
        },
        child: AnimatedContainer(
          duration: Durations.short3,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  width: 4,
                  color: widget.isActive
                      ? Colors.deepOrange
                      : context.secondary.withOpacity(0.5))),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/${widget.name.toLowerCase()}.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                  child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: hovered
                        ? Colors.black.withOpacity(0.55)
                        : Colors.transparent),
                child: hovered
                    ? Center(
                        child: Container(
                          height: 32,
                          width: 80,
                          decoration: BoxDecoration(
                              color: context.secondary,
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                            child: Text(
                              widget.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      )
                    : null,
              ))
            ],
          ),
        ),
      ),
    );
  }
}

class BlurBg extends StatelessWidget {
  const BlurBg({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return SizedBox(
        height: size.height,
        width: size.width,
        child: ClipRRect(
            child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: child,
        )));
  }
}

class FollowMeForm extends StatelessWidget {
  final List<SocialMediaOption> socialMediaOptions = [
    SocialMediaOption(
        FontAwesomeIcons.github, 'GitHub', 'https://github.com/jemisgoti'),
    SocialMediaOption(FontAwesomeIcons.linkedin, 'LinkedIn',
        'https://www.linkedin.com/in/jemisgoti'),
    SocialMediaOption(
        FontAwesomeIcons.envelope, 'Email', 'mailto:jemis.dev@gmail.com'),
    SocialMediaOption(FontAwesomeIcons.twitter, 'Twitter',
        'https://twitter.com/jemisgoti'), // Replace with actual username
    SocialMediaOption(FontAwesomeIcons.medium, 'Medium',
        'https://medium.com/@jemisgoti'), // Replace with actual Medium username
  ];

  FollowMeForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      surfaceTintColor: Colors.transparent,
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: 420,
        height: 420,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text(
              "Did you like the demo?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              "Feel free to connect with me through any of the following platforms:",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
            const Gap(16),
            Center(
              child: Lottie.asset('assets/jsons/follow-me.json',
                  width: 280, height: 180),
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(socialMediaOptions.length, (index) {
                return InkWell(
                  onTap: () => _launchURL(socialMediaOptions[index].url),
                  mouseCursor: SystemMouseCursors.click,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.grey[200],
                        child: Icon(
                          socialMediaOptions[index].icon,
                          size: 24,
                          color: Colors.black87,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        socialMediaOptions[index].name,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}

class SocialMediaOption {
  final IconData icon;
  final String name;
  final String url;

  SocialMediaOption(this.icon, this.name, this.url);
}
