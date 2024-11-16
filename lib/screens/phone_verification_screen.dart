// lib/screens/phone_verification_screen.dart
// ignore_for_file: library_private_types_in_public_api, unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  _PhoneVerificationScreenState createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController(text: '+92');
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool isLoading = false;
  String? errorMessage;
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  void _onNumberTap(String value) {
    HapticFeedback.lightImpact();
    if (_phoneController.text.length < 13) {
      setState(() {
        _phoneController.text += value;
      });
    }
  }

  void _onBackspace() {
    final text = _phoneController.text;
    if (text.length > 3) {
      // Don't delete the '+92' prefix
      _phoneController.text = text.substring(0, text.length - 1);
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize arrow animation
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _arrowAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 5)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 5, end: 0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_arrowController);

    // Start the repeating animation
    _arrowController.repeat();
  }

  Widget _buildNumberButton(String number) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNumberTap(number),
        child: Container(
          height: 60,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xff83A43F),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffD9FF7E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 60),
                  // Title
                  const Text(
                    'Enter your phone number',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  const Text(
                    'We will send you a verification code',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Phone Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _phoneController,
                      enabled: false, // Disable keyboard input
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Icon(
                            Icons.phone,
                            color: Color(0xff83A43F),
                            size: 24,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (!value.startsWith('+92')) {
                          return 'Phone number must start with +92';
                        }
                        if (value.length != 13) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Error Message
                  if (errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xff83A43F).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Color(0xff83A43F),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  // const Spacer(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  // Number Pad
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff83A43F).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildAnimatedButton('1'),
                            _buildAnimatedButton('2'),
                            _buildAnimatedButton('3'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildAnimatedButton('4'),
                            _buildAnimatedButton('5'),
                            _buildAnimatedButton('6'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildAnimatedButton('7'),
                            _buildAnimatedButton('8'),
                            _buildAnimatedButton('9'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Empty space with matching dimensions
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 80) / 3,
                              height: 65,
                            ),
                            _buildAnimatedButton('0'),
                            _buildBackspaceButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Submit Button
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff83A43F).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });

                          await _authService.verifyPhone(
                            phoneNumber: _phoneController.text,
                            onCodeSent: (message) {
                              Navigator.pushNamed(
                                context,
                                '/otpVerification',
                                arguments: _phoneController.text,
                              );
                            },
                            onError: (error) {
                              setState(() {
                                errorMessage = error;
                              });
                            },
                          );

                          if (mounted) {
                            setState(() => isLoading = false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff83A43F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Send Verification Code',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _arrowAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(_arrowAnimation.value, 0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            size: 22,
                                          ),
                                          const SizedBox(width: 3),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color:
                                                Colors.white.withOpacity(0.6),
                                            size: 22,
                                          ),
                                          const SizedBox(width: 3),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            size: 22,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
    _arrowController.dispose();
  }

  // Add these methods to your class
  Widget _buildAnimatedButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberTap(number),
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 150),
        tween: Tween<double>(begin: 1, end: 1),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              width: (MediaQuery.of(context).size.width - 90) / 3,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff83A43F).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.9),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  number,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff83A43F),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: _onBackspace,
      child: Padding(
        padding: const EdgeInsets.only(left: 3),
        child: Container(
          width: (MediaQuery.of(context).size.width - 80) / 3,
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff83A43F).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.9),
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_rounded,
              color: Color(0xff83A43F),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
