import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/services/database_service.dart';
import 'package:app/models/diagnosis_item.dart';
import 'package:app/utils/color_extensions.dart';

class MedicalInfoSCreen extends StatefulWidget {
  const MedicalInfoSCreen({super.key});
  @override
  State<MedicalInfoSCreen> createState() => _MedicalInfoSCreenState();
}

class _MedicalInfoSCreenState extends State<MedicalInfoSCreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final List<TextEditingController> _textControllers = [
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    controller.animateTo(0.8);
  }

  @override
  void dispose() {
    controller.dispose();
    for (var controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addTextField() {
    if (_textControllers.length <= 1) {
      setState(() {
        _textControllers.add(TextEditingController());
      });
    }
  }

  void _removeTextField(int index) {
    if (_textControllers.length > 1) {
      setState(() {
        _textControllers[index].dispose();
        _textControllers.removeAt(index);
      });
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white.themedWith(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed progress bar at top
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
            // Scrollable content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 40,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Card with form
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: const Color(
                                    0xFFD4D4D4,
                                  ).themedWith(isDark),
                                  width: 1,
                                ),
                              ),
                              color: Colors.white.themedWith(isDark),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/icon for Medvault/alertcircle-icon.svg',
                                        width: 32,
                                        height: 40,
                                        colorFilter: ColorFilter.mode(
                                          const Color(
                                            0xFF277AFF,
                                          ).themedWith(isDark),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        "Medical Information (optional)",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.normal,
                                          color: const Color(
                                            0xFF000000,
                                          ).themedWith(isDark),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Existing Diagnosis or Conditions",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.normal,
                                                  color: const Color(
                                                    0xFF5F5D5D,
                                                  ).themedWith(isDark),
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Card(
                                              elevation: 10,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                side: BorderSide(
                                                  color: const Color(
                                                    0xFFD4D4D4,
                                                  ).themedWith(isDark),
                                                  width: 1,
                                                ),
                                              ),
                                              color: Colors.white.themed(
                                                context,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                child: Column(
                                                  children: [
                                                    ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          _textControllers
                                                              .length,
                                                      itemBuilder: (context, index) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                bottom: 12.0,
                                                              ),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: TextFormField(
                                                                  controller:
                                                                      _textControllers[index],
                                                                  decoration: InputDecoration(
                                                                    labelText:
                                                                        'Condition ${index + 1}',
                                                                    border:
                                                                        const OutlineInputBorder(),
                                                                    enabledBorder: OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                        color:
                                                                            const Color(
                                                                              0xFF9E9E9E,
                                                                            ).themed(
                                                                              context,
                                                                            ),
                                                                        width:
                                                                            1,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                    focusedBorder: OutlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                        color:
                                                                            const Color(
                                                                              0xFF3AC0A0,
                                                                            ).themed(
                                                                              context,
                                                                            ),
                                                                        width:
                                                                            1.5,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                    counterText:
                                                                        "",
                                                                  ),
                                                                ),
                                                              ),
                                                              if (_textControllers
                                                                      .length >
                                                                  1) ...[
                                                                const SizedBox(
                                                                  width: 8,
                                                                ),
                                                                IconButton(
                                                                  onPressed: () =>
                                                                      _removeTextField(
                                                                        index,
                                                                      ),
                                                                  icon: const Icon(
                                                                    Icons
                                                                        .remove_circle_outline,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                  iconSize: 24,
                                                                  tooltip:
                                                                      'Remove this condition',
                                                                ),
                                                              ],
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: IconButton(
                                                        onPressed:
                                                            _addTextField,
                                                        icon: const Icon(
                                                          Icons.add,
                                                          size: 20,
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              const Color(
                                                                0xFF3AC0A0,
                                                              ).themedWith(
                                                                isDark,
                                                              ),
                                                          foregroundColor:
                                                              Colors.white
                                                                  .themed(
                                                                    context,
                                                                  ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 10,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      Text(
                                        'Don\'t worry! ✨ We\'re keeping it easy. You can skip the detailed info for now. 📝  Just enter the name of Condition. Two conditions are enough😊',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.normal,
                                          color: const Color(
                                            0xFF000000,
                                          ).themedWith(isDark),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 35),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Navigation buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith<Color>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          WidgetState.pressed,
                                        )) {
                                          return const Color(
                                            0xFFE2E2E2,
                                          ).themedWith(isDark);
                                        }
                                        return Colors.white.themedWith(isDark);
                                      }),
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.all(15),
                                  ),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  side: WidgetStateProperty.all(
                                    BorderSide(
                                      color: const Color(
                                        0xFF3AC0A0,
                                      ).themedWith(isDark),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "← Previous",
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF000000,
                                    ).themedWith(isDark),
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      final db = DatabaseService();
                                      for (var controller in _textControllers) {
                                        if (controller.text.isNotEmpty) {
                                          db.addDiagnosis(
                                            DiagnosisItem(
                                              id: '',
                                              title: controller.text.trim(),
                                              description: '',
                                              status: DiagnosisStatus.ongoing,
                                              severity: DiagnosisSeverity.low,
                                              diagnosedDate: DateTime.now(),
                                              documentsCount: 0,
                                              medicationsCount: 0,
                                            ),
                                          );
                                        }
                                      }
                                      Navigator.pushNamed(context, '/uploadpp');
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith<Color>((
                                          states,
                                        ) {
                                          if (states.contains(
                                            WidgetState.pressed,
                                          )) {
                                            return const Color.fromARGB(
                                              255,
                                              226,
                                              226,
                                              226,
                                            );
                                          }
                                          return const Color(0xFFFFFFFF);
                                        }),
                                    padding: WidgetStateProperty.all(
                                      const EdgeInsets.all(15),
                                    ),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    side: WidgetStateProperty.all(
                                      const BorderSide(
                                        color: Color(0xFF3AC0A0),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "Next →",
                                    style: TextStyle(
                                      color: const Color(
                                        0xFF000000,
                                      ).themedWith(isDark),
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
