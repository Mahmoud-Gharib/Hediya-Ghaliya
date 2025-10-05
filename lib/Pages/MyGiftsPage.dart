import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:hediya_ghaliya/Services/GithubToken.dart';

class MyGiftsPage extends StatefulWidget {
  static const routeName = '/gifts';
  const MyGiftsPage({super.key});

  @override
  State<MyGiftsPage> createState() => _MyGiftsPageState();
}

class _MyGiftsPageState extends State<MyGiftsPage> 
{
  final String username = 'mahmoud-gharib';
  // جرب الأسماء دي واحد واحد:
  // 'Hediya-Ghaliya' أو 'hediya-ghaliya' أو 'app_upload'
  final List<String> repos = ['Hediya-Ghaliya' , 'app_upload']; // غير الاسم حسب الـ repo الموجود عندك 
  final String fileKeyword = 'apk';
  String? userPhone;

  bool isLoading = false;

  final List<_ReleaseItem> _releases = [];
  List<_ReleaseItem> _filtered = [];

  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      print('📞 Arguments المستلمة: $args');
      if (args is Map && args['phone'] is String) {
        userPhone = args['phone'] as String;
        print('✅ تم استلام رقم الهاتف: $userPhone');
      } else {
        print('⚠️ لم يتم استلام رقم الهاتف!');
      }
      fetchReleases();
    });
  }

  Future<void> fetchReleases() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    _releases.clear(); // Clear existing releases
    
    // Fetch from all repositories
    for (final repo in repos) {
      await _fetchFromRepository(repo);
    }

    _applyFilter();
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _fetchFromRepository(String repo) async {
    try {
      print('🔍 بدء جلب البيانات من: $repo');
      print('📱 رقم المستخدم: $userPhone');
      
      // جلب الـ token بشكل آمن
      String? token;
      try {
        token = await GitHubTokenService.getTokenForRepository(repo);
        print('✅ تم جلب token بنجاح');
      } catch (e) {
        print('⚠️ تحذير: فشل في جلب token لـ $repo، سيتم المحاولة بدون token: $e');
      }
      
      int page = 1;
      bool hasMoreInRepo = true;
      
      // Fetch all pages from this repository
      while (hasMoreInRepo) {
        final url = 'https://api.github.com/repos/$username/$repo/releases?page=$page&per_page=100';
        
        // إعداد الـ headers مع أو بدون token
        final headers = <String, String>{
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'HediyaGhaliya/1.0',
        };
        
        // إضافة الـ token إذا كان متوفراً
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
        
        print('🌐 الرابط: $url');
        final response = await http.get(Uri.parse(url), headers: headers);
        print('📊 Status Code: ${response.statusCode}');

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          print('📦 عدد الـ releases: ${data.length}');
          
          if (data.isEmpty) {
            print('⚠️ لا توجد releases في هذه الصفحة');
            hasMoreInRepo = false;
          } else {
            for (final release in data) {
              final publishedAt = release['published_at'] as String? ?? '';
              final assets = (release['assets'] as List<dynamic>? ?? []);
              print('📁 عدد الملفات في الـ release: ${assets.length}');
              
              final matchedAssets = assets.where((asset) {
                final name = (asset['name'] as String? ?? '').toLowerCase();
                final phone = (userPhone ?? '').toLowerCase();
                
                // الأدمن: يرى كل الملفات اللي تحتوي على apk
                if (phone == '01147857132') {
                  return name.contains(fileKeyword.toLowerCase());
                }
                
                // المستخدم العادي: يرى فقط الملفات اللي تحتوي على apk ورقم تليفونه
                return name.contains(fileKeyword.toLowerCase()) && (phone.isEmpty || name.contains(phone));
              }).toList();
              
              print('✅ عدد الملفات المطابقة: ${matchedAssets.length}');

              for (final asset in matchedAssets) {
                final fileName = asset['name'] as String? ?? 'file';
                print('➕ إضافة ملف: $fileName');
                _releases.add(_ReleaseItem(
                  dateIso: publishedAt,
                  name: asset['name'] as String? ?? 'file',
                  url: asset['browser_download_url'] as String? ?? '',
                  repository: repo, // Add repository info
                ));
              }
            }
            page++;
          }
        } else {
          // If repo doesn't exist or has no access, continue to next repo
          print('❌ خطأ: Status Code ${response.statusCode}');
          print('📄 Response: ${response.body}');
          hasMoreInRepo = false;
        }
      }
    } catch (e) {
      // Continue with other repositories if one fails
      print('💥 خطأ في جلب البيانات من $repo: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  void _applyFilter() {
    if (selectedDate == null) {
      _filtered = List.from(_releases);
    } else {
      final target = DateFormat('yyyy-MM-dd').format(selectedDate!);
      _filtered = _releases.where((r) => r.dateIso.startsWith(target)).toList();
    }
    _filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    if (mounted) setState(() {});
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      locale: const Locale('ar'),
    );
    if (picked != null) {
      selectedDate = picked;
      _applyFilter();
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
        title: const Text('🎁 هداياي الغالية', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_today), tooltip: 'اختيار تاريخ', onPressed: _pickDate),
          if (selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'مسح الفلتر',
              onPressed: () {
                selectedDate = null;
                _applyFilter();
              },
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
                  child: Text('الهدايا الخاصة بك', style: titleStyle.copyWith(color: Colors.white, fontSize: 20)),
                ),
                const SizedBox(height: 12),
                if (selectedDate != null)
                  Center(
                    child: Text(
                      '📅 ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 12),
                Expanded(
                  child: _buildResponsiveTable(context),
                ),
                if (isLoading) ...[
                  const SizedBox(height: 12),
                  const Center(child: CircularProgressIndicator(color: Colors.white)),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'جاري تحميل جميع الهدايا ...',
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

  Widget _buildResponsiveTable(BuildContext context) {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.info_outline, size: 40, color: Colors.white70),
            SizedBox(height: 8),
            Text('لا توجد هداياي متاحة', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Ultra-narrow screens: use compact list layout
        if (constraints.maxWidth < 420) {
          return _buildCompactList(context);
        }

        // DataTable with dynamic name column width to avoid overflow
        const dateColWidth = 112.0; // yyyy-MM-dd
        const timeColWidth = 92.0;  // hh:mm a
        const shareColWidth = 64.0; // share button
        const paddings = 48.0; // margins within table rows
        final nameWidth = (constraints.maxWidth - dateColWidth - timeColWidth - shareColWidth - paddings).clamp(180.0, 400.0);

        const columns = [
          DataColumn(label: Text('الاسم')),
          DataColumn(label: Text('التاريخ')),
          DataColumn(label: Text('الوقت')),
          DataColumn(label: Text('مشاركة')),
        ];
        final rows = _filtered.map((r) {
          final date = r.dateTime;
          final dateStr = DateFormat('yyyy-MM-dd').format(date);
          final timeStr = DateFormat('hh:mm a').format(date);
          final name = userPhone != null ? r.name.replaceAll(userPhone!, '').trim() : r.name;
          return DataRow(cells: [
            DataCell(SizedBox(width: nameWidth, child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)))),
            DataCell(Text(dateStr, style: const TextStyle(color: Colors.white))),
            DataCell(Text(timeStr, style: const TextStyle(color: Colors.white))),
            DataCell(IconButton(icon: const Icon(Icons.share, color: Colors.lightBlue), onPressed: () => _shareFile(r.url, r.name))),
          ]);
        }).toList();

        final table = Theme(
          data: Theme.of(context).copyWith(
            cardColor: Colors.white.withOpacity(0.08),
            dividerColor: Colors.white24,
            dataTableTheme: DataTableThemeData(
              headingRowColor: WidgetStatePropertyAll(Colors.white.withOpacity(0.10)),
              dataRowColor: WidgetStatePropertyAll(Colors.white.withOpacity(0.06)),
              headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              dataTextStyle: const TextStyle(color: Colors.white70),
            ),
          ),
          child: DataTable(columns: columns, rows: rows, columnSpacing: 12, horizontalMargin: 12),
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: table,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactList(BuildContext context) 
  {
    return SingleChildScrollView
	(
      child: Column
	  (
        children: List.generate(_filtered.length * 2 - 1, (index) 
		{
          if (index.isOdd) 
		  {
            return const SizedBox(height: 8);
          }
          final i = index ~/ 2;
          final r = _filtered[i];
          final dt = r.dateTime;
          final dateStr = DateFormat('yyyy-MM-dd').format(dt);
          final timeStr = DateFormat('hh:mm a').format(dt);
          final name = userPhone != null ? r.name.replaceAll(userPhone!, '').trim() : r.name;
          return Container
		  (
            decoration: BoxDecoration
			(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: ListTile
			(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              leading: const Icon(Icons.card_giftcard, color: Colors.amber),
              title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
              subtitle: Text('$dateStr  •  $timeStr', style: const TextStyle(color: Colors.white70)),
              trailing: IconButton
			  (
                icon: const Icon(Icons.share, color: Colors.lightBlue),
                onPressed: () => _shareFile(r.url, r.name),
                tooltip: 'مشاركة',
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ReleaseItem 
{
  final String dateIso;
  final String name;
  final String url;
  final String repository;
  const _ReleaseItem({required this.dateIso, required this.name, required this.url, required this.repository});
  DateTime get dateTime => DateTime.tryParse(dateIso)?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);
}
