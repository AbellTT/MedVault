import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/services/database_service.dart';
import 'package:app/utils/color_extensions.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});
  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final firstNamecontroller = TextEditingController();
  final birth = TextEditingController();
  final lastNamecontroller = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    controller.animateTo(0.2);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF3AC0A0).themedWith(isDark),
              onPrimary: Colors.white.themedWith(isDark),
              onSurface: const Color(0xFF2B2F33).themedWith(isDark),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        birth.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
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
                                        'assets/images/user-icon.svg',
                                        width: 32,
                                        height: 40,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        "Personal Information",
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 150,
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "First Name",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: const Color(
                                                        0xFF5F5D5D,
                                                      ).themedWith(isDark),
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                TextFormField(
                                                  controller:
                                                      firstNamecontroller,
                                                  decoration: InputDecoration(
                                                    border:
                                                        const OutlineInputBorder(),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color:
                                                                const Color(
                                                                  0xFF9E9E9E,
                                                                ).themedWith(
                                                                  isDark,
                                                                ),
                                                            width: 1,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color:
                                                                const Color(
                                                                  0xFF277AFF,
                                                                ).themedWith(
                                                                  isDark,
                                                                ),
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter your first name';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 150,
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "Last Name",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: const Color(
                                                        0xFF5F5D5D,
                                                      ).themedWith(isDark),
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                TextFormField(
                                                  controller:
                                                      lastNamecontroller,
                                                  decoration: InputDecoration(
                                                    border:
                                                        const OutlineInputBorder(),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color:
                                                                const Color(
                                                                  0xFF9E9E9E,
                                                                ).themedWith(
                                                                  isDark,
                                                                ),
                                                            width: 1,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color:
                                                                const Color(
                                                                  0xFF277AFF,
                                                                ).themedWith(
                                                                  isDark,
                                                                ),
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter your Last name';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 35),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Date Of Birth",
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
                                            TextFormField(
                                              controller: birth,
                                              decoration: InputDecoration(
                                                border:
                                                    const OutlineInputBorder(),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: const Color(
                                                          0xFF9E9E9E,
                                                        ).themedWith(isDark),
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: const Color(
                                                          0xFF277AFF,
                                                        ).themedWith(isDark),
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                suffixIcon: Padding(
                                                  padding: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                  child: SvgPicture.asset(
                                                    'assets/images/icon for Medvault/calendar.svg',
                                                    width: 20,
                                                    height: 20,
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                          const Color(
                                                            0xFF3AC0A0,
                                                          ).themedWith(isDark),
                                                          BlendMode.srcIn,
                                                        ),
                                                  ),
                                                ),
                                                hintText: 'DD/MM/YYYY',
                                              ),
                                              onTap: () => _selectDate(context),
                                              readOnly: true,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please select your date of birth';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 35),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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
                                      DatabaseService().createOrUpdateUserData({
                                        'personal_info': {
                                          'first_name': firstNamecontroller.text
                                              .trim(),
                                          'last_name': lastNamecontroller.text
                                              .trim(),
                                          'date_of_birth': birth.text.trim(),
                                        },
                                      });
                                      Navigator.pushNamed(
                                        context,
                                        '/healthmetrics',
                                      );
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
                                            return const Color(
                                              0xFFE2E2E2,
                                            ).themedWith(isDark);
                                          }
                                          return Colors.white.themedWith(
                                            isDark,
                                          );
                                        }),
                                    padding: WidgetStateProperty.all(
                                      const EdgeInsets.all(15),
                                    ),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
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
