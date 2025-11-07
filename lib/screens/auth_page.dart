/*
 *     Copyright (C) 2025 Valeri Gokadze
 *
 *     Billie is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Billie is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:math';
import 'package:flutter/material.dart';

import 'package:billie/services/auth_service.dart';
import 'package:billie/services/router_service.dart';
import 'package:billie/utilities/flutter_toast.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        if (mounted) {
          showToast(context, 'تم تسجيل الدخول بنجاح!');
          NavigationManager.router.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'فشل في تسجيل الدخول: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _continueAsGuest() async {
    try {
      await _authService.setGuestMode();
      if (mounted) {
        showToast(context, 'المتابعة كضيف');
        NavigationManager.router.go('/home');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'خطأ في المتابعة كضيف: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.8),
              primaryColor.withOpacity(0.6),
              theme.colorScheme.secondary.withOpacity(0.7),
              primaryColor.withOpacity(0.9),
            ],
          ),
        ),
        child: Stack(
          children: [
            // خلفية متحركة موسيقية
            _buildAnimatedBackground(),
            
            // المحتوى الرئيسي
            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // شعار التطبيق
                          _buildAppLogo(),
                          
                          const SizedBox(height: 60),
                          
                          // أزرار تسجيل الدخول
                          _buildAuthButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final random = Random(index);
            final size = random.nextDouble() * 100 + 50;
            final left = random.nextDouble() * MediaQuery.of(context).size.width;
            final top = random.nextDouble() * MediaQuery.of(context).size.height;
            final opacity = (random.nextDouble() * 0.3 + 0.1) * _pulseAnimation.value;
            
            return Positioned(
              left: left,
              top: top,
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(opacity),
                  ),
                  child: Icon(
                    _getMusicIcon(index),
                    size: size * 0.6,
                    color: Colors.white.withOpacity(opacity * 0.8),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  IconData _getMusicIcon(int index) {
    final icons = [
      Icons.music_note,
      Icons.audiotrack,
      Icons.album,
      Icons.headphones,
      Icons.speaker,
      Icons.queue_music,
      Icons.radio,
      Icons.mic,
      Icons.piano,
      Icons.music_note,
    ];
    return icons[index % icons.length];
  }

  Widget _buildAppLogo() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.music_note,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Billie',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'paytoneOne',
            shadows: [
              Shadow(
                offset: Offset(2, 2),
                blurRadius: 4,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'تطبيق الموسيقى المفضل لديك',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButtons() {
    return Column(
      children: [
        // زر تسجيل الدخول بـ Google
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _signInWithGoogle,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.login, color: Colors.white),
            label: Text(
              _isLoading ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول بـ Google',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // زر المتابعة كضيف
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _continueAsGuest,
            icon: const Icon(Icons.person_outline, color: Colors.white),
            label: const Text(
              'المتابعة كضيف',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
      ],
    );
  }
}