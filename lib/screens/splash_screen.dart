import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/widgets/loading_animation.dart';

class SplashScreen extends StatefulWidget {
  final bool showLoading;
  const SplashScreen({super.key, this.showLoading = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/icon.svg', width: 150),
            if (widget.showLoading) ...[
              const SizedBox(height: 20),
              const LoadingAnimation(size: 100),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 80, left: 80, right: 80),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Med",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF277AFF),
                  fontFamily: 'Poppins',
                ),
              ),
              TextSpan(
                text: "Vault",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3AC0A0),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
