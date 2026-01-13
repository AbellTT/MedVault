import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/services/database_service.dart';
import 'package:app/utils/color_extensions.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});
  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final firstNamecontroller = TextEditingController();
  final birth = TextEditingController();
  final lastNamecontroller = TextEditingController();
  String? selectedRelation;
  final List<String> relations = [
    'Father',
    'Mother',
    'Sister',
    'Brother',
    'Relative',
    'Spouse',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    controller.animateTo(0.6);
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
                                        'assets/images/icon for Medvault/Vector.svg',
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
                                        "Emergency Contact",
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
                                                "Contact Name",
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
                                              controller: firstNamecontroller,
                                              decoration: InputDecoration(
                                                border:
                                                    const OutlineInputBorder(),
                                                enabledBorder:
                                                    OutlineInputBorder(
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
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter contact name';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
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
                                                "Relation",
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
                                                    const Color(0xFF3AC0A0)
                                                        .themedWith(isDark)
                                                        .withValues(alpha: 0.6),
                                                hoverColor:
                                                    const Color(0xFF3AC0A0)
                                                        .themedWith(isDark)
                                                        .withValues(alpha: 0.6),
                                                splashColor: Colors.transparent,
                                              ),
                                              child: DropdownButtonFormField<String>(
                                                initialValue: selectedRelation,
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
                                                    BorderRadius.circular(10),
                                                focusColor:
                                                    const Color(0xFF3AC0A0)
                                                        .themedWith(isDark)
                                                        .withValues(alpha: 0.6),
                                                selectedItemBuilder:
                                                    (BuildContext context) {
                                                      return relations.map<
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
                                                items: relations.map((
                                                  String relation,
                                                ) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: relation,
                                                    child: Text(
                                                      relation,
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
                                                    selectedRelation = newValue;
                                                  });
                                                },
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please select relation';
                                                  }
                                                  return null;
                                                },
                                                hint: const Text(
                                                  'Select Relation',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 35),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Phone Number",
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
                                              controller: lastNamecontroller,
                                              keyboardType:
                                                  TextInputType.number,
                                              maxLength: 9,
                                              decoration: InputDecoration(
                                                border:
                                                    const OutlineInputBorder(),
                                                enabledBorder:
                                                    OutlineInputBorder(
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
                                                prefixIcon: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                      ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        '+251',
                                                        style: TextStyle(
                                                          color:
                                                              const Color(
                                                                    0xFF000000,
                                                                  )
                                                                  .themed(
                                                                    context,
                                                                  )
                                                                  .withValues(
                                                                    alpha: 0.8,
                                                                  ),
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 20,
                                                        width: 1,
                                                        margin:
                                                            const EdgeInsets.only(
                                                              left: 8,
                                                            ),
                                                        color: const Color(
                                                          0xFF9E9E9E,
                                                        ).themedWith(isDark),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter phone number';
                                                }
                                                final number = int.tryParse(
                                                  value,
                                                );
                                                if (number == null) {
                                                  return 'Please enter numbers only';
                                                }
                                                if (number / 10000000 < 1) {
                                                  return 'Enter valid phone number';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 30),
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
                                      DatabaseService().createOrUpdateUserData({
                                        'emergency_contact': {
                                          'contact_name': firstNamecontroller
                                              .text
                                              .trim(),
                                          'relation': selectedRelation,
                                          'phone_number': lastNamecontroller
                                              .text
                                              .trim(),
                                        },
                                      });
                                      Navigator.pushNamed(
                                        context,
                                        '/medicalinfo',
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
