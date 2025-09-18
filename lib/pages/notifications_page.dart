import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notifications_api.dart';

class NotificationsPage extends StatefulWidget {
  static const routeName = '/notifications';
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _scroll = ScrollController();
  bool _loading = true;
  List<NotificationItem> _all = [];
  String _filter = 'all'; // all | chat | gift | system
  Set<String> _readIds = {};
  late String _phone;
  // تم إيقاف التحديث الدوري بناءً على طلب المستخدم
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['phone'] is String) {
        _phone = args['phone'] as String;
      } else {
        _phone = 'UNKNOWN';
      }
      await _loadReadState();
      await _loadInitial();
      // لا نبدأ Polling بعد الآن
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  // تم إزالة التحديث الدوري

  Future<void> _loadReadState() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notif_read_ids_$_phone';
    _readIds = (prefs.getStringList(key) ?? []).toSet();
  }

  Future<void> _saveReadState() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notif_read_ids_$_phone';
    await prefs.setStringList(key, _readIds.toList());
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    try {
      final data = await NotificationsApi.fetch(_phone);
      if (!mounted) return;
      setState(() {
        _all = data.items..sort((a,b)=> (b.createdAt).compareTo(a.createdAt));
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('تعذر تحميل الإشعارات: $e');
    }
  }

  List<NotificationItem> get _filtered {
    if (_filter == 'all') return _all;
    return _all.where((e) => e.type == _filter).toList();
  }

  void _markRead(String id) {
    setState(() {
      _readIds.add(id);
    });
    _saveReadState();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإشعارات', style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: true,
          actions: const [],
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
            child: Column(
              children: [
                _filtersBar(),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _filtered.isEmpty
                          ? const Center(child: Text('لا توجد إشعارات', style: TextStyle(color: Colors.white70)))
                          : ListView.builder(
                              controller: _scroll,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(12),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) {
                                final n = _filtered[i];
                                final isUnread = !_readIds.contains(n.id);
                                return Dismissible(
                                  key: ValueKey(n.id),
                                  background: _swipeBg(alignEnd: false, color: Colors.green, icon: Icons.mark_email_read_outlined),
                                  secondaryBackground: _swipeBg(alignEnd: true, color: Colors.redAccent, icon: Icons.delete_outline),
                                  confirmDismiss: (d) async {
                                    if (d == DismissDirection.startToEnd) {
                                      _markRead(n.id);
                                      return false; // أبقه في القائمة (سحب لليسار يحذف)
                                    } else {
                                      return await _confirmDelete();
                                    }
                                  },
                                  onDismissed: (d) {
                                    // حذف محلي فقط
                                    setState(() {
                                      _all.removeWhere((e) => e.id == n.id);
                                    });
                                  },
                                  child: _tile(n, isUnread),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filtersBar() {
    Widget chip(String key, String label, IconData icon) {
      final selected = _filter == key;
      return ChoiceChip(
        selected: selected,
        onSelected: (_) => setState(() => _filter = key),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(icon, size: 16, color: Colors.white), const SizedBox(width: 6), Text(label)],
        ),
        labelStyle: const TextStyle(color: Colors.white),
        selectedColor: const Color(0xFFFF6F61).withOpacity(0.8),
        backgroundColor: Colors.white.withOpacity(0.14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white.withOpacity(0.2))),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          chip('all', 'الكل', Icons.all_inbox_outlined),
          chip('chat', 'الدردشة', Icons.chat_bubble_outline),
          chip('gift', 'الهدايا', Icons.card_giftcard),
          chip('system', 'النظام', Icons.info_outline),
        ],
      ),
    );
  }

  Widget _tile(NotificationItem n, bool isUnread) {
    final when = _fmt(n.createdAt);
    final icon = n.type == 'chat'
        ? Icons.chat_bubble_outline
        : n.type == 'gift'
            ? Icons.card_giftcard
            : Icons.info_outline;
    return InkWell(
      onTap: () => _open(n),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFFF6F61).withOpacity(0.9),
                  child: Icon(icon, color: Colors.white),
                ),
                if (isUnread)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(n.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                      Text(when, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(n.body, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _markRead(n.id),
              icon: Icon(isUnread ? Icons.mark_email_unread : Icons.mark_email_read, color: Colors.white70),
              tooltip: isUnread ? 'وضع كمقروء' : 'مقروء',
            ),
          ],
        ),
      ),
    );
  }

  Widget _swipeBg({required bool alignEnd, required Color color, required IconData icon}) {
    return Container(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: color.withOpacity(0.8),
      child: Icon(icon, color: Colors.white),
    );
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: ui.TextDirection.rtl,
            child: AlertDialog(
              title: const Text('حذف الإشعار؟'),
              content: const Text('هل تريد حذف هذا الإشعار من العرض؟ (لن يُحذف من المصدر)'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
              ],
            ),
          ),
        ) ??
        false;
  }

  void _open(NotificationItem n) {
    // عند الفتح: اعتبره مقروءًا واحذفه من القائمة فورًا
    _markRead(n.id);
    setState(() {
      _all.removeWhere((e) => e.id == n.id);
    });
    if (n.route != null) {
      Navigator.pushNamed(context, n.route!, arguments: n.args);
    }
  }

  String _fmt(String iso) {
    try {
      final dt = DateTime.tryParse(iso)?.toLocal();
      if (dt == null) return '';
      return DateFormat('dd MMM, hh:mm a', 'ar').format(dt);
    } catch (_) {
      return '';
    }
  }
}
