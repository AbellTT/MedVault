import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/utils/color_extensions.dart';
import 'package:app/models/appointment.dart';
import 'package:app/services/database_service.dart';
import '../../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class AddAppointment extends StatefulWidget {
  const AddAppointment({super.key});

  @override
  State<AddAppointment> createState() => _AddAppointmentState();
}

class _AddAppointmentState extends State<AddAppointment> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedDiagnosis;
  List<String> _diagnosisOptions = ['General'];

  String? _selectedSpecialty;
  final List<String> _specialtyOptions = [
    'General Physician',
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Pediatrics',
    'Orthopedics',
    'Psychiatry',
    'Dentistry',
    'Ophthalmology',
    'Others',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedDiagnosis == null) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is String) {
        _selectedDiagnosis = args;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDiagnoses();
  }

  Future<void> _loadDiagnoses() async {
    try {
      final diagnoses = await DatabaseService().getDiagnoses();
      if (mounted) {
        setState(() {
          _diagnosisOptions = {
            'General',
            ...diagnoses.map((d) => d.title),
          }.toList();
        });
      }
    } catch (e) {
      // Handle error if needed
    }
  }

  @override
  void dispose() {
    _doctorNameController.dispose();
    _specialtyController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDark) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF3AC0A0).themedWith(isDark),
              onPrimary: Colors.white.themedWith(isDark),
              onSurface: const Color(0xFF2B2F33).themedWith(isDark),
              surface: Colors.white.themedWith(isDark),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
    bool isDark,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF3AC0A0).themedWith(isDark),
              onPrimary: Colors.white.themedWith(isDark),
              onSurface: const Color(0xFF2B2F33).themedWith(isDark),
              surface: Colors.white.themedWith(isDark),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
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
            ), // Green Theme
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
                    'Add Appointment',
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
                    // Doctor info section
                    _buildSectionCard(
                      icon: "user",
                      iconColor: const Color(0xFF3AC0A0).themedWith(isDark),
                      title: 'Doctor Information',
                      isDark: isDark,
                      children: [
                        _buildLabel('Doctor Name', isDark, required: true),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _doctorNameController,
                          hintText: 'e.g., Dr. Michael Chen',
                          isDark: isDark,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter doctor name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildLabel(
                          'Specialty/Department',
                          isDark,
                          required: true,
                        ),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _selectedSpecialty,
                          items: _specialtyOptions,
                          isDark: isDark,
                          hint: 'Select specialty',
                          onChanged: (value) {
                            setState(() {
                              _selectedSpecialty = value;
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
                          hint: 'Select diagnosis (or Other)',
                          onChanged: (value) {
                            setState(() {
                              _selectedDiagnosis = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Schedule Section
                    _buildSectionCard(
                      icon: "calendar",
                      iconColor: const Color(0xFF3AC0A0).themedWith(isDark),
                      title: 'Date & Time',
                      isDark: isDark,
                      children: [
                        _buildLabel('Appointment Date', isDark, required: true),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _dateController,
                          hintText: 'mm/dd/yyyy',
                          readOnly: true,
                          isDark: isDark,
                          onTap: () => _selectDate(context, isDark),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select date';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(
                                    'Start Time',
                                    isDark,
                                    required: true,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: _startTimeController,
                                    isDark: isDark,
                                    hintText: '00:00 AM',
                                    readOnly: true,
                                    onTap: () => _selectTime(
                                      context,
                                      _startTimeController,
                                      isDark,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('End Time', isDark),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: _endTimeController,
                                    isDark: isDark,
                                    hintText: '00:00 AM',
                                    readOnly: true,
                                    onTap: () => _selectTime(
                                      context,
                                      _endTimeController,
                                      isDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Location & Reason Section
                    _buildSectionCard(
                      icon: "mappin",
                      iconColor: const Color(0xFF3AC0A0).themedWith(isDark),
                      title: 'Appointment Details',
                      isDark: isDark,
                      children: [
                        _buildLabel('Location', isDark, required: true),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _locationController,
                          isDark: isDark,
                          hintText: 'e.g., City Medical Center, Floor 3',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Reason for Visit', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _reasonController,
                          hintText: 'e.g., Bi-annual checkup',
                          isDark: isDark,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Additional Notes', isDark),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _notesController,
                          hintText: 'Any specific questions or concerns',
                          isDark: isDark,
                          maxLines: 3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Convert String date to DateTime
                            final dateParts = _dateController.text.split('/');
                            final appointmentDate = DateTime(
                              int.parse(dateParts[2]),
                              int.parse(dateParts[0]),
                              int.parse(dateParts[1]),
                            );

                            // Helper to parse TimeOfDay from string (e.g., "10:30 AM")
                            TimeOfDay parseTime(String timeStr) {
                              final parts = timeStr.split(' ');
                              final timeParts = parts[0].split(':');
                              int hour = int.parse(timeParts[0]);
                              int minute = int.parse(timeParts[1]);
                              if (parts.length > 1 &&
                                  parts[1] == 'PM' &&
                                  hour < 12) {
                                hour += 12;
                              } else if (parts.length > 1 &&
                                  parts[1] == 'AM' &&
                                  hour == 12) {
                                hour = 0;
                              }
                              return TimeOfDay(hour: hour, minute: minute);
                            }

                            final newAppointment = Appointment(
                              id: const Uuid().v4(),
                              doctorName: _doctorNameController.text,
                              specialty: _selectedSpecialty ?? 'Others',
                              date: appointmentDate,
                              startTime: parseTime(_startTimeController.text),
                              endTime: _endTimeController.text.isNotEmpty
                                  ? parseTime(_endTimeController.text)
                                  : null,
                              location: _locationController.text,
                              reason: _reasonController.text,
                              notes: _notesController.text,
                              linkedDiagnosis: _selectedDiagnosis ?? 'General',
                              status: 'Upcoming',
                            );

                            // Show global loading if needed, but here we'll just save
                            await DatabaseService().addAppointment(
                              newAppointment,
                            );

                            // Schedule one-time notification
                            NotificationService()
                                .scheduleAppointmentNotification(
                                  newAppointment,
                                );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Appointment saved successfully!',
                                    style: TextStyle(
                                      color: Colors.white.themedWith(isDark),
                                    ),
                                  ),
                                  backgroundColor: const Color(
                                    0xFF3AC0A0,
                                  ).themedWith(isDark),
                                ),
                              );
                              Navigator.pop(context, true);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF3AC0A0,
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
                        child: const Text('Save Appointment'),
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
    required bool isDark,
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
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
    required bool isDark,
    String? hint,
    required void Function(String?) onChanged,
  }) {
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
