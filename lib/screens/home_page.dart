// ignore_for_file: unused_import, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loan_app_3/models/user_model.dart';
import 'package:loan_app_3/screens/loan_application_screen.dart';
import 'package:loan_app_3/services/auth_service.dart';

class HomePage extends StatefulWidget {
  final Function? onNewLoanPressed;

  const HomePage({
    super.key,
    this.onNewLoanPressed,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  double _totalLoanBalance = 0;
  int _activeLoanCount = 0;
  double _nextPaymentAmount = 0;
  DateTime? _nextPaymentDate;
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLoanData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _loadLoanData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('loan_applications')
          .where('userId', isEqualTo: _authService.currentUser?.uid)
          .where('status', isEqualTo: 'approved')
          .get();

      double totalBalance = 0;
      int activeLoans = 0;
      double nextPayment = 0;
      DateTime? nextDate;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['status'] == 'approved') {
          activeLoans++;
          final salary = data['estimatedSalary'] as double? ?? 0;
          totalBalance += salary;

          // Calculate next payment (example calculation)
          final paymentAmount = salary / (data['tenure'] as int? ?? 1);
          if (nextDate == null ||
              (data['applicationDate'] as Timestamp?)!
                  .toDate()
                  .isAfter(nextDate)) {
            nextPayment = paymentAmount;
            nextDate = (data['applicationDate'] as Timestamp?)?.toDate();
          }
        }
      }

      if (mounted) {
        setState(() {
          _totalLoanBalance = totalBalance;
          _activeLoanCount = activeLoans;
          _nextPaymentAmount = nextPayment;
          _nextPaymentDate = nextDate;
        });
      }
    } catch (e) {
      print('Error loading loan data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar Section
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              // 'Ahmar',
                              _currentUser?.firstName ?? 'Loading...',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff83A43F),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                size: 28,
                                color: Color(0xff83A43F),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Loan Summary Card
                    // Container(
                    //   padding: const EdgeInsets.all(20),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(20),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.black.withOpacity(0.1),
                    //         blurRadius: 10,
                    //         offset: const Offset(0, 5),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Column(
                    //     children: [
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           Text(
                    //             'Total Loan Balance',
                    //             style: GoogleFonts.poppins(
                    //               fontSize: 14,
                    //               color: Colors.black54,
                    //             ),
                    //           ),
                    //           Container(
                    //             padding: const EdgeInsets.symmetric(
                    //               horizontal: 12,
                    //               vertical: 6,
                    //             ),
                    //             decoration: BoxDecoration(
                    //               color: const Color(0xffD9FF7E),
                    //               borderRadius: BorderRadius.circular(20),
                    //             ),
                    //             child: Text(
                    //               '2 Active Loans',
                    //               style: GoogleFonts.poppins(
                    //                 fontSize: 12,
                    //                 color: const Color(0xff83A43F),
                    //                 fontWeight: FontWeight.w600,
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 8),
                    //       Row(
                    //         crossAxisAlignment: CrossAxisAlignment.end,
                    //         children: [
                    //           Text(
                    //             '\$74,526',
                    //             style: GoogleFonts.poppins(
                    //               fontSize: 32,
                    //               fontWeight: FontWeight.bold,
                    //               color: const Color(0xff83A43F),
                    //             ),
                    //           ),
                    //           Text(
                    //             '.30',
                    //             style: GoogleFonts.poppins(
                    //               fontSize: 20,
                    //               fontWeight: FontWeight.bold,
                    //               color: const Color(0xff83A43F),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    _buildLoanSummaryCard()
                  ],
                ),
              ),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickActionButton(
                          icon: Icons.add_circle_outline,
                          label: 'New Loan',
                          color: const Color(0xff83A43F),
                        ),
                        _buildQuickActionButton(
                          icon: Icons.payment_outlined,
                          label: 'Pay Loan',
                          color: const Color(0xff95B94A),
                        ),
                        _buildQuickActionButton(
                          icon: Icons.history,
                          label: 'Loan Status',
                          color: const Color(0xffADD462),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    // Monthly Payment Section
                    // Container(
                    //   padding: const EdgeInsets.all(20),
                    //   decoration: BoxDecoration(
                    //     color: const Color(0xff83A43F),
                    //     borderRadius: BorderRadius.circular(20),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: const Color(0xff83A43F).withOpacity(0.3),
                    //         blurRadius: 10,
                    //         offset: const Offset(0, 5),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               Text(
                    //                 'Next Payment',
                    //                 style: GoogleFonts.poppins(
                    //                   fontSize: 14,
                    //                   color: Colors.white70,
                    //                 ),
                    //               ),
                    //               const SizedBox(height: 4),
                    //               Text(
                    //                 '\$12,345.30',
                    //                 style: GoogleFonts.poppins(
                    //                   fontSize: 24,
                    //                   fontWeight: FontWeight.bold,
                    //                   color: Colors.white,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //           Container(
                    //             padding: const EdgeInsets.symmetric(
                    //               horizontal: 16,
                    //               vertical: 8,
                    //             ),
                    //             decoration: BoxDecoration(
                    //               color: Colors.white,
                    //               borderRadius: BorderRadius.circular(20),
                    //             ),
                    //             child: Text(
                    //               'Due in 7 days',
                    //               style: GoogleFonts.poppins(
                    //                 fontSize: 12,
                    //                 fontWeight: FontWeight.w600,
                    //                 color: const Color(0xff83A43F),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 20),
                    //       ElevatedButton(
                    //         onPressed: () {},
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: Colors.white,
                    //           foregroundColor: const Color(0xff83A43F),
                    //           padding: const EdgeInsets.symmetric(
                    //             horizontal: 24,
                    //             vertical: 12,
                    //           ),
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(12),
                    //           ),
                    //         ),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             const Icon(Icons.payment),
                    //             const SizedBox(width: 8),
                    //             Text(
                    //               'Pay Now',
                    //               style: GoogleFonts.poppins(
                    //                 fontSize: 16,
                    //                 fontWeight: FontWeight.w600,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    _buildNextPaymentCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextPaymentCard() {
    final daysUntilDue = _nextPaymentDate != null
        ? DateTime.now().difference(_nextPaymentDate!).inDays.abs()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff83A43F),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff83A43F).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Payment',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_nextPaymentAmount.toStringAsFixed(2)} PKR',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (_nextPaymentDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Due in $daysUntilDue days',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff83A43F),
                    ),
                  ),
                ),
            ],
          ),
          if (_nextPaymentAmount > 0) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement payment functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xff83A43F),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payment),
                  const SizedBox(width: 8),
                  Text(
                    'Pay Now',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoanSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Loan Balance',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffD9FF7E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_activeLoanCount Active Loan${_activeLoanCount != 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xff83A43F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _totalLoanBalance.toStringAsFixed(0),
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff83A43F),
                ),
              ),
              Text(
                '.${(_totalLoanBalance.toStringAsFixed(2).split('.')[1])} PKR',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff83A43F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        // Handle navigation based on label
        if (label == 'New Loan') {
          if (label == 'New Loan' && widget.onNewLoanPressed != null) {
            widget.onNewLoanPressed!();
          }
        }
        if (label == 'Loan Status') {
          Navigator.pushNamed(context, '/loanStatus');
        }
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
