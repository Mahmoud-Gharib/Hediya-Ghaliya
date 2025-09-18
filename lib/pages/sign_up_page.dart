import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/github_token_service.dart';

// تم تحسين الأمان: الـ token يتم جلبه من GitHub repository
Future<void> saveUserToGitHub({
  required String name,
  required String phone,
  required String password,
}) async {
  final String token = await GitHubTokenService.getToken();
  const String owner = 'mahmoud-gharib';
  const String repo = 'Users';
  const String path = 'users.json';

  final url = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');

  // 1) Fetch current file
  final response = await http.get(url, headers: {
    'Authorization': 'token $token',
    'Accept': 'application/vnd.github+json',
  });

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
    final String sha = jsonResponse['sha'];
    final String encodedContent = jsonResponse['content'];
    final decoded = utf8.decode(base64.decode(encodedContent.replaceAll('\n', '')));
    final data = json.decode(decoded) as Map<String, dynamic>;

    final List users = (data['users'] as List?) ?? <dynamic>[];
    final bool phoneExists = users.any((u) => u['phone'] == phone);
    if (phoneExists) {
      throw Exception('يوجد حساب مسجل بهذا الرقم مسبقًا');
    }

    users.add({
      'name': name,
      'phone': phone,
      'password': password,
    });

    final updatedContent = json.encode({'users': users});
    final base64Content = base64.encode(utf8.encode(updatedContent));

    final updateResponse = await http.put(
      url,
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
      },
      body: json.encode({
        'message': 'Add new user $phone',
        'content': base64Content,
        'sha': sha,
      }),
    );

    if (updateResponse.statusCode != 200 && updateResponse.statusCode != 201) {
      throw Exception('Failed to update file: ${updateResponse.body}');
    }
  } else {
    throw Exception('Failed to fetch file: ${response.body}');
  }
}

class SignUpPage extends StatefulWidget {
  static const routeName = '/signup';
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String phone = '';
  String password = '';
  String confirmPassword = '';
  String errorMessage = '';
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  late final AnimationController _c;
  late final Animation<double> _fadeTop;
  late final Animation<double> _slideForm;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
    _fadeTop = CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    _slideForm = CurvedAnimation(parent: _c, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (password != confirmPassword) {
      setState(() => errorMessage = 'كلمة المرور غير متطابقة');
      return;
    }

    setState(() {
      errorMessage = '';
      isLoading = true;
    });

    try {
      await saveUserToGitHub(name: name, phone: phone, password: password);
      if (!mounted) return;
      // Save login state after successful registration
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logged_in', true);
      await prefs.setString('phone', phone);
      Navigator.pushReplacementNamed(context, '/home', arguments: {'phone': phone});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final s = e.toString();
        final isNetwork = s.contains('SocketException') || s.contains('Failed') || s.contains('XMLHttpRequest');
        errorMessage = isNetwork ? 'خطأ في الاتصال:الرجاء التأكد من الاتصال ب الانترنت' : s;
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF311B92), Color(0xFF8E24AA), Color(0xFFFF6F61)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                FadeTransition(
                  opacity: _fadeTop,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Hero(
                        tag: 'gift_logo',
                        child: Image(
                          image: AssetImage('assets/images/Logo.png'),
                          width: 110,
                          height: 110,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(_slideForm),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 12)),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            const SizedBox(height: 6),
                            const Text(
                              'إنشاء حساب جديد',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            const SizedBox(height: 14),
                            if (errorMessage.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                                ),
                                child: Text(errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                              ),
                            const SizedBox(height: 12),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text('الاسم', style: TextStyle(fontSize: 13, color: Colors.white70)),
                            ),
                            TextFormField(
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(hint: ' اسمك '),
                              onChanged: (v) => name = v.trim(),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'الرجاء إدخال الاسم';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text('رقم الهاتف', style: TextStyle(fontSize: 13, color: Colors.white70)),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(hint: '*********01'),
                              onChanged: (v) => phone = v.trim(),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'الرجاء إدخال رقم الهاتف';
                                if (!RegExp(r'^\d{8,15}$').hasMatch(v)) return 'رقم الهاتف غير صالح';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text('كلمة المرور', style: TextStyle(fontSize: 13, color: Colors.white70)),
                            ),
                            TextFormField(
                              obscureText: obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(
                                hint: '•••••••',
                                suffixIcon: IconButton(
                                  icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70),
                                  onPressed: () => setState(() => obscurePassword = !obscurePassword),
                                ),
                              ),
                              onChanged: (v) => password = v,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة المرور';
                                if (v.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text('تأكيد كلمة المرور', style: TextStyle(fontSize: 13, color: Colors.white70)),
                            ),
                            TextFormField(
                              obscureText: obscureConfirmPassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(
                                hint: '•••••••',
                                suffixIcon: IconButton(
                                  icon: Icon(obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70),
                                  onPressed: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                                ),
                              ),
                              onChanged: (v) => confirmPassword = v,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'الرجاء تأكيد كلمة المرور';
                                return null;
                              },
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _registerUser,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFFFF6F61), Color(0xFF8E24AA)]),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white))
                                        : const Text('إنشاء حساب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: isLoading ? null : () => Navigator.pushReplacementNamed(context, '/signin'),
                              child: const Text('لديك حساب؟ سجل الدخول', style: TextStyle(color: Colors.white70)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white54),
    filled: true,
    fillColor: Colors.white.withOpacity(0.06),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white),
    ),
    suffixIcon: suffixIcon,
  );
}
