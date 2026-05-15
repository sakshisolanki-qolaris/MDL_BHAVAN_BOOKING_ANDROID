import 'package:flutter/material.dart';
import 'dart:ui';
import '../core/di/service_locator.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = getIt<AuthService>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  final Color _primaryGold = const Color(0xFFD4AF37);
  final Color _deepNavy = const Color(0xFF0F172A);

  final RegExp _passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,16}$');

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await _authService.register(
      name: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      password: _passwordController.text,
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created! Welcome to Maharashtra Mandal.'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepNavy,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://mhmandalraipur.org/uploads/banner/1720081961225-NEW.jpg', // Official Maharashtra Mandal Raipur Banner
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _deepNavy.withOpacity(0.5),
                    _deepNavy.withOpacity(0.85),
                    _deepNavy,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Back Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Column(
                        children: [
                          const Icon(Icons.person_add_rounded, size: 54, color: Color(0xFFD4AF37)),
                          const SizedBox(height: 16),
                          const Text(
                            'NEW REGISTRATION',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const Text(
                            'Join Maharashtra Mandal Raipur',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white60,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Glassmorphism Card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildElegantTextField(
                                        controller: _nameController,
                                        label: 'Full Name',
                                        icon: Icons.person_outline_rounded,
                                        validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                                      ),
                                      const SizedBox(height: 20),
                                      
                                      _buildElegantTextField(
                                        controller: _mobileController,
                                        label: 'Mobile Number',
                                        icon: Icons.phone_android_rounded,
                                        keyboardType: TextInputType.phone,
                                        validator: (value) => value == null || value.length != 10 ? 'Enter 10-digit number' : null,
                                      ),
                                      const SizedBox(height: 20),
                                      
                                      _buildElegantTextField(
                                        controller: _emailController,
                                        label: 'Email (Optional)',
                                        icon: Icons.alternate_email_rounded,
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value != null && value.isNotEmpty) {
                                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                              return 'Enter valid email';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      
                                      _buildElegantTextField(
                                        controller: _passwordController,
                                        label: 'Create Password',
                                        icon: Icons.lock_outline_rounded,
                                        isPassword: true,
                                        obscureText: _obscurePassword,
                                        onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'Please enter a password';
                                          if (!_passwordRegex.hasMatch(value)) {
                                            return 'Password too weak';
                                          }
                                          return null;
                                        },
                                        helperText: '8-16 chars, include Symbol & Number',
                                      ),
                                      const SizedBox(height: 40),

                                      ElevatedButton(
                                        onPressed: _isLoading ? null : _handleRegister,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 20),
                                          backgroundColor: _primaryGold,
                                          foregroundColor: _deepNavy,
                                          elevation: 8,
                                          shadowColor: _primaryGold.withOpacity(0.4),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(color: Color(0xFF0F172A), strokeWidth: 3),
                                              )
                                            : const Text(
                                                'CREATE ACCOUNT',
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already registered? ", style: TextStyle(color: Colors.white70)),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Login Now',
                                  style: TextStyle(
                                    color: _primaryGold,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: _primaryGold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white70, size: 18),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: Colors.white38,
                      size: 18,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            helperText: helperText,
            helperStyle: const TextStyle(color: Colors.white38, fontSize: 10),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryGold, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
