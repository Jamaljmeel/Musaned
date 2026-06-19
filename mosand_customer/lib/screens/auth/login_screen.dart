import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text.trim());
    } catch (e) {
      if (mounted) Helpers.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withValues(alpha: 0.05), Colors.white],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset('assets/images/loge.png', fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 20),
                  const Text('مُساند', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const Text('تسوّق من الأسر المنتجة', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 40),

                  CustomTextField(
                    controller: _emailCtrl, label: 'البريد الإلكتروني',
                    prefixIcon: Icons.email_outlined,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passCtrl, label: 'كلمة المرور',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (v) => Validators.required(v, 'كلمة المرور'),
                  ),
                  const SizedBox(height: 30),

                  CustomButton(text: 'تسجيل الدخول', isLoading: _isLoading, onPressed: _login),
                  
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ليس لديك حساب؟', style: TextStyle(color: AppColors.textSecondary)),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: const Text('إنشاء حساب جديد', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
