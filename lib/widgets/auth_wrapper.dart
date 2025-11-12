import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../services/auth_service.dart';
import '../models/user.dart' as app_user;
import '../utils/colors.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Set up a listener to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        // User is signed in
        try {
          // Get user data from Firestore
          app_user.User? userData = await _authService.getUserData(user.uid);
          if (userData != null) {
            // User data exists, navigate to home
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              Navigator.of(context).pushReplacementNamed('/home');
            }
          } else {
            // User is authenticated but no profile data, create basic profile
            await _authService.updateUserProfile(
              userId: user.uid,
              name: user.displayName ?? 'User',
              phoneNumber: null,
            );
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              Navigator.of(context).pushReplacementNamed('/home');
            }
          }
        } catch (e) {
          // Error getting user data, sign out and show onboarding
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        // User is not signed in, show onboarding
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.blue.shade100,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.bolt,
                    size: 50,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          // User is authenticated
          return const HomeScreen();
        } else {
          // User is not authenticated
          return const OnboardingScreen();
        }
      },
    );
  }
}
