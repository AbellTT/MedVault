import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/services/database_service.dart';
import 'package:app/models/medication.dart';
import 'package:app/utils/color_extensions.dart';

class AddMedicine extends StatefulWidget {
  const AddMedicine({super.key});

  @override
  State<AddMedicine> createState() => _AddMedicineState();
}

class _AddMedicineState extends State<AddMedicine> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _medicationNameController =
      TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _prescribedByController = TextEditingController();
  final TextEditingController _prescribedDateController =
      TextEditingController();
  final TextEditingController _pharmacyController = TextEditingController();
  final TextEditingController _refillsController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _additionalNotesController =
      TextEditingController();

  String? _selectedFrequency = 'Once Daily';
  String? _selectedDiagnosis = 'General';
  bool _enableReminders = false;
  bool _isSaving = false;
  List<String> _diagnosisOptions = ['General'];
  bool _isLoadingDiagnoses = true;
  final List<String> _reminderTimes = ['08:00']; // Default for Once Daily

  @override
  void initState() {
    super.initState();
    _loadDiagnoses();
  }

  Future<void> _loadDiagnoses() async {
    try {
      final diagnoses = await DatabaseService().getDiagnoses();
      setState(() {
        _diagnosisOptions = ['General', ...diagnoses.map((d) => d.title)];
        _isLoadingDiagnoses = false;
      });
    } catch (e) {
      debugPrint('Error loading diagnoses: $e');
      setState(() => _isLoadingDiagnoses = false);
    }
  }

  Future<void> _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final medication = Medication(
          id: '', // Firestore will handle it or we use name as ID
          name: _medicationNameController.text,
          dosage: _dosageController.text,
          frequency: _selectedFrequency ?? '',
          instructions: _instructionsController.text,
          prescribedBy: _prescribedByController.text,
          prescribedDate: _prescribedDateController.text,
          pharmacy: _pharmacyController.text,
          refillsRemaining: int.tryParse(_refillsController.text) ?? 0,
          expiryDate: _expiryDateController.text,
          notes: _additionalNotesController.text,
          diagnosisId: _selectedDiagnosis,
          enableReminders: _enableReminders,
          reminderTimes: _enableReminders ? _reminderTimes : [],
          createdAt: DateTime.now(),
        );

        debugPrint('Scheduling medication with reminders: $_reminderTimes');

        await DatabaseService().addMedication(medication);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medication saved successfully!'),
              backgroundColor: Color(0xFF277AFF),
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        debugPrint('Error saving medication: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving medication: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  final List<String> _frequencyOptions = [
    'Once Daily',
    'Twice Daily',
    'Three Times Daily',
    'Four Times Daily',
    'Every Other Day',
    'Weekly',
    'As Needed (PRN)',
  ];

  @override
  void dispose() {
    _medicationNameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _prescribedByController.dispose();
    _prescribedDateController.dispose();
    _pharmacyController.dispose();
    _refillsController.dispose();
    _expiryDateController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.white.themedWith(isDark),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF277AFF).themedWith(isDark),
            ),
            child: Row(
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
                    'Add Medication',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.themedWith(isDark),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(width: 20),
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
                    // Basic Information Section
                    _buildSectionCard(
                      icon: "edit2",
                      iconColor: const Color(0xFF277AFF).themedWith(isDark),
                      title: 'Basic Information',
                      children: [
                        _buildLabel('Medication Name', required: true),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _medicationNameController,
                          hintText: 'e.g., Metformin',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter medication name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Dosage', required: true),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _dosageController,
                          hintText: 'e.g., 500mg',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter dosage';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Frequency', required: true),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _selectedFrequency,
                          items: _frequencyOptions,
                          onChanged: (value) {
                            setState(() {
                              _selectedFrequency = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Linked Diagnosis'),
                        const SizedBox(height: 8),
                        _isLoadingDiagnoses
                            ? const Center(child: CircularProgressIndicator())
                            : _buildDropdown(
                                value: _selectedDiagnosis,
                                items: _diagnosisOptions,
                                hint: 'Select diagnosis (optional)',
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDiagnosis = value;
                                  });
                                },
                              ),
                        const SizedBox(height: 16),

                        _buildLabel('Instructions'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _instructionsController,
                          hintText: 'e.g., Take with food',
                          maxLines: 3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Reminder Settings Section
                    _buildSectionCard(
                      icon: "clock",
                      iconColor: const Color(0xFF3AC0A0).themedWith(isDark),
                      title: 'Reminder Settings',
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFE8F5F1,
                                ).themedWith(isDark),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.access_time,
                                color: const Color(
                                  0xFF3AC0A0,
                                ).themedWith(isDark),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Enable Reminders',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                      color: const Color(
                                        0xFF2B2F33,
                                      ).themedWith(isDark),
                                    ),
                                  ),
                                  Text(
                                    'Get notified when it\'s time to take medication',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      color: const Color(
                                        0xFF6C7278,
                                      ).themedWith(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _enableReminders,
                              onChanged: (value) {
                                setState(() {
                                  _enableReminders = value;
                                });
                              },
                              thumbColor: WidgetStateProperty.all(Colors.white),
                              trackColor:
                                  WidgetStateProperty.resolveWith<Color>((
                                    states,
                                  ) {
                                    return states.contains(WidgetState.selected)
                                        ? const Color(0xFF3AC0A0)
                                        : const Color.fromARGB(
                                            133,
                                            189,
                                            189,
                                            189,
                                          );
                                  }),
                              trackOutlineColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Prescription Details Section
                    _buildSectionCard(
                      icon: "filetext",
                      iconColor: const Color(0xFF277AFF).themedWith(isDark),
                      title: 'Prescription Details',
                      children: [
                        _buildLabel('Prescribed By'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _prescribedByController,
                          hintText: 'e.g., Dr. John Smith',
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Prescribed Date'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _prescribedDateController,
                          hintText: 'mm/dd/yyyy',
                          readOnly: true,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
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
                                      onSurface: const Color(
                                        0xFF2B2F33,
                                      ).themedWith(isDark),
                                      surface: Colors.white.themedWith(isDark),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              _prescribedDateController.text =
                                  '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Pharmacy'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _pharmacyController,
                          hintText: 'e.g., CVS Pharmacy',
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Refills Remaining'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _refillsController,
                          hintText: 'e.g., 3',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Expiry Date'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _expiryDateController,
                          hintText: 'mm/dd/yyyy',
                          readOnly: true,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
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
                                      onSurface: const Color(
                                        0xFF2B2F33,
                                      ).themedWith(isDark),
                                      surface: Colors.white.themedWith(isDark),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              _expiryDateController.text =
                                  '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Additional Notes'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _additionalNotesController,
                          hintText:
                              'Any important notes or side effects to monitor',
                          maxLines: 4,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveMedication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF277AFF,
                          ).themedWith(isDark),
                          foregroundColor: Colors.white.themedWith(isDark),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: _isSaving
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white.themedWith(isDark),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Medication'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFE0E0E0).themedWith(isDark),
          width: 1,
        ),
      ),
      color: Colors.white.themedWith(isDark),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  "assets/images/icon for Medvault/$icon.svg",
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: const Color(0xFF2B2F33).themedWith(isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label, {bool required = false}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Poppins',
          color: const Color(0xFF2B2F33).themedWith(isDark),
        ),
        children: required
            ? [
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: const Color(0xFFB0B0B0).themedWith(isDark),
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: Colors.white.themedWith(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFE0E0E0).themedWith(isDark),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFE0E0E0).themedWith(isDark),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF277AFF).themedWith(isDark),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.themedWith(isDark)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red.themedWith(isDark),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    String? hint,
    required void Function(String?) onChanged,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: Colors.white.themedWith(isDark),
      borderRadius: BorderRadius.circular(12),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.themedWith(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFE0E0E0).themedWith(isDark),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFE0E0E0).themedWith(isDark),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF277AFF).themedWith(isDark),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      hint: hint != null
          ? Text(
              hint,
              style: TextStyle(
                color: const Color(0xFFB0B0B0).themedWith(isDark),
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            )
          : null,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: const Color(0xFF2B2F33).themedWith(isDark),
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
