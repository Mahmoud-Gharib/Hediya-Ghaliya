import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notifications_api.dart';
import '../models/package.dart';
import 'sign_in_page.dart';
import '../services/navigation.dart';

class HomePage extends StatefulWidget 
{
  static const routeName = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _phoneArg;
  int _unreadAppBar = 0;
  Timer? _badgeTimer;
  final GlobalKey<_MainDrawerState> _drawerKey = GlobalKey<_MainDrawerState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['phone'] is String) {
      if (_phoneArg != args['phone']) {
        _phoneArg = args['phone'] as String;
        _loadUnreadAppBar();
        _startBadgePolling();
      }
    }
  }

  void _startBadgePolling() {
    _badgeTimer?.cancel();
    // Poll every 1 second to keep unread badge fresh while on home
    _badgeTimer = Timer.periodic(const Duration(seconds: 1), (_) => _loadUnreadAppBar());
  }

  @override
  void dispose() {
    _badgeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadAppBar() async {
    final phone = _phoneArg;
    if (phone == null || phone.isEmpty) return;
    try {
      final data = await NotificationsApi.fetch(phone);
      final prefs = await SharedPreferences.getInstance();
      final read = (prefs.getStringList('notif_read_ids_$phone') ?? []).toSet();
      final unread = data.items.where((e) => !read.contains(e.id)).length;
      if (!mounted) return;
      setState(() => _unreadAppBar = unread);
      // تحديث بادج المنيو تلقائيًا
      _drawerKey.currentState?._loadUnread();
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الصفحة الرئيسية', style: TextStyle(fontWeight: FontWeight.w800)),
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
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 6),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/notifications', arguments: {'phone': _phoneArg});
                      _loadUnreadAppBar();
                    },
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _badge(_unreadAppBar),
                  ),
                ],
              ),
            ),
          ],
        ),
        drawer: _MainDrawer(key: _drawerKey, phone: _phoneArg),
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
                _HeaderLogo(),
                const SizedBox(height: 16),
                _QuickActions(),
                const SizedBox(height: 16),
                _DashboardCards(phone: _phoneArg, unread: _unreadAppBar),
                const SizedBox(height: 16),
                _SuggestedTemplates(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/create'),
          backgroundColor: const Color(0xFFFF6F61),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('إنشاء هدية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

Widget _badge(int count) {
  if (count <= 0) return const SizedBox.shrink();
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(10)),
    child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
  );
}

Widget _drawerItemWithBadge(BuildContext context, {required IconData icon, required String label, required String route, required int badge, String? phone}) {
  return ListTile(
    leading: Icon(icon, color: Colors.white),
    title: Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white))),
        _badge(badge),
      ],
    ),
    onTap: () async {
      Navigator.pop(context);
      if (route == '/notifications') {
        // Always push and pass phone to ensure notifications load for the right user
        await Navigator.pushNamed(context, route, arguments: {'phone': phone});
        // بعد العودة: تحديث عداد الدرج نفسه
        final drawer = context.findAncestorStateOfType<_MainDrawerState>();
        await drawer?._loadUnread();
        // وإعلام الصفحة الرئيسية لتحديث عداد الهيدر
        final home = context.findAncestorStateOfType<_HomePageState>();
        home?._loadUnreadAppBar();
        return;
      }
      if (ModalRoute.of(context)?.settings.name != route) {
        Navigator.pushReplacementNamed(context, route);
      }
    },
  );
}

class _HeaderLogo extends StatelessWidget {
  const _HeaderLogo();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Hero(
        tag: 'gift_logo',
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 12))],
          ),
          child: const Image(
            image: AssetImage('assets/images/Logo.png'),
            width: 90,
            height: 90,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _GlassCard({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: child,
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('إجراءات سريعة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          // إنشاء هدية في المنتصف
          Center(
            child: _CreateGiftButton(
              onTap: () => Navigator.pushNamed(context, '/create'),
            ),
          ),
          const SizedBox(height: 16),
          const Text('الباقات المتاحة', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          // الباقات في صفوف (اثنين في كل صف)
          _PackagesGrid(),
        ],
      ),
    );
  }
}

class _CreateGiftButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateGiftButton({required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6F61), Color(0xFF8E24AA)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              'إنشاء هدية جديدة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackagesGrid extends StatelessWidget {
  const _PackagesGrid();
  
  @override
  Widget build(BuildContext context) {
    final packages = GiftPackage.packages;
    
    return Column(
      children: [
        // الصف الأول: المجانية والبرونزية
        Row(
          children: [
            Expanded(
              child: _PackageCard(package: packages[0]), // المجانية
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PackageCard(package: packages[1]), // البرونزية
            ),
          ],
        ),
        const SizedBox(height: 12),
        // الصف الثاني: الفضية والذهبية
        Row(
          children: [
            Expanded(
              child: _PackageCard(package: packages[2]), // الفضية
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PackageCard(package: packages[3]), // الذهبية
            ),
          ],
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final GiftPackage package;
  const _PackageCard({required this.package});
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/create', arguments: {'selectedPackage': package.type}),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              package.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              package.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              package.price == 0 ? 'مجاناً' : '${package.price.toInt()} ج.م',
              style: TextStyle(
                color: package.price == 0 ? Colors.green.shade300 : Colors.amber.shade300,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionChip({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _DashboardCards extends StatelessWidget {
  final String? phone;
  final int? unread;
  const _DashboardCards({this.phone, this.unread});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _SmallCard(title: 'هداياي', subtitle: 'آخر الهدايا', icon: Icons.card_giftcard, route: '/gifts', phone: phone)),
            const SizedBox(width: 12),
            Expanded(child: _SmallCard(title: 'آخر هدية', subtitle: 'آخر هدية أنشأتها', icon: Icons.star, route: '/latest-gift', phone: phone)),
          ],
        ),
        const SizedBox(height: 12),
        _SmallCard(title: 'الإشعارات', subtitle: 'الجديد لديك', icon: Icons.notifications_none, route: '/notifications', phone: phone, unread: unread ?? 0),
      ],
    );
  }
}

class _SmallCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final String? phone;
  final int unread;
  const _SmallCard({required this.title, required this.subtitle, required this.icon, required this.route, this.phone, this.unread = 0});
  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: route == '/notifications' ? _badge(unread) : null,
        onTap: () async {
          if ((route == '/notifications' || route == '/gifts') && phone != null) {
            await Navigator.pushNamed(context, route, arguments: {'phone': phone});
          } else {
            await Navigator.pushNamed(context, route);
          }
          // بعد العودة من صفحة الإشعارات: حدّث عداد الهيدر بالصفحة الرئيسية
          if (route == '/notifications') {
            final home = context.findAncestorStateOfType<_HomePageState>();
            home?._loadUnreadAppBar();
          }
        },
      ),
    );
  }
}

class _SuggestedTemplates extends StatelessWidget {
  const _SuggestedTemplates();
  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('مقترحة لك', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => Container(
                width: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [Color(0xFFFF6F61), Color(0xFF8E24AA)]),
                ),
                child: Center(
                  child: Text('قالب #${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _MainDrawer extends StatefulWidget {
  final String? phone;
  const _MainDrawer({super.key, this.phone});
  @override
  State<_MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<_MainDrawer> {
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _loadUnread();
  }

  Future<void> _loadUnread() async {
    final phone = widget.phone;
    if (phone == null || phone.isEmpty) return;
    try {
      final data = await NotificationsApi.fetch(phone);
      final prefs = await SharedPreferences.getInstance();
      final read = (prefs.getStringList('notif_read_ids_$phone') ?? []).toSet();
      final unread = data.items.where((e) => !read.contains(e.id)).length;
      if (!mounted) return;
      setState(() => _unread = unread);
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF311B92), Color(0xFF8E24AA), Color(0xFFFF6F61)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Hero(
                      tag: 'gift_logo',
                      child: Image(
                        image: AssetImage('assets/images/Logo.png'),
                        width: 72,
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('هدية غالية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('مرحبًا بك!', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              _drawerItem(context, icon: Icons.home_outlined, label: 'الرئيسية', route: '/home'),
              _drawerItem(context, icon: Icons.card_giftcard, label: 'إنشاء هدية', route: '/create'),
              _drawerItem(context, icon: Icons.list_alt_outlined, label: 'هداياي', route: '/gifts'),
              _drawerItem(context, icon: Icons.star, label: 'آخر هدية', route: '/latest-gift'),
              
              _drawerItem(context, icon: Icons.grid_view, label: 'القوالب الجاهزة', route: '/templates'),
              _drawerItemWithBadge(context,
                  icon: Icons.notifications_none,
                  label: 'الإشعارات',
                  route: '/notifications',
                  badge: _unread,
                  phone: widget.phone),
              const Divider(color: Colors.white24, height: 24, thickness: 0.6, indent: 16, endIndent: 16),
              _drawerItem(context, icon: Icons.person_outline, label: 'الملف الشخصي', route: '/profile'),
              // Chat entry (admin/user)
              if (widget.phone != null)
                _drawerItem(
                  context,
                  icon: Icons.chat_bubble_outline,
                  label: 'الدردشة',
                  route: widget.phone == '01147857132' ? '/chat_admin' : '/chat_user',
                ),
              
              _drawerItem(context, icon: Icons.info_outline, label: 'عن التطبيق', route: '/about'),
              _drawerItem(context, icon: Icons.logout, label: 'تسجيل الخروج', route: '/signin'),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, {required IconData icon, required String label, required String route}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () async {
        // Close the drawer first
        Navigator.pop(context);
        // Intercept logout to show confirmation dialog
        if (route == '/signin') {
          final confirm = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  backgroundColor: Colors.white.withOpacity(0.95),
                  title: const Text('تأكيد تسجيل الخروج'),
                  content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6F61)),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          );
          if (confirm == true) {
            // Clear persisted login state
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('logged_in');
            await prefs.remove('phone');
            // Navigate using global navigator key to ensure we use root navigator
            await Future.delayed(const Duration(milliseconds: 60));
            appNavigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SignInPage()),
              (r) => false,
            );
          }
          return;
        }

        // Intercept profile to pass phone argument
        if (route == '/profile') {
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushReplacementNamed(context, route, arguments: {'phone': widget.phone});
          }
          return;
        }

        

        // Intercept chat routes to pass phone
        if (route == '/chat_user' || route == '/chat_admin') {
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushReplacementNamed(context, route, arguments: {'phone': widget.phone});
          }
          return;
        }

        // Intercept notifications to pass phone (use pushNamed for consistent back behavior)
        if (route == '/notifications') {
          Navigator.pushNamed(context, route, arguments: {'phone': widget.phone});
          return;
        }

        // Intercept gifts to pass phone
        if (route == '/gifts') {
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushReplacementNamed(context, route, arguments: {'phone': widget.phone});
          }
          return;
        }

        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
