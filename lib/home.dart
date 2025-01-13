import 'package:flutter/material.dart';
import 'package:spotlight/appColor.dart';
import 'package:spotlight/drawer.dart';
import 'package:spotlight/heroSection.dart';
//import 'package:spotlight/HeroSection.dart';
import 'package:spotlight/main.dart';
//import 'package:helloworld/hero_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:stroke_text/stroke_text.dart';

class Home extends StatefulWidget {
  //const Home{Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    _controller = AnimationController(
      vsync: this,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Navigate to another page when the animation finishes
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(seconds: 1),
            pageBuilder: (context, animation, secondaryAnimation) {
              return const Drawer_();
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin =
                  Offset(0.0, 1.0); // Start from the bottom of the screen
              const end = Offset.zero; // End at the current position
              const curve = Curves.easeInOut;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
          // MaterialPageRoute(
          //   builder: (context) => const hero_screen(),
          // ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.liteorange,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Stack(children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Lottie.asset(
            "asset/animations/map2.json",
            repeat: !false,
            height: 300,
            width: 300,
            reverse: false,
            controller: _controller,
            onLoaded: (composition) {
              final desiredDuration = Duration(milliseconds: 1500);
              _controller
                ..duration = desiredDuration
                ..forward(); // Play the animation
            },
          ),
        ),
      ),
      Positioned(
          bottom: 170,
          left: 0,
          right: 0,
          child: Center(
            child: StrokeText(
              text: "SpotLight Nearby",
              textStyle: TextStyle(
                  color: const Color.fromARGB(221, 255, 81, 0),
                  fontFamily: "Playwrite",
                  fontSize: 32,
                  fontWeight: FontWeight.w700),
              strokeColor: const Color.fromARGB(255, 255, 255, 255),
              strokeWidth: 4,
            ),
          ))
    ]);
  }
}

// class NextScreen extends StatelessWidget {
//   const NextScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Text(
//           'Welcome to the Next Screen!',
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }
