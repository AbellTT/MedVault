import 'package:flutter/material.dart';
import 'package:app/utils/color_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/models/medication.dart';
import 'package:app/services/database_service.dart';
import 'package:app/models/diagnosis_item.dart';
import 'package:app/widgets/loading_animation.dart';

class MedDetailEdit extends StatefulWidget {
  const MedDetailEdit({super.key});

  @override
  State<MedDetailEdit> createState() => _MedDetailEditState();
}

class _MedDetailEditState extends State<MedDetailEdit> {
  final _formKey = GlobalKey<FormState>();

  bool _isInitialized = false;
  late Medication medication;
  bool _isLoading = false;
  bool _isSaving = false;

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

  String? _selectedFrequency;
  String? _selectedDiagnosis;
  List<DiagnosisItem> _availableDiagnoses = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Medication) {
        medication = args;
        _populateFields();
        _loadDiagnoses();
      }
      _isInitialized = true;
    }
  }

  void _populateFields() {
    _medicationNameController.text = medication.name;
    _dosageController.text = medication.dosage;
    _instructionsController.text = medication.instructions;
    _prescribedByController.text = medication.prescribedBy;
    _prescribedDateController.text = medication.prescribedDate;
    _pharmacyController.text = medication.pharmacy;
    _refillsController.text = medication.refillsRemaining.toString();
    _expiryDateController.text = medication.expiryDate;
    _additionalNotesController.text = medication.notes;
    _selectedFrequency = medication.frequency;
    _selectedDiagnosis = medication.diagnosisId ?? 'General';
  }

  Future<void> _loadDiagnoses() async {
    setState(() => _isLoading = true);
    try {
      final diagnoses = await DatabaseService().getDiagnoses();
      setState(() {
        _availableDiagnoses = diagnoses;
        _diagnosisOptions = ['General', ...diagnoses.map((d) => d.title)];
      });
    } catch (e) {
      debugPrint('Error loading diagnoses: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<String> _diagnosisOptions = ['General'];

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

  Future<void> _saveUpdates() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final updatedMed = Medication(
        id: medication.id,
        name: _medicationNameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _selectedFrequency!,
        instructions: _instructionsController.text.trim(),
        prescribedBy: _prescribedByController.text.trim(),
        prescribedDate: _prescribedDateController.text.trim(),
        pharmacy: _pharmacyController.text.trim(),
        refillsRemaining: int.tryParse(_refillsController.text) ?? 0,
        expiryDate: _expiryDateController.text.trim(),
        notes: _additionalNotesController.text.trim(),
        diagnosisId: _selectedDiagnosis == 'General'
            ? null
            : _selectedDiagnosis,
        enableReminders: medication.enableReminders,
        createdAt: medication.createdAt,
      );

      final bool isDark = Theme.of(context).brightness == Brightness.dark;
      await DatabaseService().updateMedication(medication, updatedMed);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Medication updated successfully!'),
            backgroundColor: const Color(0xFF277AFF).themedWith(isDark),
          ),
        );
        Navigator.pop(context, true); // Pop edit
      }
    } catch (e) {
      if (mounted) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating medication: $e'),
            backgroundColor: Colors.red.themedWith(isDark),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading && _availableDiagnoses.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white.themedWith(isDark),
        body: const Center(child: LoadingAnimation()),
      );
    }

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
                    'Edit Medication',
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
                      isDark: isDark,
                      children: [
                        _buildLabel('Medication Name', isDark, required: true),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _medicationNameController,
                          hintText: 'e.g., Metformin',
                          isDark: isDark,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter medication name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Dosage', isDark, required: true),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _dosageController,
                          hintText: 'e.g., 500mg',
                          isDark: isDark,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter dosage';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Frequency', isDark, required: true),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _selectedFrequency,
                          items: _frequencyOptions,
                          isDark: isDark,
                          onChanged: (value) {
                            setState(() {
                              _selectedFrequency = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Linked Diagnosis', isDark),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _selectedDiagnosis,
                          items: _diagnosisOptions,
                          isDark: isDark,
                          hint: 'Select diagnosis (optional)',
                          onChanged: (value) {
                            setState(() {
                              _selectedDiagnosis = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Instructions', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _instructionsController,
                          hintText: 'e.g., Take with food',
                          maxLines: 3,
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Prescription Details Section
                    _buildSectionCard(
                      icon: "filetext",
                      iconColor: const Color(0xFF277AFF).themedWith(isDark),
                      title: 'Prescription Details',
                      isDark: isDark,
                      children: [
                        _buildLabel('Prescribed By', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _prescribedByController,
                          hintText: 'e.g., Dr. John Smith',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Prescribed Date', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _prescribedDateController,
                          hintText: 'mm/dd/yyyy',
                          readOnly: true,
                          isDark: isDark,
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

                        _buildLabel('Pharmacy', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _pharmacyController,
                          hintText: 'e.g., CVS Pharmacy',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Refills Remaining', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _refillsController,
                          hintText: 'e.g., 3',
                          keyboardType: TextInputType.number,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Expiry Date', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _expiryDateController,
                          hintText: 'mm/dd/yyyy',
                          readOnly: true,
                          isDark: isDark,
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

                        _buildLabel('Additional Notes', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _additionalNotesController,
                          hintText:
                              'Any important notes or side effects to monitor',
                          maxLines: 4,
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveUpdates,
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
                            : const Text('Update Medication'),
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
    required bool isDark,
  }) {
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

  Widget _buildLabel(String label, bool isDark, {bool required = false}) {
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
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red.themedWith(isDark)),
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
    required bool isDark,
  }) {
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
    required bool isDark,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: (items.contains(value)) ? value : null,
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
