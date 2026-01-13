import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/utils/color_extensions.dart';

class HealthMetricsScreen extends StatefulWidget {
  const HealthMetricsScreen({super.key});
  @override
  State<HealthMetricsScreen> createState() => _HealthMetricsScreenState();
}

class _HealthMetricsScreenState extends State<HealthMetricsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final firstNamecontroller = TextEditingController();
  final birth = TextEditingController();
  final lastNamecontroller = TextEditingController();
  String? selectedBloodGroup;
  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    controller.animateTo(0.4);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
                                        'assets/images/icon for Medvault/heart.svg',
                                        width: 32,
                                        height: 40,
                                        colorFilter: ColorFilter.mode(
                                          const Color(
                                            0xFF3AC0A0,
                                          ).themedWith(isDark),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        "Health Metrics",
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
                                                    "Height (cm)",
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
                                                  keyboardType:
                                                      TextInputType.number,
                                                  maxLength: 3,
                                                  decoration: InputDecoration(
                                                    border:
                                                        const OutlineInputBorder(),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                            color:
                                                                Color.fromARGB(
                                                                  144,
                                                                  158,
                                                                  158,
                                                                  158,
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
                                                          borderSide:
                                                              const BorderSide(
                                                                color: Color(
                                                                  0xFF277AFF,
                                                                ),
                                                                width: 2,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                    counterText: "",
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter height';
                                                    }
                                                    final number = int.tryParse(
                                                      value,
                                                    );
                                                    if (number == null) {
                                                      return 'Please enter numbers only';
                                                    }
                                                    if (number < 50 ||
                                                        number > 250) {
                                                      return 'Enter valid height (50-250cm)';
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
                                                    "Weight (kg)",
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
                                                  keyboardType:
                                                      TextInputType.number,
                                                  maxLength: 3,
                                                  decoration: InputDecoration(
                                                    border:
                                                        const OutlineInputBorder(),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                            color:
                                                                Color.fromARGB(
                                                                  144,
                                                                  158,
                                                                  158,
                                                                  158,
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
                                                          borderSide:
                                                              const BorderSide(
                                                                color: Color(
                                                                  0xFF277AFF,
                                                                ),
                                                                width: 2,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                    counterText: "",
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter weight';
                                                    }
                                                    final number = int.tryParse(
                                                      value,
                                                    );
                                                    if (number == null) {
                                                      return 'Please enter numbers only';
                                                    }
                                                    if (number < 20 ||
                                                        number > 300) {
                                                      return 'Enter valid weight (20-300kg)';
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
                                                "Blood Group",
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
                                            Theme(
                                              data: Theme.of(context).copyWith(
                                                focusColor:
                                                    const Color.fromARGB(
                                                      169,
                                                      58,
                                                      192,
                                                      161,
                                                    ),
                                                hoverColor:
                                                    const Color.fromARGB(
                                                      169,
                                                      58,
                                                      192,
                                                      161,
                                                    ),
                                                splashColor: Colors.transparent,
                                              ),
                                              child: DropdownButtonFormField<String>(
                                                initialValue:
                                                    selectedBloodGroup,
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
                                                            0xFF3AC0A0,
                                                          ).themedWith(isDark),
                                                          width: 1.5,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                  suffixIcon: const Icon(
                                                    Icons.arrow_drop_down,
                                                  ),
                                                ),
                                                dropdownColor: Colors.white
                                                    .themedWith(isDark),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                focusColor:
                                                    const Color(0xFF3AC0A0)
                                                        .themedWith(isDark)
                                                        .withValues(alpha: 0.6),
                                                selectedItemBuilder:
                                                    (BuildContext context) {
                                                      return bloodGroups.map<
                                                        Widget
                                                      >((String item) {
                                                        return Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            item,
                                                            style: TextStyle(
                                                              color:
                                                                  const Color(
                                                                    0xFF2C2C2C,
                                                                  ).themed(
                                                                    context,
                                                                  ),
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        );
                                                      }).toList();
                                                    },
                                                itemHeight: 50,
                                                items: bloodGroups.map((
                                                  String bloodGroup,
                                                ) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: bloodGroup,
                                                    child: Text(
                                                      bloodGroup,
                                                      style: TextStyle(
                                                        color: const Color(
                                                          0xFF2C2C2C,
                                                        ).themedWith(isDark),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    selectedBloodGroup =
                                                        newValue;
                                                  });
                                                },
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please select blood group';
                                                  }
                                                  return null;
                                                },
                                                hint: const Text(
                                                  'Select Blood Group',
                                                ),
                                              ),
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
                                        'health_metrics': {
                                          'height_cm': int.tryParse(
                                            firstNamecontroller.text,
                                          ),
                                          'weight_kg': int.tryParse(
                                            lastNamecontroller.text,
                                          ),
                                          'blood_group': selectedBloodGroup,
                                          'updated_at':
                                              FieldValue.serverTimestamp(),
                                        },
                                      });
                                      Navigator.pushNamed(
                                        context,
                                        '/emergencycontact',
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
                                            return const Color.fromARGB(
                                              255,
                                              226,
                                              226,
                                              226,
                                            ).themedWith(isDark);
                                          }
                                          return const Color(
                                            0xFFFFFFFF,
                                          ).themedWith(isDark);
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
