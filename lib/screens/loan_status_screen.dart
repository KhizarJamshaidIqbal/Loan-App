// lib/screens/loan_status_screen.dart
// ignore_for_file: unused_local_variable, depend_on_referenced_packages, use_super_parameters, unused_element

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class LoanStatusScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final currencyFormatter = NumberFormat.currency(symbol: '\$');

  LoanStatusScreen({Key? key}) : super(key: key);
  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return '0xFF4CAF50';
      case 'pending':
        return '0xFFFFA726';
      case 'rejected':
        return '0xFFEF5350';
      default:
        return '0xFF9E9E9E';
    }
  }

  Widget _buildLoanCard(Map<String, dynamic> loan) {
    final status = loan['status'] as String? ?? 'pending';
    final statusColor = Color(int.parse(getStatusColor(status)));
    final firstName = loan['firstName'] as String? ?? '';
    final lastName = loan['lastName'] as String? ?? '';
    final amount = NumberFormat.currency(symbol: 'PKR ')
        .format(loan['estimatedSalary'] ?? 0);
    final tenure = loan['tenure']?.toString() ?? '0';
    final geography = loan['geography'] as String? ?? '';
    final numProducts = loan['numOfProducts']?.toString() ?? '0';
    final createdAt = loan['createdAt'] as Timestamp?;
    final date = createdAt?.toDate() ?? DateTime.now();
    final applicationId = loan['applicationId'] as String? ?? '';

    if (kDebugMode) {
      print('Building card with data:');
      print('Status: $status');
      print('Name: $firstName $lastName');
      print('Amount: $amount');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with application ID and status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffD9FF7E).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xff83A43F),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$firstName $lastName',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff83A43F),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'ID: ${applicationId.substring(0, 8)}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  'Applied on ${DateFormat('MMM dd, yyyy').format(date)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // Details grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn('Amount', amount),
                    _buildInfoColumn('Tenure', '$tenure Months'),
                    _buildInfoColumn('Location', geography),
                  ],
                ),
                const SizedBox(height: 16),

                // Status specific information
                _buildStatusInfo(status, loan),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(String status, Map<String, dynamic> loan) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Under Review',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        );
      case 'approved':
        return Column(
          children: [
            LinearProgressIndicator(
              value: 0.3,
              backgroundColor: Colors.grey.shade200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xff83A43F)),
            ),
            const SizedBox(height: 8),
            Text(
              'Processing Payment',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        );
      case 'rejected':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Application Rejected',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDetailChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffD9FF7E).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xff83A43F),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xff83A43F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Current user ID: ${_authService.currentUser?.uid}');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xffD9FF7E),
        elevation: 0,
        title: Text(
          'Loan Applications',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('loan_applications')
            .where('userId', isEqualTo: _authService.currentUser?.uid)
            .get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xff83A43F)),
              ),
            );
          }
          if (snapshot.hasError) {
            if (snapshot.error.toString().contains('failed-precondition')) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xff83A43F)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Setting up database...\nPlease wait a moment.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No loan applications yet',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/loanApplicationForm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff83A43F),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply for a Loan',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              if (kDebugMode) {
                print('Building card for document: ${doc.id}');
                print('Document data: ${doc.data()}');
              }
              final data = doc.data() as Map<String, dynamic>;
              return _buildLoanCard(data);
            },
          );
        },
      ),
    );
  }
}
