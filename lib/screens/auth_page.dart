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
          children: [
            // خلفية متدرجة إضافية
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // العناصر الموسيقية المتحركة
            ...List.generate(20, (index) {
              final random = Random(index);
              final size = random.nextDouble() * 80 + 30;
              final left = random.nextDouble() * MediaQuery.of(context).size.width;
              final top = random.nextDouble() * MediaQuery.of(context).size.height;
              final opacity = (random.nextDouble() * 0.2 + 0.05) * _pulseAnimation.value;
              final rotationSpeed = random.nextDouble() * 2 + 1;
              
              return Positioned(
                left: left,
                top: top,
                child: Transform.rotate(
                  angle: _pulseController.value * rotationSpeed * 2 * pi,
                  child: Transform.scale(
                    scale: 0.8 + (_pulseAnimation.value - 1) * 0.5,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(opacity * 0.3),
                            Colors.white.withOpacity(opacity * 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Icon(
                        _getMusicIcon(index),
                        size: size * 0.5,
                        color: Colors.white.withOpacity(opacity * 1.2),
                      ),
                    ),
                  ),
                ),
              );
            }),
            // موجات صوتية
            ...List.generate(5, (index) {
              return Positioned(
                left: -100 + (index * 50.0),
                top: MediaQuery.of(context).size.height * 0.7,
                child: Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 4,
                    height: 100 + (index * 20.0) * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
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
      Icons.music_video,
      Icons.library_music,
      Icons.equalizer,
      Icons.volume_up,
      Icons.play_circle_filled,
      Icons.favorite,
      Icons.shuffle,
      Icons.repeat,
      Icons.skip_next,
      Icons.skip_previous,
      Icons.pause_circle_filled,
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
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // خلفية دائرية داخلية
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    // أيقونة الموسيقى الرئيسية
                    const Icon(
                      Icons.music_note,
                      size: 70,
                      color: Colors.white,
                    ),
                    // أيقونات صغيرة دوارة
                    ...List.generate(8, (index) {
                      final angle = (index * pi / 4) + (_pulseController.value * 2 * pi);
                      return Transform.rotate(
                        angle: angle,
                        child: Transform.translate(
                          offset: const Offset(45, 0),
                          child: Icon(
                            _getMusicIcon(index),
                            size: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Colors.white70, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Billie',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'paytoneOne',
              shadows: [
                Shadow(
                  offset: Offset(3, 3),
                  blurRadius: 8,
                  color: Colors.black38,
                ),
                Shadow(
                  offset: Offset(-1, -1),
                  blurRadius: 4,
                  color: Colors.white24,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            'تطبيق الموسيقى المفضل لديك',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButtons() {
    return Column(
      children: [
        // زر تسجيل الدخول بـ Google
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _signInWithGoogle,
            icon: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.login, color: Colors.white, size: 20),
                  ),
            label: Text(
              _isLoading ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول بـ Google',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // زر المتابعة كضيف
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _continueAsGuest,
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_outline, color: Colors.white, size: 20),
            ),
            label: const Text(
              'المتابعة كضيف',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // نص إضافي
        Text(
          'اختر طريقة الدخول المفضلة لديك',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}