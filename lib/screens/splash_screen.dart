import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/widgets/loading_animation.dart';
import 'package:app/utils/color_extensions.dart';

class SplashScreen extends StatefulWidget {
  final bool showLoading;
  const SplashScreen({super.key, this.showLoading = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.white.themedWith(isDark),
      body: Center(
        child: SvgPicture.asset('assets/images/icon.svg', width: 150),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 60, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showLoading) ...[
              const LoadingAnimation(size: 80),
              const SizedBox(height: 40),
            ],
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Med",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF277AFF).themedWith(isDark),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextSpan(
                    text: "Vault",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3AC0A0).themedWith(isDark),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
