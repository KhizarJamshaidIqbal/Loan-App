import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loan_app_3/screens/home_page.dart';
import 'package:loan_app_3/screens/loan_application_screen.dart';
import 'package:loan_app_3/screens/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  void switchToLoanApplication() {
    setState(() {
      currentIndex = 1; // Index of LoanApplicationScreen
    });
  }

// Method to get pages
  List<Widget> _getPages() {
    return [
      HomePage(
        onNewLoanPressed: () {
          setState(() {
            currentIndex = 1;
          });
        },
      ),
      const LoanApplicationScreen(),
      const ProfilePage(),
    ];
  }

  // final page = [
  //   // HomePage(),
  //   HomePage(
  //     onNewLoanPressed: () {
  //       setState(() {
  //         currentIndex = 1;
  //       });
  //     },
  //   ),
  //   // const CardsScreen(),
  //   const LoanApplicationScreen(),
  //   const ProfilePage()
  //   // ProfilePage()
  // ];
  @override
  Widget build(BuildContext context) {
    final pages = _getPages();
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(25),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/svg/home_2.svg'),
                label: 'home',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/svg/card.svg'),
                label: 'Apply Loan',
              ),
              // BottomNavigationBarItem(
              //   icon: SvgPicture.asset('assets/svg/search.svg'),
              //   label: 'chat',
              // ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/svg/profile.svg'),
                label: 'profile',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            currentIndex: currentIndex,
            onTap: (index) {
              setState(
                () {
                  currentIndex = index;
                  if (kDebugMode) {
                    print(index);
                  }
                },
              );
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          // page[currentIndex],
          pages[currentIndex],
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
