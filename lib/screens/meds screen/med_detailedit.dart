import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MedDetailEdit extends StatefulWidget {
  const MedDetailEdit({super.key});

  @override
  State<MedDetailEdit> createState() => _MedDetailEditState();
}

class _MedDetailEditState extends State<MedDetailEdit> {
  final _formKey = GlobalKey<FormState>();

  // Pre-filled controllers with existing medication data
  final TextEditingController _medicationNameController = TextEditingController(
    text: 'Metformin',
  );
  final TextEditingController _dosageController = TextEditingController(
    text: '500mg',
  );
  final TextEditingController _instructionsController = TextEditingController(
    text:
        'Take with food to minimize stomach upset. Do not crush or chew tablets.',
  );
  final TextEditingController _prescribedByController = TextEditingController(
    text: 'Dr. Sarah Johnson',
  );
  final TextEditingController _prescribedDateController = TextEditingController(
    text: '01/10/2023',
  );
  final TextEditingController _pharmacyController = TextEditingController(
    text: 'CVS Pharmacy',
  );
  final TextEditingController _refillsController = TextEditingController(
    text: '3',
  );
  final TextEditingController _expiryDateController = TextEditingController(
    text: '12/31/2025',
  );
  final TextEditingController
  _additionalNotesController = TextEditingController(
    text: 'Monitor blood sugar levels regularly. Report any unusual symptoms.',
  );

  String? _selectedFrequency = 'Twice Daily';
  String? _selectedDiagnosis = 'Type 2 Diabetes';

  final List<String> _frequencyOptions = [
    'Once Daily',
    'Twice Daily',
    'Three Times Daily',
    'Four Times Daily',
    'Every Other Day',
    'Weekly',
    'As Needed (PRN)',
  ];

  final List<String> _diagnosisOptions = [
    'General',
    'Hypertension',
    'Type 2 Diabetes',
    'Seasonal Allergies',
    'Asthma',
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(color: Color(0xFF277AFF)),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const Expanded(
                  child: Text(
                    'Edit Medication',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
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
                      iconColor: const Color(0xFF277AFF),
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
                        _buildDropdown(
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

                    // Prescription Details Section
                    _buildSectionCard(
                      icon: "filetext",
                      iconColor: const Color(0xFF277AFF),
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
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF3AC0A0),
                                      onPrimary: Colors.white,
                                      onSurface: Color(0xFF2B2F33),
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
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF3AC0A0),
                                      onPrimary: Colors.white,
                                      onSurface: Color(0xFF2B2F33),
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Medication updated successfully!',
                                ),
                                backgroundColor: Color(0xFF277AFF),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF277AFF),
                          foregroundColor: Colors.white,
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
                        child: const Text('Update Medication'),
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
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      color: Colors.white,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Color(0xFF2B2F33),
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
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Poppins',
          color: Color(0xFF43474B),
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
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFFB0B0B0),
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF277AFF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
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
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(10),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF277AFF), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      hint: hint != null
          ? Text(
              hint,
              style: const TextStyle(
                color: Color(0xFFB0B0B0),
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
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: Color(0xFF2B2F33),
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
