import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/services/database_service.dart';
import 'package:app/models/diagnosis_item.dart';
import 'package:app/utils/color_extensions.dart';

class AddDiagnosis extends StatefulWidget {
  const AddDiagnosis({super.key});

  @override
  State<AddDiagnosis> createState() => _AddDiagnosisState();
}

class _AddDiagnosisState extends State<AddDiagnosis> {
  final _formKey = GlobalKey<FormState>();
  final diagnosisNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final doctorNameController = TextEditingController();
  final visitDateController = TextEditingController();
  final notesController = TextEditingController();

  String selectedStatus = 'Ongoing';
  String selectedSeverity = 'Moderate';

  final List<String> statusOptions = [
    'Ongoing',
    'Managed',
    'Recurring',
    'Resolved',
  ];
  final List<String> severityOptions = ['Low', 'Moderate', 'High'];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.white.themedWith(isDark),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: BoxDecoration(
              color: const Color(0xFF277AFF).themedWith(isDark),
            ),
            child: Column(
              children: [
                // Top Bar
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white.themedWith(isDark),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Expanded(
                      child: Text(
                        'Add Diagnosis',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.themedWith(isDark),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(width: 20), // Balance the back button
                  ],
                ),
                const SizedBox(height: 20),

                // File Icon
                Container(
                  width: 80,
                  height: 80,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SvgPicture.asset(
                    "assets/images/icon for Medvault/filetext.svg",
                    colorFilter: ColorFilter.mode(
                      Colors.white.themedWith(isDark),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Card
                    Card(
                      elevation: 2,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: const Color.fromARGB(
                            178,
                            212,
                            212,
                            212,
                          ).themedWith(isDark),
                          width: 1,
                        ),
                      ),
                      color: Colors.white.themedWith(isDark),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Basic Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                color: const Color(
                                  0xFF2B2F33,
                                ).themedWith(isDark),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Diagnosis Name
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Diagnosis Name ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      color: const Color(
                                        0xFF2B2F33,
                                      ).themedWith(isDark),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '*',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                      color: Colors.red.themedWith(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: diagnosisNameController,
                              decoration: InputDecoration(
                                hintText: 'e.g., Hypertension, Diabetes',
                                fillColor: Colors.white.themedWith(isDark),
                                hintStyle: TextStyle(
                                  color: const Color(
                                    0xFFB0B0B0,
                                  ).themedWith(isDark),
                                  fontSize: 14, // Adjusted for consistency
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: SvgPicture.asset(
                                    "assets/images/icon for Medvault/filetext.svg",
                                    colorFilter: ColorFilter.mode(
                                      const Color(
                                        0xFF277AFF,
                                      ).themedWith(isDark),
                                      BlendMode.srcIn,
                                    ),
                                    width: 10,
                                    height: 10,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFFE0E0E0,
                                    ).themedWith(isDark),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFFE0E0E0,
                                    ).themedWith(isDark),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFF277AFF,
                                    ).themedWith(isDark),
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter diagnosis name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Description
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: const Color(
                                  0xFF2B2F33,
                                ).themedWith(isDark),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText:
                                    'Brief description of the diagnosis...',
                                hintStyle: TextStyle(
                                  color: const Color(
                                    0xFFB0B0B0,
                                  ).themedWith(isDark),
                                  fontSize: 16,
                                ),
                                fillColor: Colors.white.themedWith(isDark),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFFE0E0E0,
                                    ).themedWith(isDark),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFFE0E0E0,
                                    ).themedWith(isDark),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFF277AFF,
                                    ).themedWith(isDark),
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // First Diagnosed Date
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'First Diagnosed Date ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      color: const Color(
                                        0xFF2B2F33,
                                      ).themedWith(isDark),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '*',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                      color: Colors.red.themedWith(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: dateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                fillColor: Colors.white.themedWith(isDark),
                                hintText: 'mm/dd/yyyy',
                                hintStyle: TextStyle(
                                  color: const Color(
                                    0xFFB0B0B0,
                                  ).themedWith(isDark),
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.calendar_today_outlined,
                                  color: const Color(
                                    0xFF3AC0A0,
                                  ).themedWith(isDark),
                                  size: 18,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFFE0E0E0,
                                    ).themedWith(isDark),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFFE0E0E0,
                                    ).themedWith(isDark),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFF277AFF,
                                    ).themedWith(isDark),
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: const Color(
                                            0xFF3AC0A0,
                                          ).themedWith(isDark),
                                          onPrimary: Colors.white.themedWith(
                                            isDark,
                                          ),
                                          surface: Colors.white.themedWith(
                                            isDark,
                                          ),
                                          onSurface: const Color(
                                            0xFF2B2F33,
                                          ).themedWith(isDark),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() {
                                    dateController.text =
                                        '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select date';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status & Severity Card
                    Card(
                      elevation: 2,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: const Color.fromARGB(
                            178,
                            212,
                            212,
                            212,
                          ).themedWith(isDark),
                          width: 1,
                        ),
                      ),
                      color: Colors.white.themedWith(isDark),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status & Severity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                color: const Color(
                                  0xFF2B2F33,
                                ).themedWith(isDark),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Status
                            Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: const Color(
                                  0xFF2B2F33,
                                ).themedWith(isDark),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.themedWith(isDark),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFFE0E0E0,
                                  ).themedWith(isDark),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 8,
                                    ),
                                    child: Icon(
                                      Icons.flag_outlined,
                                      color: const Color(
                                        0xFF277AFF,
                                      ).themedWith(isDark),
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedStatus,
                                        dropdownColor: Colors.white.themed(
                                          context,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        isExpanded: true,
                                        icon: const Padding(
                                          padding: EdgeInsets.only(right: 12),
                                          child: Icon(Icons.arrow_drop_down),
                                        ),
                                        items: statusOptions.map((
                                          String value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Poppins',
                                                color: const Color(
                                                  0xFF2B2F33,
                                                ).themedWith(isDark),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedStatus = newValue!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Severity Level
                            Text(
                              'Severity Level',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: const Color(
                                  0xFF2B2F33,
                                ).themedWith(isDark),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.themedWith(isDark),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFFE0E0E0,
                                  ).themedWith(isDark),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 8,
                                    ),
                                    child: Icon(
                                      Icons.info_outline,
                                      color: const Color(
                                        0xFFFF9800,
                                      ).themedWith(isDark),
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedSeverity,
                                        dropdownColor: Colors.white.themed(
                                          context,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        isExpanded: true,
                                        icon: const Padding(
                                          padding: EdgeInsets.only(right: 12),
                                          child: Icon(Icons.arrow_drop_down),
                                        ),
                                        items: severityOptions.map((
                                          String value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Poppins',
                                                color: const Color(
                                                  0xFF2B2F33,
                                                ).themedWith(isDark),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedSeverity = newValue!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Doctor Information Card
                    Card(
                      elevation: 2,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: const Color.fromARGB(
                            178,
                            212,
                            212,
                            212,
                          ).themedWith(isDark),
                          width: 1,
                        ),
                      ),
                      color: Colors.white.themedWith(isDark),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Doctor Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                color: const Color(
                                  0xFF2B2F33,
                                ).themedWith(isDark),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Doctor Name
                            Text(
                              'Diagnosed By (Doctor Name)',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                color: const Color(
                                  0xFF2B2F33,
                                ).themedWith(isDark),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: doctorNameController,
                              decoration: InputDecoration(
                                hintText: 'e.g., Dr. Michael Chen',
                                hintStyle: TextStyle(
                                  color: const Color(
                                    0xFFB0B0B0,
                                  ).themedWith(isDark),
                                  fontSize: 14,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: SvgPicture.asset(
                                    "assets/images/icon for Medvault/user.svg",
                                    colorFilter: ColorFilter.mode(
                                      const Color(
                                        0xFF277AFF,
                                      ).themedWith(isDark),
                                      BlendMode.srcIn,
                                    ),
                                    width: 10,
                                    height: 10,
                                  ),
                                ),
                                fillColor: Colors.white.themedWith(isDark),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFFE0E0E0,
                                    ).themedWith(isDark),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFFE0E0E0,
                                    ).themedWith(isDark),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF277AFF),
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Visit/Notes Date
                            Text(
                              'Date of Visit / Notes',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                color: const Color(
                                  0xFF2B2F33,
                                ).themedWith(isDark),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: visitDateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: 'mm/dd/yyyy',
                                hintStyle: TextStyle(
                                  color: const Color(
                                    0xFFB0B0B0,
                                  ).themedWith(isDark),
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.calendar_today_outlined,
                                  color: const Color(
                                    0xFF3AC0A0,
                                  ).themedWith(isDark),
                                  size: 18,
                                ),
                                fillColor: Colors.white.themedWith(isDark),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFFE0E0E0,
                                    ).themedWith(isDark),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFFE0E0E0,
                                    ).themedWith(isDark),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF277AFF),
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: const Color(
                                            0xFF3AC0A0,
                                          ).themedWith(isDark),
                                          onPrimary: Colors.white.themedWith(
                                            isDark,
                                          ),
                                          surface: Colors.white.themedWith(
                                            isDark,
                                          ),
                                          onSurface: const Color(
                                            0xFF2B2F33,
                                          ).themedWith(isDark),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() {
                                    visitDateController.text =
                                        '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Initial Notes
                            Text(
                              'Initial Notes / Comments',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                color: const Color(
                                  0xFF2B2F33,
                                ).themedWith(isDark),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: notesController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText:
                                    'Initial diagnosis notes or doctor comments...',
                                hintStyle: TextStyle(
                                  color: const Color(
                                    0xFFB0B0B0,
                                  ).themedWith(isDark),
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Colors.white.themedWith(isDark),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFFE0E0E0,
                                    ).themedWith(isDark),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFFE0E0E0,
                                    ).themedWith(isDark),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: const Color(
                                      0xFF277AFF,
                                    ).themedWith(isDark),
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          30,
                          58,
                          192,
                          161,
                        ).themedWith(isDark),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFF3AC0A0).themedWith(isDark),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: const Color(
                                    0xFF3AC0A0,
                                  ).themedWith(isDark),
                                  fontFamily: 'Poppins',
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Note\n',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        'You can add related documents, prescriptions, and appointments after creating this diagnosis from the diagnosis detail page.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: const Color(
                                  0xFFE0E0E0,
                                ).themedWith(isDark),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(
                                  0xFF6C7278,
                                ).themedWith(isDark),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // Show loading
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                try {
                                  final db = DatabaseService();

                                  // Map String to enums
                                  DiagnosisStatus status =
                                      DiagnosisStatus.ongoing;
                                  if (selectedStatus == 'Managed') {
                                    status = DiagnosisStatus.managed;
                                  }
                                  if (selectedStatus == 'Recurring') {
                                    status = DiagnosisStatus.recurring;
                                  }
                                  if (selectedStatus == 'Resolved') {
                                    status = DiagnosisStatus.resolved;
                                  }

                                  DiagnosisSeverity severity =
                                      DiagnosisSeverity.moderate;
                                  if (selectedSeverity == 'Low') {
                                    severity = DiagnosisSeverity.low;
                                  }
                                  if (selectedSeverity == 'High') {
                                    severity = DiagnosisSeverity.high;
                                  }

                                  final newDiagnosis = DiagnosisItem(
                                    id: '', // Will be set by name-as-ID logic in service
                                    title: diagnosisNameController.text.trim(),
                                    description: descriptionController.text
                                        .trim(),
                                    status: status,
                                    severity: severity,
                                    diagnosedDate:
                                        dateController.text.isNotEmpty
                                        ? DateTime.tryParse(
                                                dateController.text,
                                              ) ??
                                              DateTime.now()
                                        : DateTime.now(),
                                    documentsCount: 0,
                                    medicationsCount: 0,
                                  );

                                  await db.addDiagnosis(
                                    newDiagnosis,
                                    doctorName: doctorNameController.text
                                        .trim(),
                                    visitDate: visitDateController.text.trim(),
                                    notes: notesController.text.trim(),
                                  );

                                  // Pop loading
                                  if (context.mounted) Navigator.pop(context);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Diagnosis saved successfully!',
                                          style: TextStyle(
                                            color: Colors.white.themedWith(
                                              isDark,
                                            ),
                                          ),
                                        ),
                                        backgroundColor: const Color(
                                          0xFF4CAF50,
                                        ).themedWith(isDark),
                                      ),
                                    );
                                  }

                                  if (context.mounted) Navigator.pop(context);
                                } catch (e) {
                                  // Pop loading
                                  if (context.mounted) Navigator.pop(context);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF277AFF,
                              ).themedWith(isDark),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/images/icon for Medvault/Save.svg",
                                  colorFilter: ColorFilter.mode(
                                    Colors.white.themedWith(isDark),
                                    BlendMode.srcIn,
                                  ),
                                  width: 25,
                                  height: 25,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Save Diagnosis',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.themedWith(isDark),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    diagnosisNameController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    doctorNameController.dispose();
    visitDateController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
