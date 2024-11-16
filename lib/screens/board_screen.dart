import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BoardingScreen extends StatelessWidget {
  const BoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(),
            const Text(
              'Welcome to LendMingle',
              style: TextStyle(),
            ),
            Lottie.asset('assets/lottie/lottie_2.json'),
            const Text(
                'Discover the smarter way to lend and borrow money. Whether you’re looking to invest or need a loan.'),
            const Spacer(),
          ],
        ),
      ),
    ));
  }
}
