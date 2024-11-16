// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loan_app_3/models/user_model.dart';
import 'package:loan_app_3/services/auth_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      labelStyle: GoogleFonts.poppins(
        color: Colors.black54,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.poppins(
        color: Colors.black38,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xff83A43F), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String? Function(String?) validatePassword() {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please enter password';
      }

      // Basic length check
      if (value.length < 8) {
        return 'Password must be at least 8 characters';
      }

      // Check for password strength
      bool hasUpperCase = value.contains(RegExp(r'[A-Z]'));
      bool hasLowerCase = value.contains(RegExp(r'[a-z]'));
      bool hasDigits = value.contains(RegExp(r'[0-9]'));
      bool hasSpecialCharacters =
          value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      bool hasNoSpaces = !value.contains(' ');

      // Common weak password patterns
      final commonPatterns = [
        RegExp(r'123'),
        RegExp(r'abc', caseSensitive: false),
        RegExp(r'password', caseSensitive: false),
        RegExp(r'qwerty', caseSensitive: false),
      ];

      bool hasCommonPattern =
          commonPatterns.any((pattern) => value.contains(pattern));

      // Sequential characters check
      bool hasSequentialChars = false;
      for (int i = 0; i < value.length - 2; i++) {
        if (value.codeUnitAt(i + 1) == value.codeUnitAt(i) + 1 &&
            value.codeUnitAt(i + 2) == value.codeUnitAt(i) + 2) {
          hasSequentialChars = true;
          break;
        }
      }

      // Repeated characters check
      bool hasRepeatedChars = false;
      for (int i = 0; i < value.length - 2; i++) {
        if (value[i] == value[i + 1] && value[i] == value[i + 2]) {
          hasRepeatedChars = true;
          break;
        }
      }

      // Build error message based on failed criteria
      List<String> errors = [];

      if (!hasUpperCase) errors.add('uppercase letter');
      if (!hasLowerCase) errors.add('lowercase letter');
      if (!hasDigits) errors.add('number');
      if (!hasSpecialCharacters) errors.add('special character');
      if (!hasNoSpaces) errors.add('no spaces');

      if (errors.isNotEmpty) {
        String errorMessage = 'Password must contain: ${errors.join(', ')}';
        return errorMessage;
      }

      if (hasCommonPattern) {
        return 'Password contains common pattern. Please use a stronger password';
      }

      if (hasSequentialChars) {
        return 'Password contains sequential characters. Please avoid patterns like abc or 123';
      }

      if (hasRepeatedChars) {
        return 'Password contains repeated characters. Please avoid patterns like aaa';
      }

      // Calculate password strength score
      int strengthScore = 0;
      if (value.length >= 12) strengthScore++;
      if (hasUpperCase && hasLowerCase) strengthScore++;
      if (hasDigits) strengthScore++;
      if (hasSpecialCharacters) strengthScore++;
      if (!hasCommonPattern && !hasSequentialChars && !hasRepeatedChars) {
        strengthScore++;
      }

      if (strengthScore < 3) {
        return 'Password is too weak. Please make it stronger';
      }

      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffD9FF7E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff83A43F).withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 40,
                      color: Color(0xff83A43F),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Personal Information',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Please fill in your details to complete registration',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // First Name
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff83A43F).withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: _buildInputDecoration(
                            label: 'First Name',
                            hint: 'Enter your first name',
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter first name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Last Name
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff83A43F).withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: _buildInputDecoration(
                            label: 'Last Name',
                            hint: 'Enter your last name',
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter last name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff83A43F).withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _buildInputDecoration(
                            label: 'Password',
                            hint: 'Enter your password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xff83A43F),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: validatePassword(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff83A43F).withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: _buildInputDecoration(
                            label: 'Confirm Password',
                            hint: 'Confirm your password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xff83A43F),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Register Button
                      Container(
                        height: 55,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff83A43F),
                              Color(0xff95B94A),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff83A43F).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    setState(() => isLoading = true);
                                    try {
                                      final user = UserModel(
                                        phoneNumber: '',
                                        firstName: _firstNameController.text,
                                        lastName: _lastNameController.text,
                                        password: _passwordController.text,
                                      );
                                      await _authService.saveUserData(user);
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/mainPage',
                                      );
                                    } catch (e) {
                                      _showError('Error saving data: $e');
                                    }
                                    setState(() => isLoading = false);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Register',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                    ),
                                  ],
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
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
