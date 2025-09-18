import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  static const routeName = '/about';
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Explicitly go to Home
              if (ModalRoute.of(context)?.settings.name != '/home') {
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: const Text('عن التطبيق', style: TextStyle(fontWeight: FontWeight.w800)),
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
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Hero(
                    tag: 'gift_logo',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 12)),
                        ],
                      ),
                      child: const Image(
                        image: AssetImage('assets/images/Logo.png'),
                        width: 110,
                        height: 110,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 12)),
                    ],
                  ),
                  child: const Text(
                    '"هدية غالية" تطبيق مصمم ليجعل مشاركة اللحظات والهدايا أكثر دفئًا وجمالًا.\n\n'
                    'هدفنا هو تسهيل إنشاء هدايا رقمية فريدة — بطاقات تهنئة، صور، رسائل صوتية وفيديو — ضمن تجربة سلسة ومبهجة.\n\n'
                    'مزايا التطبيق:\n'
                    '• إنشاء هدية بسهولة عبر قوالب جاهزة وأدوات بسيطة.\n'
                    '• حفظ الهدايا كمَسودات وإكمالها لاحقًا.\n'
                    '• تنظيم الهدايا، المفضلة، والإشعارات في مكان واحد.\n'
                    '• دعم اللغة العربية واتجاه الكتابة من اليمين لليسار.\n\n'
                    'يستخدم التطبيق تصميمًا حديثًا بواجهات زجاجية وخلفيات متدرجة،\n'
                    'مع اهتمام بالتفاصيل البصرية والانتقالات السلسة بين الصفحات.\n\n'
                    'فريق العمل يواصل تطوير مزايا جديدة وتحسين الأداء والأمان.\n'
                    'إذا كانت لديك اقتراحات، يسعدنا سماع رأيك!'
                    ,
                    style: TextStyle(color: Colors.white, height: 1.6),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Text('الإصدار: v1.0.1', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
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
