import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Services/GithubToken.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  String? phoneArg;
  String? error;
  bool loading = true;
  bool saving = false; // legacy (not used by new per-section saves)
  bool savingName = false;
  bool savingPw = false;
  bool deleting = false;
  
  String nameErrorMessage = '';
  String passwordErrorMessage = '';
  
  bool _isAdmin = false;
  int _totalUsers = 0;
  bool _loadingStats = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  final TextEditingController _oldPwCtrl = TextEditingController();
  bool _obscurePw = true;
  bool _obscurePw2 = true;
  bool _obscureOldPw = true;

  @override
  void initState() {
    super.initState();
    // will fetch in didChangeDependencies to read arguments
  }

  Future<void> _saveName() async {
    if (user == null || phoneArg == null) return;
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => nameErrorMessage = 'الرجاء إدخال الاسم');
      return;
    }
    setState(() {
      nameErrorMessage = '';
      savingName = true;
    });

    final String token = await GitHubTokenService.getUserToken();
    const String owner = 'Hed-Mahmoud-iya-Gha-Gharib-liya';
    const String repo = 'Users';
    const String path = 'users.json';
    final url = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
      });
      if (response.statusCode != 200) {
        throw Exception('تعذر جلب الملف: ${response.statusCode}');
      }
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      final String sha = jsonResponse['sha'];
      final String encodedContent = jsonResponse['content'];
      final decoded = utf8.decode(base64.decode(encodedContent.replaceAll('\n', '')));
      final data = json.decode(decoded) as Map<String, dynamic>;
      final List usersList = (data['users'] as List?) ?? <dynamic>[];

      bool updated = false;
      for (int i = 0; i < usersList.length; i++) {
        final u = usersList[i];
        if (u is Map<String, dynamic> && u['phone'] == phoneArg) {
          final updatedUser = Map<String, dynamic>.from(u);
          updatedUser['name'] = _nameCtrl.text.trim();
          usersList[i] = updatedUser;
          updated = true;
          break;
        }
      }

      if (!updated) throw Exception('تعذر تحديث الاسم: لم يتم العثور على المستخدم');

      final updatedContent = json.encode({'users': usersList});
      final base64Content = base64.encode(utf8.encode(updatedContent));
      final putRes = await http.put(
        url,
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github+json',
        },
        body: json.encode({'message': 'Update name ${phoneArg}', 'content': base64Content, 'sha': sha}),
      );
      if (putRes.statusCode != 200 && putRes.statusCode != 201) {
        throw Exception('تعذر حفظ الاسم');
      }
      await _fetchUser();
      if (!mounted) return;
      setState(() => nameErrorMessage = '');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final s = e.toString();
        final isNetwork = s.contains('SocketException') || s.contains('Failed') || s.contains('XMLHttpRequest');
        nameErrorMessage = isNetwork ? 'خطأ في الاتصال: الرجاء التأكد من الاتصال بالإنترنت' : s.replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => savingName = false);
    }
  }

  Future<void> _savePassword() async {
    if (user == null || phoneArg == null) return;
    final pw = _passwordCtrl.text;
    final cpw = _confirmCtrl.text;
    final old = _oldPwCtrl.text;
    if (old.isEmpty) {
      setState(() => passwordErrorMessage = 'أدخل كلمة المرور الحالية');
      return;
    }
    if (user?['password'] != old) {
      setState(() => passwordErrorMessage = 'كلمة المرور الحالية غير صحيحة');
      return;
    }
    if (pw.isEmpty) {
      setState(() => passwordErrorMessage = 'الرجاء إدخال كلمة المرور الجديدة');
      return;
    }
    if (pw.length < 6) {
      setState(() => passwordErrorMessage = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }
    if (cpw != pw) {
      setState(() => passwordErrorMessage = 'كلمة المرور غير متطابقة');
      return;
    }
    setState(() {
      passwordErrorMessage = '';
      savingPw = true;
    });

    final String token = await GitHubTokenService.getUserToken();
    const String owner = 'Hed-Mahmoud-iya-Gha-Gharib-liya';
    const String repo = 'Users';
    const String path = 'users.json';
    final url = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
      });
      if (response.statusCode != 200) {
        throw Exception('تعذر جلب الملف: ${response.statusCode}');
      }
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      final String sha = jsonResponse['sha'];
      final String encodedContent = jsonResponse['content'];
      final decoded = utf8.decode(base64.decode(encodedContent.replaceAll('\n', '')));
      final data = json.decode(decoded) as Map<String, dynamic>;
      final List usersList = (data['users'] as List?) ?? <dynamic>[];

      bool updated = false;
      for (int i = 0; i < usersList.length; i++) {
        final u = usersList[i];
        if (u is Map<String, dynamic> && u['phone'] == phoneArg) {
          final updatedUser = Map<String, dynamic>.from(u);
          updatedUser['password'] = pw;
          usersList[i] = updatedUser;
          updated = true;
          break;
        }
      }

      if (!updated) throw Exception('تعذر تحديث كلمة المرور: لم يتم العثور على المستخدم');

      final updatedContent = json.encode({'users': usersList});
      final base64Content = base64.encode(utf8.encode(updatedContent));
      final putRes = await http.put(
        url,
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github+json',
        },
        body: json.encode({'message': 'Update password ${phoneArg}', 'content': base64Content, 'sha': sha}),
      );
      if (putRes.statusCode != 200 && putRes.statusCode != 201) {
        throw Exception('تعذر حفظ كلمة المرور');
      }
      _passwordCtrl.clear();
      _confirmCtrl.clear();
      _oldPwCtrl.clear();
      if (!mounted) return;
      setState(() => passwordErrorMessage = '');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final s = e.toString();
        final isNetwork = s.contains('SocketException') || s.contains('Failed') || s.contains('XMLHttpRequest');
        passwordErrorMessage = isNetwork ? 'خطأ في الاتصال: الرجاء التأكد من الاتصال بالإنترنت' : s.replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => savingPw = false);
    }
  }
  Future<void> _confirmDelete() async {
    if (phoneArg == null) return;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.95),
            title: const Text('تأكيد حذف الحساب'),
            content: const Text('هل أنت متأكد من حذف الحساب؟ هذا الإجراء لا يمكن التراجع عنه.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6F61)),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('حذف', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
    if (ok == true) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    if (phoneArg == null) return;
    setState(() => deleting = true);

    final String token = await GitHubTokenService.getUserToken();
    const String owner = 'Hed-Mahmoud-iya-Gha-Gharib-liya';
    const String repo = 'Users';
    const String path = 'users.json';
    final url = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
      });
      if (response.statusCode != 200) {
        throw Exception('تعذر جلب الملف: ${response.statusCode}');
      }
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      final String sha = jsonResponse['sha'];
      final String encodedContent = jsonResponse['content'];
      final decoded = utf8.decode(base64.decode(encodedContent.replaceAll('\n', '')));
      final data = json.decode(decoded) as Map<String, dynamic>;
      final List usersList = (data['users'] as List?) ?? <dynamic>[];

      usersList.removeWhere((u) => u is Map<String, dynamic> && u['phone'] == phoneArg);

      final updatedContent = json.encode({'users': usersList});
      final base64Content = base64.encode(utf8.encode(updatedContent));
      final putRes = await http.put(
        url,
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github+json',
        },
        body: json.encode({'message': 'Delete user ${phoneArg}', 'content': base64Content, 'sha': sha}),
      );
      if (putRes.statusCode != 200 && putRes.statusCode != 201) {
        throw Exception('تعذر حذف الحساب');
      }

      if (!mounted) return;
      // اذهب لصفحة تسجيل الدخول مع تنظيف المكدس
      Navigator.of(context).pushNamedAndRemoveUntil('/signin', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => deleting = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (phoneArg == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['phone'] is String) {
        phoneArg = args['phone'] as String;
        _isAdmin = phoneArg == '01147857132';
      }
      _fetchUser();
    }
  }

  Future<void> _fetchUserStats() async {
    if (!_isAdmin) return;
    
    setState(() => _loadingStats = true);
    
    try {
      final String token = await GitHubTokenService.getUserToken();
      const String owner = 'Hed-Mahmoud-iya-Gha-Gharib-liya';
      const String repo = 'Users';
      const String path = 'users.json';
      final url = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');

      final response = await http.get(url, headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
      });

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final String encodedContent = jsonResponse['content'];
        final decoded = utf8.decode(base64.decode(encodedContent.replaceAll('\n', '')));
        final data = json.decode(decoded);
        final List users = data['users'] ?? [];
        
        if (mounted) {
          setState(() => _totalUsers = users.length);
        }
      }
    } catch (e) {
      // Silent error handling for stats
    } finally {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _fetchUser() async {
    setState(() {
      loading = true;
      error = null;
    });

    final String token = await GitHubTokenService.getUserToken();
    const String owner = 'Hed-Mahmoud-iya-Gha-Gharib-liya';
    const String repo = 'Users';
    const String path = 'users.json';
    final url = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/$path');

    try {
      final res = await http.get(url, headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github+json',
      });
      if (res.statusCode != 200) {
        throw Exception('فشل في جلب البيانات: ${res.statusCode}');
      }
      final jsonResponse = json.decode(res.body) as Map<String, dynamic>;
      final String encodedContent = jsonResponse['content'];
      final decoded = utf8.decode(base64.decode(encodedContent.replaceAll('\n', '')));
      final data = json.decode(decoded) as Map<String, dynamic>;
      final List users = (data['users'] as List?) ?? <dynamic>[];

      Map<String, dynamic>? found;
      if (phoneArg != null) {
        for (final u in users) {
          if (u is Map<String, dynamic> && u['phone'] == phoneArg) {
            found = u;
            break;
          }
        }
      }

      setState(() {
        user = found;
        loading = false;
        if (found == null) {
          error = 'لم يتم العثور على المستخدم';
        }
        _nameCtrl.text = (found?['name'] ?? '').toString();
        _passwordCtrl.clear();
        _confirmCtrl.clear();
        _oldPwCtrl.clear();
      });
      
      // جلب الإحصائيات للأدمن
      if (_isAdmin) {
        _fetchUserStats();
      }
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (ModalRoute.of(context)?.settings.name != '/home') {
                Navigator.pushReplacementNamed(context, '/home', arguments: {'phone': phoneArg});
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: const Text('الملف الشخصي', style: TextStyle(fontWeight: FontWeight.w800)),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : error != null
                      ? _glass(
                          child: Center(
                            child: Text(error!, style: const TextStyle(color: Colors.white)),
                          ),
                        )
                      : Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: _glass(
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                    child: Column(
                                      children: [
                                        const CircleAvatar(radius: 38, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 34)),
                                        const SizedBox(height: 12),
                                        Text(user?['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                                        const SizedBox(height: 4),
                                        Text(user?['phone'] ?? '', style: const TextStyle(color: Colors.white70)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_isAdmin) ...[
                                  _glass(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.admin_panel_settings, color: Colors.amber.shade300, size: 20),
                                            const SizedBox(width: 8),
                                            const Text('إحصائيات الأدمن', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.amber.withOpacity(0.15), Colors.amber.withOpacity(0.08)],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(Icons.group, color: Colors.amber.shade300, size: 24),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'إجمالي المستخدمين المسجلين',
                                                      style: TextStyle(color: Colors.amber.shade100, fontSize: 14, fontWeight: FontWeight.w600),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    _loadingStats
                                                        ? SizedBox(
                                                            width: 16,
                                                            height: 16,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Colors.amber.shade300,
                                                            ),
                                                          )
                                                        : Text(
                                                            '$_totalUsers مستخدم',
                                                            style: TextStyle(color: Colors.amber.shade200, fontSize: 18, fontWeight: FontWeight.w800),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                _glass(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Text('تعديل الاسم', style: TextStyle(color: Colors.white70)),
                                      const SizedBox(height: 8),
                                      if (nameErrorMessage.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          margin: const EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.amber.withOpacity(0.15), Colors.amber.withOpacity(0.08)],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.amber.withOpacity(0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.info_outline_rounded, color: Colors.amber.shade300, size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  nameErrorMessage,
                                                  style: TextStyle(color: Colors.amber.shade100, fontSize: 14, fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      TextFormField(
                                        controller: _nameCtrl,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: _inputDecoration(hint: 'اسمك'),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) return 'الرجاء إدخال الاسم';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 44,
                                        child: ElevatedButton(
                                          onPressed: savingName ? null : _saveName,
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(colors: [Color(0xFFFF6F61), Color(0xFF8E24AA)]),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: savingName
                                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                                                  : const Text('حفظ الاسم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _glass(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Text('تغيير كلمة المرور (اختياري)', style: TextStyle(color: Colors.white70)),
                                      const SizedBox(height: 8),
                                      if (passwordErrorMessage.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          margin: const EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.amber.withOpacity(0.15), Colors.amber.withOpacity(0.08)],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.amber.withOpacity(0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.info_outline_rounded, color: Colors.amber.shade300, size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  passwordErrorMessage,
                                                  style: TextStyle(color: Colors.amber.shade100, fontSize: 14, fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      TextFormField(
                                        controller: _oldPwCtrl,
                                        obscureText: _obscureOldPw,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: _inputDecoration(
                                          hint: 'كلمة المرور الحالية',
                                          suffixIcon: IconButton(
                                            icon: Icon(_obscureOldPw ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70),
                                            onPressed: () => setState(() => _obscureOldPw = !_obscureOldPw),
                                          ),
                                        ),
                                        validator: (v) {
                                          if (_passwordCtrl.text.isNotEmpty || _confirmCtrl.text.isNotEmpty) {
                                            if (v == null || v.isEmpty) return 'أدخل كلمة المرور الحالية';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _passwordCtrl,
                                        obscureText: _obscurePw,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: _inputDecoration(
                                          hint: '•••••••',
                                          suffixIcon: IconButton(
                                            icon: Icon(_obscurePw ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70),
                                            onPressed: () => setState(() => _obscurePw = !_obscurePw),
                                          ),
                                        ),
                                        validator: (v) {
                                          if (v != null && v.isNotEmpty && v.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _confirmCtrl,
                                        obscureText: _obscurePw2,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: _inputDecoration(
                                          hint: 'تأكيد كلمة المرور',
                                          suffixIcon: IconButton(
                                            icon: Icon(_obscurePw2 ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70),
                                            onPressed: () => setState(() => _obscurePw2 = !_obscurePw2),
                                          ),
                                        ),
                                        validator: (v) {
                                          if (_passwordCtrl.text.isNotEmpty && v != _passwordCtrl.text) return 'كلمة المرور غير متطابقة';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 44,
                                        child: ElevatedButton(
                                          onPressed: savingPw ? null : _savePassword,
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(colors: [Color(0xFFFF6F61), Color(0xFF8E24AA)]),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: savingPw
                                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                                                  : const Text('حفظ كلمة المرور', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: deleting ? null : _confirmDelete,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFFF7043)]),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        child: deleting
                                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white))
                                            : const Text('حذف الحساب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
          ),
        ),
      ),
    ),
  );
  }

  Widget _glass({required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(16)}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: child,
    );
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.amber.withOpacity(0.6), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.amber.shade300, width: 2),
      ),
      errorStyle: TextStyle(
        color: Colors.amber.shade200,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
      suffixIcon: suffixIcon,
    );
  }
}
