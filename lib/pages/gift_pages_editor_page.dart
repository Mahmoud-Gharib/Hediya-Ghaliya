import 'package:flutter/material.dart';
import '../models/gift.dart';

class GiftPagesEditorPage extends StatefulWidget {
  final Gift gift;
  const GiftPagesEditorPage({super.key, required this.gift});

  @override
  State<GiftPagesEditorPage> createState() => _GiftPagesEditorPageState();
}

class _GiftPagesEditorPageState extends State<GiftPagesEditorPage> {
  late List<Map<String, dynamic>> pages;

  @override
  void initState() {
    super.initState();
    final d = widget.gift.details ?? {};
    final raw = (d['pages'] as List?)?.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
    pages = raw ?? <Map<String, dynamic>>[];
  }

  void _editPageBlocks(int index) async {
    final page = pages[index];
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.7),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final blocks = (page['blocks'] as List?)?.cast<Map>().map((e) => e.cast<String, dynamic>()).toList() ?? [];
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: StatefulBuilder(
              builder: (context, setLocal) => Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('تحرير: ${page['title'] ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: blocks.length,
                        itemBuilder: (context, i) {
                          final b = blocks[i];
                          final type = (b['type'] ?? '').toString();
                          if (type == 'text' || type == 'quote') {
                            final controller = TextEditingController(text: (b['content'] ?? '').toString());
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TextFormField(
                                controller: controller,
                                style: const TextStyle(color: Colors.white),
                                maxLines: type == 'quote' ? 3 : null,
                                decoration: InputDecoration(
                                  labelText: type == 'quote' ? 'اقتباس' : 'نص',
                                  labelStyle: const TextStyle(color: Colors.white70),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.08),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onChanged: (v) => b['content'] = v,
                              ),
                            );
                          }
                          if (type == 'image') {
                            return ListTile(
                              title: const Text('صورة', style: TextStyle(color: Colors.white)),
                              subtitle: Text((b['content'] ?? '').toString().isEmpty ? 'لم يتم اختيار صورة' : (b['content'] ?? '').toString(), style: const TextStyle(color: Colors.white70)),
                              trailing: const Icon(Icons.image_outlined, color: Colors.white),
                              onTap: () {
                                // يمكن لاحقًا ربطه بمُلتقط صور/ملفات
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختيار الصور قادم قريبًا')));
                              },
                            );
                          }
                          return ListTile(
                            title: Text('بلوك: $type', style: const TextStyle(color: Colors.white)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          pages[index]['blocks'] = blocks;
                        });
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.save, color: Colors.white),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6F61)),
                      label: const Text('حفظ التعديلات', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تحرير صفحات الهدية', style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                final g = widget.gift;
                final d = (g.details ?? <String, dynamic>{});
                d['pages'] = pages;
                g.details = d;
                Navigator.pop(context, g);
              },
              icon: const Icon(Icons.check),
              tooltip: 'تم',
            )
          ],
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
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pages.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = pages.removeAt(oldIndex);
                  pages.insert(newIndex, item);
                });
              },
              itemBuilder: (context, i) {
                final p = pages[i];
                return Card(
                  key: ValueKey(p['id'] ?? i),
                  color: Colors.white.withOpacity(0.12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.drag_handle, color: Colors.white70),
                    title: Text(p['title']?.toString() ?? 'صفحة', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    subtitle: Text(p['type']?.toString() ?? '-', style: const TextStyle(color: Colors.white70)),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () => _editPageBlocks(i),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
