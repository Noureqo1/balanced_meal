import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: const Color(0xFFE67E22), // Orange color
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleButtonPress() async {
    setState(() => _isPressed = true);
    await _controller.forward();
    if (!mounted) return;
    await _controller.reverse();
    setState(() => _isPressed = false);
    if (mounted) {
      Navigator.pushNamed(context, '/user-details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 450),
                  child: Text(
                    '  Balanced Meal',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Craft your ideal meal effortlessly with our app. Select nutritious ingredients tailored to your taste and well-being.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: AnimatedBuilder(
                    animation: _colorAnimation,
                    builder: (context, child) {
                      return ElevatedButton(
                        onPressed: _handleButtonPress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colorAnimation.value,
                          foregroundColor: _isPressed ? Colors.white : const Color(0xFFE67E22),
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black26,
                        ),
                        child: Text(
                          'Order Food',
                          style: GoogleFonts.poppins(
                            color: _isPressed ? Colors.white : const Color(0xFFE67E22),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
