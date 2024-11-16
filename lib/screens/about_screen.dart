import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _launchURL(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff83A43F).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: const Color(0xff83A43F),
                  size: 24,
                ),
                const SizedBox(width: 12),
              ],
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff83A43F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff83A43F).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xff83A43F),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xff83A43F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xffD9FF7E),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Color(0xff83A43F),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff83A43F)
                                        .withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/logo/logo2.png', // Add your app logo
                                // width: 100,
                                // height: 100,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'LendMingle',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff83A43F),
                              ),
                            ),
                            Text(
                              'Version 1.0.0',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(
                        icon: Icons.info_outline,
                        title: 'About Us',
                        content:
                            'LendMingle is a modern lending platform designed to make borrowing and lending money simple, transparent, and accessible to everyone. We believe in creating meaningful financial connections while maintaining the highest standards of security and trust.',
                      ),

                      _buildInfoSection(
                        icon: Icons.verified_outlined,
                        title: 'Our Mission',
                        content:
                            'To revolutionize personal lending by creating a secure, user-friendly platform that connects borrowers with lenders, while promoting financial inclusion and responsible lending practices.',
                      ),

                      _buildInfoSection(
                        icon: Icons.security_outlined,
                        title: 'Security & Privacy',
                        content:
                            'Your security is our top priority. We use industry-leading encryption and security measures to protect your personal and financial information. All transactions are secured and monitored 24/7.',
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'Connect With Us',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Social Links
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildSocialButton(
                            label: 'Website',
                            icon: Icons.language,
                            onTap: () => _launchURL('https://lendmingle.com'),
                          ),
                          _buildSocialButton(
                            label: 'Twitter',
                            icon: Icons.alternate_email,
                            onTap: () =>
                                _launchURL('https://twitter.com/lendmingle'),
                          ),
                          _buildSocialButton(
                            label: 'Instagram',
                            icon: Icons.camera_alt_outlined,
                            onTap: () =>
                                _launchURL('https://instagram.com/lendmingle'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      // Legal Links
                      Column(
                        children: [
                          TextButton(
                            onPressed: () =>
                                _launchURL('https://lendmingle.com/terms'),
                            child: Text(
                              'Terms of Service',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xff83A43F),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                _launchURL('https://lendmingle.com/privacy'),
                            child: Text(
                              'Privacy Policy',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xff83A43F),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      // Copyright
                      Text(
                        '© 2024 LendMingle. All rights reserved.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
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
    _animationController.dispose();
    super.dispose();
  }
}
