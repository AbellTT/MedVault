import 'package:flutter/material.dart';
import 'package:app/utils/color_extensions.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});
  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with SingleTickerProviderStateMixin {
  double progressValue = 0.0;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    controller.animateTo(
      progressValue,
    ); // runs automatically when the screen loads
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.white.themedWith(isDark),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, -100), // move the bar UP by 40 pixels
                child: Container(
                  width: double.infinity,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0).themedWith(isDark),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: controller.value,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(
                            const Color(0xFF3AC0A0).themedWith(isDark),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: 350,
                height: 100,
                child: Text(
                  'Let’s set up your profile!',
                  style: TextStyle(
                    fontSize: 38,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF277AFF).themedWith(isDark),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.center,
                width: 250,
                height: 100,
                child: Text(
                  "We’ll ask a few questions to personalize your health dashboard.",
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color(0xFF61677D).themedWith(isDark),
                    fontFamily: 'Inter_28pt-Regular',
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.pressed)) {
                        return const Color(
                          0xFF1E5ED8,
                        ); // darker blue when pressed
                      }
                      return const Color(0xFF277AFF).themedWith(isDark);
                    }),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/personalinfo',
                      arguments: {'progressValue': progressValue},
                    );
                  },
                  child: const Text(
                    "Start →",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
