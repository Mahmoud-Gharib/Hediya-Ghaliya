import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class LatestGiftPage extends StatefulWidget {
  static const routeName = '/latest-gift';
  const LatestGiftPage({super.key});

  @override
  State<LatestGiftPage> createState() => _LatestGiftPageState();
}

class _LatestGiftPageState extends State<LatestGiftPage> {
  final String username = 'mahmoud-gharib';
  final List<String> repos = ['app_upload', 'Hediya-Ghaliya']; // Multiple repositories
  final String fileKeyword = 'apk';
  String? userPhone;

  bool isLoading = false;
  _ReleaseItem? latestGift;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['phone'] is String) {
        userPhone = args['phone'] as String;
      }
      fetchLatestGift();
    });
  }

  Future<void> fetchLatestGift() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    List<_ReleaseItem> allGifts = [];
    
    // Fetch from all repositories
    for (final repo in repos) {
      await _fetchFromRepository(repo, allGifts);
    }

    // Find the latest gift by date and time
    if (allGifts.isNotEmpty) {
      allGifts.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      latestGift = allGifts.first;
    }

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _fetchFromRepository(String repo, List<_ReleaseItem> allGifts) async {
    try {
      int page = 1;
      bool hasMoreInRepo = true;
      
      // Fetch all pages from this repository
      while (hasMoreInRepo) {
        final url = 'https://api.github.com/repos/$username/$repo/releases?page=$page&per_page=100';
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          if (data.isEmpty) {
            hasMoreInRepo = false;
          } else {
            for (final release in data) {
              final publishedAt = release['published_at'] as String? ?? '';
              final assets = (release['assets'] as List<dynamic>? ?? []);
              final matchedAssets = assets.where((asset) {
                final name = (asset['name'] as String? ?? '').toLowerCase();
                final phone = (userPhone ?? '').toLowerCase();
                return name.contains(fileKeyword.toLowerCase()) && (phone.isEmpty || name.contains(phone));
              }).toList();

              for (final asset in matchedAssets) {
                allGifts.add(_ReleaseItem(
                  dateIso: publishedAt,
                  name: asset['name'] as String? ?? 'file',
                  url: asset['browser_download_url'] as String? ?? '',
                  repository: repo,
                ));
              }
            }
            page++;
          }
        } else {
          // If repo doesn't exist or has no access, continue to next repo
          hasMoreInRepo = false;
        }
      }
    } catch (e) {
      // Continue with other repositories if one fails
      print('Error fetching from repository $repo: $e');
    }
  }

  Future<void> _shareFile(String url, String fileName) async {
    try {
      // على الويب: مشاركة الرابط مباشرة
      if (kIsWeb) {
        _snack('مشاركة رابط الملف...');
        
        final shareText = '''
🎁 هدية غالية من تطبيق "هدية غالية"

اسم الملف: $fileName
رابط التحميل: $url

تطبيق هدية غالية - أجمل الهدايا الرقمية
        '''.trim();
        
        await Share.share(
          shareText,
          subject: 'مشاركة هدية غالية',
        );
        
        _snack('تم مشاركة رابط الملف');
        return;
      }
      
      // على الموبايل: تحميل الملف ومشاركته
      _snack('جاري تحضير الملف للمشاركة...');
      
      // التحقق من صحة الرابط
      if (url.isEmpty) {
        _snack('رابط الملف غير صحيح');
        return;
      }
      
      // تحميل الملف مؤقتاً
      final dio = Dio();
      
      // إعداد خيارات Dio
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 60);
      dio.options.headers = {
        'User-Agent': 'HediyaGhaliya/1.0',
      };
      
      final tempDir = await getTemporaryDirectory();
      final cleanFileName = fileName.replaceAll(RegExp(r'[^\w\-_\.\u0600-\u06FF]'), '_');
      final tempFilePath = '${tempDir.path}/$cleanFileName';
      
      // حذف الملف إذا كان موجوداً مسبقاً
      final existingFile = File(tempFilePath);
      if (existingFile.existsSync()) {
        await existingFile.delete();
      }
      
      // تحميل الملف مع progress
      await dio.download(
        url, 
        tempFilePath,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            final progress = (received / total * 100).toStringAsFixed(0);
            ScaffoldMessenger.of(context).clearSnackBars();
            _snack('تحميل: $progress%');
          }
        },
      );
      
      // التحقق من وجود الملف وحجمه
      final file = File(tempFilePath);
      if (!file.existsSync()) {
        _snack('فشل في حفظ الملف');
        return;
      }
      
      final fileSize = await file.length();
      if (fileSize == 0) {
        _snack('الملف فارغ أو تالف');
        return;
      }
      
      // مشاركة الملف
      ScaffoldMessenger.of(context).clearSnackBars();
      _snack('فتح نافذة المشاركة...');
      
      final result = await Share.shareXFiles(
        [XFile(tempFilePath)],
        text: 'هدية غالية من تطبيق "هدية غالية" 🎁\n\nاسم الملف: $fileName\nحجم الملف: ${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB',
        subject: 'مشاركة هدية غالية',
      );
      
      // تنظيف الملف المؤقت بعد المشاركة
      try {
        await file.delete();
      } catch (_) {
        // تجاهل أخطاء الحذف
      }
      
      if (result.status == ShareResultStatus.success) {
        _snack('تم مشاركة الملف بنجاح');
      } else if (result.status == ShareResultStatus.dismissed) {
        _snack('تم إلغاء المشاركة');
      } else {
        _snack('فشل في المشاركة');
      }
      
    } catch (e) {
      String errorMsg = 'فشل في تحضير الملف للمشاركة';
      
      if (kIsWeb) {
        errorMsg = 'فشل في مشاركة الرابط';
      } else if (e.toString().contains('SocketException')) {
        errorMsg = 'خطأ في الاتصال بالإنترنت';
      } else if (e.toString().contains('TimeoutException')) {
        errorMsg = 'انتهت مهلة التحميل';
      } else if (e.toString().contains('404')) {
        errorMsg = 'الملف غير موجود';
      } else if (e.toString().contains('403')) {
        errorMsg = 'غير مسموح بالوصول للملف';
      }
      
      _snack(errorMsg);
      print('Share error: $e'); // للتشخيص
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(fontWeight: FontWeight.w800);
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎁 آخر هدية', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: fetchLatestGift,
          ),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),
                Center(child: Icon(Icons.card_giftcard, size: 64, color: Colors.white.withOpacity(0.95))),
                const SizedBox(height: 10),
                Center(
                  child: Text('آخر هدية قمت بإنشائها', style: titleStyle.copyWith(color: Colors.white, fontSize: 20)),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildLatestGiftCard(),
                ),
                if (isLoading) ...[
                  const SizedBox(height: 12),
                  const Center(child: CircularProgressIndicator(color: Colors.white)),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'جاري البحث عن آخر هدية...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLatestGiftCard() {
    if (isLoading) {
      return const SizedBox.shrink();
    }

    if (latestGift == null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.card_giftcard_outlined, size: 64, color: Colors.white70),
              SizedBox(height: 16),
              Text(
                'لم يتم العثور على هدايا',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'لم تقم بإنشاء أي هدية بعد\nابدأ بإنشاء هديتك الأولى!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final gift = latestGift!;
    final date = gift.dateTime;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final timeStr = DateFormat('hh:mm a').format(date);
    final name = userPhone != null ? gift.name.replaceAll(userPhone!, '').trim() : gift.name;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gift icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.card_giftcard,
                size: 48,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 20),
            
            // Gift name
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            
            // Date and time info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        timeStr,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Share button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _shareFile(gift.url, gift.name),
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text(
                  'مشاركة الهدية',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E24AA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReleaseItem {
  final String dateIso;
  final String name;
  final String url;
  final String repository;
  const _ReleaseItem({required this.dateIso, required this.name, required this.url, required this.repository});
  DateTime get dateTime => DateTime.tryParse(dateIso)?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);
}
