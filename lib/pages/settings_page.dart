import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'ar';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('themeMode');
    final lang = prefs.getString('appLang');
    setState(() {
      _themeMode = _fromString(theme) ?? ThemeMode.system;
      _language = lang ?? 'ar';
      _loading = false;
    });
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _toString(mode));
    setState(() => _themeMode = mode);
    _showRestartHint();
  }

  Future<void> _saveLang(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appLang', lang);
    setState(() => _language = lang);
    _showRestartHint();
  }

  void _showRestartHint() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الإعدادات. قد تحتاج لإعادة فتح التطبيق لتطبيقها.'),
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإعدادات', style: TextStyle(fontWeight: FontWeight.w800)),
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
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionTitle('المظهر'),
                    _glass(
                      child: Column(
                        children: [
                          RadioListTile<ThemeMode>(
                            value: ThemeMode.system,
                            groupValue: _themeMode,
                            onChanged: (v) => _saveTheme(v!),
                            title: const Text('اتّباع النظام', style: TextStyle(color: Colors.white)),
                            activeColor: Colors.white,
                          ),
                          const Divider(color: Colors.white24, height: 1),
                          RadioListTile<ThemeMode>(
                            value: ThemeMode.light,
                            groupValue: _themeMode,
                            onChanged: (v) => _saveTheme(v!),
                            title: const Text('فاتح', style: TextStyle(color: Colors.white)),
                            activeColor: Colors.white,
                          ),
                          const Divider(color: Colors.white24, height: 1),
                          RadioListTile<ThemeMode>(
                            value: ThemeMode.dark,
                            groupValue: _themeMode,
                            onChanged: (v) => _saveTheme(v!),
                            title: const Text('داكن', style: TextStyle(color: Colors.white)),
                            activeColor: Colors.white,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    _sectionTitle('اللغة'),
                    _glass(
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            value: 'ar',
                            groupValue: _language,
                            onChanged: (v) => _saveLang(v!),
                            title: const Text('العربية', style: TextStyle(color: Colors.white)),
                            activeColor: Colors.white,
                          ),
                          const Divider(color: Colors.white24, height: 1),
                          RadioListTile<String>(
                            value: 'en',
                            groupValue: _language,
                            onChanged: (v) => _saveLang(v!),
                            title: const Text('English', style: TextStyle(color: Colors.white)),
                            activeColor: Colors.white,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    _sectionTitle('الحساب'),
                    _glass(
                      child: ListTile(
                        leading: const Icon(Icons.person_outline, color: Colors.white),
                        title: const Text('الملف الشخصي', style: TextStyle(color: Colors.white)),
                        trailing: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 16),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/profile', arguments: ModalRoute.of(context)?.settings.arguments);
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700));
  }

  Widget _glass({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: child,
    );
  }

  ThemeMode? _fromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
    }
    return null;
  }

  String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
