// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/loan_model.dart';
import '../models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoanApplicationScreen extends StatefulWidget {
  final UserModel? userData;

  const LoanApplicationScreen({super.key, this.userData});

  @override
  _LoanApplicationScreenState createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;
  File? _cnicFrontImage;
  File? _cnicBackImage;
  final ImagePicker _picker = ImagePicker();

  // Section 1 Controllers
  final _creditScoreController = TextEditingController();
  final _geographyController = TextEditingController();
  String _selectedGender = 'Male';
  final _ageController = TextEditingController();
  final _tenureController = TextEditingController();
  final _balanceController = TextEditingController();
  final _numProductsController = TextEditingController();
  bool _hasCreditCard = false;
  bool _isActiveMember = true;
  final _salaryController = TextEditingController();

  // Section 2 Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cnicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _firstNameController.text = widget.userData!.firstName;
      _lastNameController.text = widget.userData!.lastName;
    }
  }

  Widget _buildSection1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Information',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xff83A43F),
          ),
        ),
        const SizedBox(height: 24),

        // Credit Score
        _buildCustomTextField(
          controller: _creditScoreController,
          label: 'Credit Score',
          hint: 'Enter score (300-850)',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter credit score';
            }
            final score = int.tryParse(value);
            if (score == null || score < 300 || score > 850) {
              return 'Enter a valid credit score (300-850)';
            }
            return null;
          },
        ),

        // Geography
        _buildCustomTextField(
          controller: _geographyController,
          label: 'Geography',
          hint: 'Enter your city',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your city';
            }
            return null;
          },
        ),

        // Gender Selection
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gender',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Male', style: GoogleFonts.poppins()),
                        value: 'Male',
                        groupValue: _selectedGender,
                        activeColor: const Color(0xff83A43F),
                        onChanged: (value) {
                          setState(() => _selectedGender = value!);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Female', style: GoogleFonts.poppins()),
                        value: 'Female',
                        groupValue: _selectedGender,
                        activeColor: const Color(0xff83A43F),
                        onChanged: (value) {
                          setState(() => _selectedGender = value!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Age
        _buildCustomTextField(
          controller: _ageController,
          label: 'Age',
          hint: 'Enter your age',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your age';
            }
            final age = int.tryParse(value);
            if (age == null || age < 18 || age > 80) {
              return 'Age must be between 18 and 80';
            }
            return null;
          },
        ),

        // Tenure
        _buildCustomTextField(
          controller: _tenureController,
          label: 'Tenure (in months)',
          hint: 'Enter loan tenure',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter tenure';
            }
            final tenure = int.tryParse(value);
            if (tenure == null || tenure < 3 || tenure > 36) {
              return 'Tenure must be between 3 and 36 months';
            }
            return null;
          },
        ),

        // Balance
        _buildCustomTextField(
          controller: _balanceController,
          label: 'Current Balance',
          hint: 'Enter current balance',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter balance';
            }
            final balance = double.tryParse(value);
            if (balance == null || balance < 0) {
              return 'Enter a valid balance';
            }
            return null;
          },
        ),

        // Number of Products
        _buildCustomTextField(
          controller: _numProductsController,
          label: 'Number of Products',
          hint: 'Enter number of products',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter number of products';
            }
            final products = int.tryParse(value);
            if (products == null || products < 0 || products > 5) {
              return 'Enter a valid number (0-5)';
            }
            return null;
          },
        ),

        // Credit Card
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Do you have a credit card?',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Switch(
                value: _hasCreditCard,
                onChanged: (value) {
                  setState(() => _hasCreditCard = value);
                },
                activeColor: const Color(0xff83A43F),
              ),
            ],
          ),
        ),

        // Active Member
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Are you an active member?',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Switch(
                value: _isActiveMember,
                onChanged: (value) {
                  setState(() => _isActiveMember = value);
                },
                activeColor: const Color(0xff83A43F),
              ),
            ],
          ),
        ),

        // Estimated Salary
        _buildCustomTextField(
          controller: _salaryController,
          label: 'Estimated Monthly Salary',
          hint: 'Enter your monthly salary',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter salary';
            }
            final salary = double.tryParse(value);
            if (salary == null || salary < 0) {
              return 'Enter a valid salary amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                errorStyle: GoogleFonts.poppins(
                  color: Colors.red.shade400,
                  fontSize: 12,
                ),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xff83A43F),
          ),
        ),
        const SizedBox(height: 24),

        // First Name
        _buildCustomTextField(
          controller: _firstNameController,
          label: 'First Name',
          hint: 'Enter your first name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter first name';
            }
            if (value.length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),

        // Last Name
        _buildCustomTextField(
          controller: _lastNameController,
          label: 'Last Name',
          hint: 'Enter your last name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter last name';
            }
            if (value.length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),

        // CNIC Number
        _buildCustomTextField(
          controller: _cnicController,
          label: 'CNIC Number',
          hint: 'Enter 13-digit CNIC number',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(13),
            _CNICFormatter(),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter CNIC number';
            }
            final cleanValue = value.replaceAll('-', '');
            if (cleanValue.length != 13) {
              return 'CNIC must be 13 digits';
            }
            // Additional validation for your country's CNIC format
            final regex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
            if (!regex.hasMatch(value)) {
              return 'Invalid CNIC format (XXXXX-XXXXXXX-X)';
            }
            return null;
          },
        ),

        const SizedBox(height: 24),

        // CNIC Images Section
        Text(
          'CNIC Images',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCNICImagePicker(
                isfront: true,
                image: _cnicFrontImage,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCNICImagePicker(
                isfront: false,
                image: _cnicBackImage,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCNICImagePicker({
    required bool isfront,
    File? image,
  }) {
    return GestureDetector(
      onTap: () => _pickImage(isfront),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xff83A43F).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  image,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_a_photo,
                    color: Color(0xff83A43F),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isfront ? 'Front Side' : 'Back Side',
                    style: GoogleFonts.poppins(
                      color: const Color(0xff83A43F),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage(bool isfront) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          if (isfront) {
            _cnicFrontImage = File(image.path);
          } else {
            _cnicBackImage = File(image.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitLoanApplication() async {
    if (_cnicFrontImage == null || _cnicBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload both CNIC images'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Upload CNIC images to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();

      // Upload front image
      final frontImageRef = storageRef.child(
          'cnic_images/${DateTime.now().millisecondsSinceEpoch}_front.jpg');
      await frontImageRef.putFile(_cnicFrontImage!);
      final frontImageUrl = await frontImageRef.getDownloadURL();

      // Upload back image
      final backImageRef = storageRef.child(
          'cnic_images/${DateTime.now().millisecondsSinceEpoch}_back.jpg');
      await backImageRef.putFile(_cnicBackImage!);
      final backImageUrl = await backImageRef.getDownloadURL();

      // Get current user ID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'User not authenticated';
      }

      // Create loan application
      final loanApplication = LoanApplicationModel(
        creditScore: int.parse(_creditScoreController.text),
        geography: _geographyController.text,
        gender: _selectedGender,
        age: int.parse(_ageController.text),
        tenure: int.parse(_tenureController.text),
        balance: double.parse(_balanceController.text),
        numOfProducts: int.parse(_numProductsController.text),
        hasCrCard: _hasCreditCard,
        isActiveMember: _isActiveMember,
        estimatedSalary: double.parse(_salaryController.text),
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        cnicNumber: _cnicController.text.replaceAll('-', ''),
        cnicFrontImage: frontImageUrl,
        cnicBackImage: backImageUrl,
        userId: user.uid,
        phoneNumber: widget.userData?.phoneNumber ?? '',
      );

      // Save to Firestore with custom ID
      final docRef = FirebaseFirestore.instance
          .collection('loan_applications')
          .doc(); // Auto-generate ID

      await docRef.set({
        ...loanApplication.toJson(),
        'applicationId': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // Show success and navigate
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan application submitted successfully!'),
            backgroundColor: Color(0xff83A43F),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate after snackbar
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/loanSuccess',
            arguments: {
              'applicationId': docRef.id,
              'userName':
                  '${_firstNameController.text} ${_lastNameController.text}',
            },
          );
        }
      }
    } catch (e) {
      String errorMessage = 'An error occurred';

      if (e.toString().contains('permission-denied')) {
        errorMessage = 'You don\'t have permission to submit applications';
      } else if (e.toString().contains('not-authenticated')) {
        errorMessage = 'Please login again to continue';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Please check your internet connection';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errorMessage,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _submitLoanApplication,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffD9FF7E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStepIndicator(),
                        const SizedBox(height: 24),
                        _currentStep == 0 ? _buildSection1() : _buildSection2(),
                        const SizedBox(height: 24),
                        _buildNavigationButtons(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentStep == 0
                        ? 'Please provide accurate financial information.'
                        : 'Make sure to upload clear images of your CNIC.',
                    style: GoogleFonts.poppins(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _currentStep >= 0
                  ? const Color(0xff83A43F)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _currentStep >= 1
                  ? const Color(0xff83A43F)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          TextButton(
            onPressed: () {
              setState(() => _currentStep--);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: Color(0xff83A43F),
                ),
                const SizedBox(width: 8),
                Text(
                  'Previous',
                  style: GoogleFonts.poppins(
                    color: const Color(0xff83A43F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          const SizedBox(width: 80),
        Flexible(
          child: Container(
            height: 55,
            constraints: const BoxConstraints(maxWidth: 200), // Add constraints
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff83A43F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 2,
              ),
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (_currentStep < 1) {
                          setState(() => _currentStep++);
                        } else {
                          _submitLoanApplication();
                        }
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep == 0 ? 'Next' : 'Submit',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_currentStep == 0) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _creditScoreController.dispose();
    _geographyController.dispose();
    _ageController.dispose();
    _tenureController.dispose();
    _balanceController.dispose();
    _numProductsController.dispose();
    _salaryController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cnicController.dispose();
    super.dispose();
  }
}

// CNIC Formatter
class _CNICFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 4 || (i == 11 && i != text.length - 1)) {
        buffer.write('-');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
