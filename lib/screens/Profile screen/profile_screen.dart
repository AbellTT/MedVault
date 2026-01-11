import 'package:flutter/material.dart';
import 'package:app/utils/color_extensions.dart';
import 'package:flutter/services.dart';
import 'package:app/screens/dashboard flow/dashboard_nav_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/services/database_service.dart';
import 'package:app/widgets/loading_animation.dart';
import 'package:app/services/connectivity_helper.dart';
import 'package:app/services/biometric_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final bpController = TextEditingController();
  final sugarController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final emergencyContactController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final birth = TextEditingController();

  DateTime? _selectedDate;
  String? profilePicUrl;
  bool _isLoading = true;
  bool _isUpdatingPassword = false;
  bool _obscurePassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _biometricEnabled = false;
  bool _isGoogleUser = false;
  bool _canCheckBiometrics = false;
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
  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF3AC0A0).themed(context),
              onPrimary: Colors.white.themed(context),
              onSurface: const Color(0xFF2B2F33).themed(context),
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
        ageController.text = _calculateAge(picked).toString();
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  final allergyController = TextEditingController();
  final List<String> _allergies = [];

  @override
  void initState() {
    super.initState();
    _checkUserProvider();
    _loadBiometricStatus();
    // Pre-populate from cache if available to avoid flicker
    final cache = DatabaseService.cachedUserData;
    if (cache != null) {
      _populateFields(cache);
      _isLoading = false;
    }
    _loadUserData();
  }

  void _checkUserProvider() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      for (final provider in user.providerData) {
        if (provider.providerId == 'google.com') {
          setState(() {
            _isGoogleUser = true;
          });
          break;
        }
      }
    }
  }

  Future<void> _loadBiometricStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final enabled = await BiometricService.isBiometricEnabled(user.uid);
    final canCheck = await BiometricService.canCheckBiometrics();
    setState(() {
      _biometricEnabled = enabled;
      _canCheckBiometrics = canCheck;
    });
  }

  Future<void> _toggleBiometrics(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (value) {
      // Authenticate before enabling
      final authenticated = await BiometricService.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
      );
      if (authenticated) {
        await BiometricService.setBiometricEnabled(user.uid, true);
        setState(() {
          _biometricEnabled = true;
        });
      }
    } else {
      await BiometricService.setBiometricEnabled(user.uid, false);
      setState(() {
        _biometricEnabled = false;
      });
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    // Personal Info
    final personal = data['personal_info'] ?? {};
    firstNameController.text = personal['first_name'] ?? '';
    lastNameController.text = personal['last_name'] ?? '';
    birth.text = personal['date_of_birth'] ?? '';

    if (personal['age'] != null) {
      ageController.text = personal['age'].toString();
    } else if (birth.text.isNotEmpty) {
      // Try to calculate age from DOB if age field is empty
      try {
        final parts = birth.text.split('/');
        if (parts.length == 3) {
          final dob = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
          ageController.text = _calculateAge(dob).toString();
        }
      } catch (_) {}
    }

    // Health Metrics
    final health = data['health_metrics'] ?? {};
    heightController.text = (health['height_cm'] ?? '').toString();
    weightController.text = (health['weight_kg'] ?? '').toString();
    selectedBloodGroup = health['blood_group'];
    bpController.text = health['blood_pressure'] ?? '';
    sugarController.text = (health['blood_sugar'] ?? '').toString();

    // Account / Contact
    final account = data['account_info'] ?? {};
    emailController.text = account['email'] ?? '';
    phoneController.text = account['phone_number'] ?? '';
    profilePicUrl = account['profile_picture'];

    final emergency = data['emergency_contact'] ?? {};
    emergencyContactController.text = emergency['phone_number'] ?? '';

    // Allergies
    if (data['allergies'] != null) {
      _allergies.clear();
      _allergies.addAll(List<String>.from(data['allergies']));
    }
  }

  Future<void> _loadUserData() async {
    final data = await DatabaseService().getUserData();
    if (data != null) {
      setState(() {
        _populateFields(data);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePasswordUpdate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    setState(() => _isUpdatingPassword = true);

    try {
      // 1. Re-authenticate
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(cred);

      // 2. Update Password
      await user.updatePassword(newPasswordController.text);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password updated successfully!'),
          backgroundColor: const Color(0xFF4CAF50).themed(context),
        ),
      );

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'wrong-password') {
        message = 'The current password you entered is incorrect.';
      } else if (e.code == 'weak-password') {
        message = 'The new password is too weak.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.themed(context),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to update password. Please check your internet.',
          ),
          backgroundColor: Colors.red.themed(context),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingPassword = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final hasInternet = await ConnectivityHelper.hasInternet();

      if (!hasInternet) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'You are offline. Your changes will be saved locally and synced when you\'re back online.',
            ),
            backgroundColor: const Color(0xFFFFA726).themed(context),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      await DatabaseService().createOrUpdateUserData({
        'personal_info': {
          'first_name': firstNameController.text.trim(),
          'last_name': lastNameController.text.trim(),
          'date_of_birth': birth.text.trim(),
          'age': int.tryParse(ageController.text),
        },
        'health_metrics': {
          'height_cm': int.tryParse(heightController.text),
          'weight_kg': int.tryParse(weightController.text),
          'blood_group': selectedBloodGroup,
          'blood_pressure': bpController.text.trim(),
          'blood_sugar': int.tryParse(sugarController.text),
        },
        'account_info': {
          'email': emailController.text.trim(),
          'phone_number': phoneController.text.trim(),
        },
        'emergency_contact': {
          'contact_name': emergencyContactController.text.trim(),
        },
        'allergies': _allergies,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: const Color(0xFF4CAF50).themed(context),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine values for header and quick info cards
    final firstName = firstNameController.text.isNotEmpty
        ? firstNameController.text
        : "MedVault";
    final lastName = lastNameController.text.isNotEmpty
        ? lastNameController.text
        : "User";
    final email = emailController.text.isNotEmpty
        ? emailController.text
        : "loading...";

    final displayHeight = heightController.text.isNotEmpty
        ? "${heightController.text} cm"
        : "N/A";
    final displayWeight = weightController.text.isNotEmpty
        ? "${weightController.text} kg"
        : "N/A";
    final displayAge = ageController.text.isNotEmpty
        ? ageController.text
        : "N/A";
    final displayBloodGroup = selectedBloodGroup ?? "N/A";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255).themed(context),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF277AFF).themed(context),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white.themed(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.white
                          .withValues(alpha: 0.75)
                          .themed(context),
                    ),
                    borderRadius: BorderRadius.circular(10000),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10000),
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child:
                          profilePicUrl != null &&
                              profilePicUrl!.startsWith('http')
                          ? Image.network(
                              profilePicUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.white
                                      .withValues(alpha: 0.24)
                                      .themed(context),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.black.themed(context),
                                    size: 20,
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.white
                                          .withValues(alpha: 0.24)
                                          .themed(context),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white.themed(context),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                            )
                          : Container(
                              color: Colors.white
                                  .withValues(alpha: 0.24)
                                  .themed(context),
                              child: Icon(
                                Icons.person,
                                color: Colors.black.themed(context),
                                size: 20,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "$firstName $lastName\n",
                        style: TextStyle(
                          color: Colors.white.themed(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      TextSpan(
                        text: email,
                        style: TextStyle(
                          color: Colors.white
                              .withValues(alpha: 0.70)
                              .themed(context),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading && firstNameController.text.isEmpty
                ? const Center(child: LoadingAnimation(size: 150))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Header Section
                        // Personal Information Section
                        Form(
                          key: _formKey,
                          child: Card(
                            elevation: 2,
                            margin: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: const Color.fromARGB(
                                  178,
                                  212,
                                  212,
                                  212,
                                ).themed(context),
                                width: 1,
                              ),
                            ),
                            color: Colors.white.themed(context),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Personal Information',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(
                                            0xFF2B2F33,
                                          ).themed(context),
                                          fontFamily: 'poppins',
                                        ),
                                      ),
                                      SvgPicture.asset(
                                        "assets/images/icon for Medvault/edit2.svg",
                                        width: 15,
                                        height: 15,
                                        colorFilter: ColorFilter.mode(
                                          const Color(
                                            0xFF2B2F33,
                                          ).themed(context),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // First Name
                                  _buildInfoLabel('First Name'),
                                  _buildTextFormField(
                                    controller: firstNameController,
                                    icon: "user",
                                    iconColor: const Color(
                                      0xFF277AFF,
                                    ).themed(context),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter first name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Last Name
                                  _buildInfoLabel('Last Name'),
                                  _buildTextFormField(
                                    controller: lastNameController,
                                    icon: "user",
                                    iconColor: const Color(
                                      0xFF277AFF,
                                    ).themed(context),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter last name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Date of Birth
                                  _buildInfoLabel('Date of Birth'),
                                  TextFormField(
                                    controller: birth,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: const Color(
                                            0xFFE0E0E0,
                                          ).themed(context),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: const Color(
                                            0xFFE0E0E0,
                                          ).themed(context),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: const Color(
                                            0xFF277AFF,
                                          ).themed(context),
                                          width: 1.5,
                                        ),
                                      ),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          right: 10,
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/images/icon for Medvault/calendar.svg",
                                          width: 21,
                                          height: 21,
                                          colorFilter: ColorFilter.mode(
                                            const Color(
                                              0xFF277AFF,
                                            ).themed(context),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      prefixIconConstraints:
                                          const BoxConstraints(
                                            minWidth: 20,
                                            minHeight: 20,
                                          ),
                                      hintText: 'DD/MM/YYYY',
                                      filled: true,
                                      fillColor: Colors.white.themed(context),
                                    ),
                                    onTap: () => _selectDate(context),
                                    readOnly: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select your date of birth';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Age
                                  _buildInfoLabel('Age'),
                                  _buildTextFormField(
                                    controller: ageController,
                                    icon: "Hash",
                                    iconColor: const Color(
                                      0xFF277AFF,
                                    ).themed(context),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter age';
                                      }
                                      return null;
                                    },
                                    number: true,
                                  ),
                                  const SizedBox(height: 16),

                                  // Blood Group
                                  _buildInfoLabel('Blood Group'),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      focusColor: const Color.fromARGB(
                                        169,
                                        58,
                                        192,
                                        161,
                                      ),
                                      hoverColor: const Color.fromARGB(
                                        169,
                                        58,
                                        192,
                                        161,
                                      ),
                                      splashColor: Colors.transparent,
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      initialValue: selectedBloodGroup,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: const Color(
                                              0xFFE0E0E0,
                                            ).themed(context),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: const Color(
                                              0xFFE0E0E0,
                                            ).themed(context),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: const Color(
                                              0xFF277AFF,
                                            ).themed(context),
                                            width: 1.5,
                                          ),
                                        ),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: SvgPicture.asset(
                                            "assets/images/icon for Medvault/droplet.svg",
                                            width: 21,
                                            height: 21,
                                            colorFilter: ColorFilter.mode(
                                              const Color(
                                                0xFF277AFF,
                                              ).themed(context),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                        prefixIconConstraints:
                                            const BoxConstraints(
                                              minWidth: 20,
                                              minHeight: 20,
                                            ),
                                        suffixIcon: Icon(Icons.arrow_drop_down),
                                        filled: true,
                                        fillColor: Colors.white.themed(context),
                                      ),
                                      dropdownColor: Colors.white.themed(
                                        context,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      focusColor: const Color.fromARGB(
                                        151,
                                        58,
                                        192,
                                        161,
                                      ),
                                      selectedItemBuilder:
                                          (BuildContext context) {
                                            return bloodGroups.map<Widget>((
                                              String item,
                                            ) {
                                              return Container(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  item,
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF2B2F33,
                                                    ).themed(context),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              );
                                            }).toList();
                                          },
                                      itemHeight: 50,
                                      items: bloodGroups.map((
                                        String bloodGroup,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: bloodGroup,
                                          child: Text(
                                            bloodGroup,
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF2B2F33,
                                              ).themed(context),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedBloodGroup = newValue;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select blood group';
                                        }
                                        return null;
                                      },
                                      hint: Text('Select Blood Group'),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Height
                                  _buildInfoLabel('Height (cm)'),
                                  _buildTextFormField(
                                    controller: heightController,
                                    icon: "Ruler",
                                    iconColor: const Color(
                                      0xFF4CAF50,
                                    ).themed(context),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter height';
                                      }
                                      if (int.parse(value) / 250 > 1) {
                                        return 'Height cannot be more than 250cm';
                                      }
                                      return null;
                                    },
                                    number: true,
                                  ),
                                  const SizedBox(height: 16),

                                  // Weight
                                  _buildInfoLabel('Weight (kg)'),
                                  _buildTextFormField(
                                    controller: weightController,
                                    icon: "Weight",
                                    iconColor: const Color(
                                      0xFF277AFF,
                                    ).themed(context),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter weight';
                                      }
                                      if (int.parse(value) / 200 > 1) {
                                        return 'Weight cannot be more than 200kg';
                                      }
                                      return null;
                                    },
                                    number: true,
                                  ),
                                  const SizedBox(height: 16),

                                  // Blood Pressure
                                  _buildInfoLabel('Blood Pressure (mmHg)'),
                                  _buildTextFormField(
                                    controller: bpController,
                                    icon: "heart",
                                    iconColor: const Color(
                                      0xFFE91E63,
                                    ).themed(context),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter blood pressure';
                                      }
                                      if (!RegExp(
                                        r'^\d{2,3}/\d{2,3}$',
                                      ).hasMatch(value)) {
                                        return 'Enter valid BP format (e.g. 120/80)';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Blood Sugar
                                  _buildInfoLabel('Blood Sugar (mg/dl)'),
                                  _buildTextFormField(
                                    controller: sugarController,
                                    icon: "droplet",
                                    iconColor: const Color(
                                      0xFF277AFF,
                                    ).themed(context),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter blood sugar';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return 'Please enter numbers only';
                                      }
                                      return null;
                                    },
                                    number: true,
                                  ),
                                  const SizedBox(height: 16),

                                  // Email
                                  _buildInfoLabel('Email'),
                                  _buildTextFormField(
                                    controller: emailController,
                                    icon: "e",
                                    iconColor: const Color(
                                      0xFF4CAF50,
                                    ).themed(context),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter email';
                                      }
                                      if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      ).hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Phone Number
                                  _buildInfoLabel('Phone Number'),
                                  _buildTextFormField(
                                    controller: phoneController,
                                    icon: "p",
                                    iconColor: const Color(
                                      0xFFE91E63,
                                    ).themed(context),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter phone number';
                                      }
                                      return null;
                                    },
                                    number: true,
                                  ),
                                  const SizedBox(height: 16),

                                  // Emergency Contact
                                  _buildInfoLabel('Emergency Contact'),
                                  _buildTextFormField(
                                    controller: emergencyContactController,
                                    icon: "i",
                                    iconColor: const Color(
                                      0xFFFF5252,
                                    ).themed(context),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter emergency contact';
                                      }
                                      return null;
                                    },
                                    number: true,
                                  ),
                                  const SizedBox(height: 16),

                                  // Known Allergies
                                  _buildInfoLabel('Known Allergies'),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: allergyController,
                                          decoration: InputDecoration(
                                            prefixIcon: Padding(
                                              padding: EdgeInsets.only(
                                                left: 12,
                                                right: 10,
                                              ),
                                              child: Icon(
                                                Icons.warning_amber_outlined,
                                                color: const Color(
                                                  0xFFFFA726,
                                                ).themed(context),
                                                size: 21,
                                              ),
                                            ),
                                            prefixIconConstraints:
                                                const BoxConstraints(
                                                  minWidth: 20,
                                                  minHeight: 20,
                                                ),
                                            hintText:
                                                'Type allergy and press +',
                                            hintStyle: TextStyle(
                                              color: const Color(
                                                0xFF999999,
                                              ).themed(context),
                                              fontSize: 15,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFFFF8E1)
                                                .withValues(alpha: 0.3)
                                                .themed(context),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: const Color(
                                                  0xFFE0E0E0,
                                                ).themed(context),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: const Color(
                                                  0xFFE0E0E0,
                                                ).themed(context),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: const Color(
                                                  0xFF277AFF,
                                                ).themed(context),
                                                width: 1.5,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFFFA726,
                                          ).themed(context),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            if (allergyController.text
                                                .trim()
                                                .isNotEmpty) {
                                              setState(() {
                                                _allergies.add(
                                                  allergyController.text.trim(),
                                                );
                                                allergyController.clear();
                                              });
                                            }
                                          },
                                          icon: Icon(
                                            Icons.add,
                                            color: Colors.white.themed(context),
                                            size: 24,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          constraints: const BoxConstraints(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Allergy chips
                                  ...(_allergies.map(
                                    (allergy) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEBEE)
                                            .withValues(alpha: 0.3)
                                            .themed(context),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              allergy,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: const Color(
                                                  0xFF1A1A1A,
                                                ).themed(context),
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _allergies.remove(allergy);
                                              });
                                            },
                                            child: Icon(
                                              Icons.close,
                                              color: const Color(
                                                0xFFE53935,
                                              ).themed(context),
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _saveProfile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF277AFF,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        'Update Profile',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.themed(context),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Security Settings Section
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: const Color.fromARGB(
                                178,
                                212,
                                212,
                                212,
                              ).themed(context),
                              width: 1,
                            ),
                          ),
                          color: Colors.white.themed(context),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFE8F1FF,
                                        ).themed(context),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/images/icon for Medvault/shield.svg",
                                        width: 21,
                                        height: 21,
                                        colorFilter: ColorFilter.mode(
                                          const Color(
                                            0xFF277AFF,
                                          ).themed(context),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Security Settings',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                        color: const Color(
                                          0xFF2B2F33,
                                        ).themed(context),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Biometric Login Toggle
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.05)
                                        .themed(context),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      width: 1,
                                      color: const Color.fromARGB(
                                        45,
                                        158,
                                        158,
                                        158,
                                      ).themed(context),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            15,
                                            58,
                                            192,
                                            161,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/images/icon for Medvault/Fingerprint.svg",
                                          width: 21,
                                          height: 21,
                                          colorFilter: ColorFilter.mode(
                                            const Color(
                                              0xFF4CAF50,
                                            ).themed(context),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Biometric Login',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(
                                                  0xFF1A1A1A,
                                                ).themed(context),
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Use fingerprint or face ID',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: const Color.fromARGB(
                                                  255,
                                                  89,
                                                  89,
                                                  89,
                                                ).themed(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Switch(
                                        value: _biometricEnabled,
                                        onChanged: _canCheckBiometrics
                                            ? (value) =>
                                                  _toggleBiometrics(value)
                                            : null,
                                        thumbColor: WidgetStateProperty.all(
                                          Colors.white.themed(context),
                                        ),
                                        trackColor:
                                            WidgetStateProperty.resolveWith<
                                              Color
                                            >((states) {
                                              if (states.contains(
                                                WidgetState.disabled,
                                              )) {
                                                return Colors.grey.themed(
                                                  context,
                                                );
                                              }
                                              return states.contains(
                                                    WidgetState.selected,
                                                  )
                                                  ? const Color(
                                                      0xFF3AC0A0,
                                                    ).themed(context)
                                                  : const Color.fromARGB(
                                                      133,
                                                      189,
                                                      189,
                                                      189,
                                                    );
                                            }),
                                        trackOutlineColor:
                                            WidgetStateProperty.all(
                                              Colors.transparent,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Change Password Section
                        if (!_isGoogleUser)
                          Card(
                            elevation: 2,
                            margin: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Color.fromARGB(178, 212, 212, 212),
                                width: 1,
                              ),
                            ),
                            color: Colors.white.themed(context),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Form(
                                key: _passwordFormKey,
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.white
                                        .withValues(alpha: 0.05)
                                        .themed(context),
                                    border: Border.all(
                                      width: 1,
                                      color: const Color.fromARGB(
                                        45,
                                        158,
                                        158,
                                        158,
                                      ).themed(context),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFE8F1FF,
                                              ).themed(context),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: SvgPicture.asset(
                                              "assets/images/icon for Medvault/Lock.svg",
                                              width: 21,
                                              height: 21,
                                              colorFilter: ColorFilter.mode(
                                                const Color(
                                                  0xFF277AFF,
                                                ).themed(context),
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Change Password',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Poppins',
                                                  color: const Color(
                                                    0xFF2B2F33,
                                                  ).themed(context),
                                                ),
                                              ),
                                              Text(
                                                'Update your account password',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: const Color.fromARGB(
                                                    255,
                                                    120,
                                                    120,
                                                    120,
                                                  ).themed(context),
                                                  fontFamily: "inter",
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),

                                      // Current Password
                                      _buildPasswordField(
                                        controller: currentPasswordController,
                                        hint: 'Current Password',
                                        obscureText: _obscurePassword,
                                        onToggleVisibility: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter current password';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),

                                      // New Password
                                      _buildPasswordField(
                                        controller: newPasswordController,
                                        hint: 'New Password',
                                        obscureText: _obscureNewPassword,
                                        onToggleVisibility: () {
                                          setState(() {
                                            _obscureNewPassword =
                                                !_obscureNewPassword;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter new password';
                                          }
                                          if (value.length < 8) {
                                            return 'Password must be at least 8 characters';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),

                                      // Confirm New Password
                                      _buildPasswordField(
                                        controller: confirmPasswordController,
                                        hint: 'Confirm New Password',
                                        obscureText: _obscureConfirmPassword,
                                        onToggleVisibility: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please confirm new password';
                                          }
                                          if (value !=
                                              newPasswordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                      ),
                                      // Update Password Button
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _isUpdatingPassword
                                              ? null
                                              : () async {
                                                  if (_passwordFormKey
                                                      .currentState!
                                                      .validate()) {
                                                    await _handlePasswordUpdate();
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF277AFF,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: _isUpdatingPassword
                                              ? SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white
                                                            .themed(context),
                                                      ),
                                                )
                                              : Text(
                                                  'Update Password',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white.themed(
                                                      context,
                                                    ),
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        // Quick Medical Info Section
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: const Color.fromARGB(
                                178,
                                212,
                                212,
                                212,
                              ).themed(context),
                              width: 1,
                            ),
                          ),
                          color: Colors.white.themed(context),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quick Medical Info',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(
                                      0xFF2B2F33,
                                    ).themed(context),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildQuickInfoCard(
                                        'Height',
                                        displayHeight,
                                        'blue',
                                        const Color(0xFF277AFF).themed(context),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildQuickInfoCard(
                                        'Weight',
                                        displayWeight,
                                        'green',
                                        const Color(0xFF4CAF50).themed(context),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildQuickInfoCard(
                                        'Blood Group',
                                        displayBloodGroup,
                                        'blue',
                                        const Color(0xFF277AFF).themed(context),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildQuickInfoCard(
                                        'Age',
                                        displayAge,
                                        'green',
                                        const Color(0xFF4CAF50).themed(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ), // Extra space for bottom nav bar
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const DashboardNavigationBar(selectedIndex: 4),
    );
    // );
  }

  Widget _buildInfoLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: const Color(0xFF2B2F33).themed(context),
          fontWeight: FontWeight.normal,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String icon,
    required Color iconColor,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool? number = false,
  }) {
    return icon == 'p' || icon == 'i'
        ? TextFormField(
            controller: icon == 'p'
                ? phoneController
                : emergencyContactController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 9,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFE0E0E0).themed(context),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFE0E0E0).themed(context),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFF277AFF).themed(context),
                  width: 1.5,
                ),
              ),
              counterText: "",
              prefixIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon == 'p' ? Icons.phone : Icons.contact_emergency,
                      color: iconColor,
                      size: 21,
                    ),
                    Text(
                      '  +251',
                      style: TextStyle(
                        color: Colors.black.themed(context),
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      height: 20,
                      width: 1,
                      margin: const EdgeInsets.only(left: 8),
                      color: const Color.fromARGB(144, 158, 158, 158),
                    ),
                  ],
                ),
              ),
              filled: true,
              fillColor: Colors.white.themed(context),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              final number = int.tryParse(value);
              if (number == null) {
                return 'Please enter numbers only';
              }
              if (number / 10000000 < 1) {
                return 'Enter valid phone number';
              }
              return null;
            },
          )
        : TextFormField(
            controller: controller,
            keyboardType: (number ?? false)
                ? TextInputType.number
                : keyboardType,
            inputFormatters: (number ?? false)
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 10),
                child: icon.length <= 1
                    ? Icon(
                        icon == 'e'
                            ? Icons.email
                            : icon == 'p'
                            ? Icons.phone
                            : Icons.contact_emergency,
                        color: iconColor,
                        size: 21,
                      )
                    : SvgPicture.asset(
                        "assets/images/icon for Medvault/$icon.svg",
                        width: 21,
                        height: 21,
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              filled: true,
              fillColor: Colors.white.themed(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFE0E0E0).themed(context),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFE0E0E0).themed(context),
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFF277AFF).themed(context),
                  width: 1.5,
                ),
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF1A1A1A).themed(context),
              fontFamily: 'Poppins',
            ),
          );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color.fromARGB(255, 137, 137, 137).themed(context),
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: Colors.white.themed(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFE0E0E0).themed(context),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFE0E0E0).themed(context),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF277AFF).themed(context),
            width: 1.5,
          ),
        ),
        suffixIcon: GestureDetector(
          onTap: onToggleVisibility,
          child: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: const Color(0xFF999999).themed(context),
            size: 20,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      ),
    );
  }

  Widget _buildQuickInfoCard(
    String label,
    String value,
    String bgColor,
    Color valueColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor == 'blue'
            ? const Color.fromARGB(15, 39, 122, 255)
            : const Color.fromARGB(15, 58, 192, 161),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
          color: bgColor == 'blue'
              ? const Color.fromARGB(100, 39, 122, 255)
              : const Color.fromARGB(100, 58, 192, 161),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF666666).themed(context),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: valueColor,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
