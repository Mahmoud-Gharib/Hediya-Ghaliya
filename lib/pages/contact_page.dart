import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  static const routeName = '/contact';
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final subject = Uri.encodeComponent('تواصل جديد من هدية غالية');
    final body = Uri.encodeComponent('الاسم: ${_nameCtrl.text}\nالهاتف: ${_phoneCtrl.text}\n\n${_msgCtrl.text}');
    final uri = Uri.parse('mailto:someone@example.com?subject=$subject&body=$body');
    await _launch(uri);
  }

  Future<void> _sendWhatsApp() async {
    if (!_formKey.currentState!.validate()) return;
    final text = Uri.encodeComponent('الاسم: ${_nameCtrl.text}\nالهاتف: ${_phoneCtrl.text}\n\n${_msgCtrl.text}');
    // ضع رقم الدعم هنا بصيغة دولية بدون +، مثال: 201234567890
    const supportNumber = '201234567890';
    final uri = Uri.parse('https://wa.me/$supportNumber?text=$text');
    await _launch(uri);
  }

  Future<void> _launch(Uri uri) async {
    setState(() => _sending = true);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnack('لا يمكن فتح التطبيق المطلوب');
      }
    } catch (e) {
      _showSnack('تعذّر الإرسال: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تواصل معنا', style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF311B92), Color(0xFF8E24AA), Color(0xFFFF6F61)],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF311B92), Color(0xFF8E24AA), Color(0xFFFF6F61)],
            ),
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _glass(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('الاسم', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('اسمك'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء إدخال الاسم' : null,
                        ),
                        const SizedBox(height: 12),
                        const Text('رقم الهاتف', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('مثال: 01000000000'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء إدخال رقم الهاتف' : null,
                        ),
                        const SizedBox(height: 12),
                        const Text('رسالتك', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _msgCtrl,
                          style: const TextStyle(color: Colors.white),
                          minLines: 4,
                          maxLines: 8,
                          decoration: _inputDecoration('اكتب رسالتك هنا'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء كتابة الرسالة' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _sending ? null : _sendEmail,
                        style: _gradButtonStyle(),
                        icon: const Icon(Icons.email, color: Colors.white),
                        label: _sending
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('إرسال عبر البريد', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _sending ? null : _sendWhatsApp,
                        style: _gradButtonStyle(),
                        icon: const Icon(Icons.whatsapp, color: Colors.white),
                        label: _sending
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('واتساب', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _gradButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ).merge(
      ButtonStyle(
        overlayColor: WidgetStateProperty.all(Colors.white24),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
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
    );
  }

  Widget _glass({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: child,
    );
  }
}
