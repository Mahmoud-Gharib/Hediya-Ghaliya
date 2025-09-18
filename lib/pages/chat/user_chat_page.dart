import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mime/mime.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:video_player/video_player.dart';
import '../../services/github_chat_api.dart';
import '../../services/notifications_api.dart';
import '../../services/navigation.dart';

class UserChatPage extends StatefulWidget {
  static const routeName = '/chat_user';
  const UserChatPage({super.key});

  @override
  State<UserChatPage> createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {
  static const String adminPhone = '01147857132';
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  Timer? _pollTimer;
  String? _sha;
  String? _etag;
  bool _loading = true;
  bool _sending = false;
  List<Message> _messages = [];
  late String _myPhone;
  String _myName = 'User';
  bool _initialLoaded = false;
  int _otherCount = 0; // messages from admin
  
  // Media handling
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _showMediaOptions = false;
  String? _recordingPath;
  DateTime? _recordingStartAt;
  Timer? _recordingTicker;
  Duration _recordingElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Delay to access context arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['phone'] is String) {
        _myPhone = args['phone'] as String;
      } else {
        _myPhone = 'UNKNOWN';
      }
      _loadInitial();
      _startPolling();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _pollTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pullUpdates());
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    try {
      final cd = await GitHubChatApi.fetchChat(_myPhone);
      if (!mounted) return;
      
      print('📥 تم تحميل ${cd.messages.length} رسالة');
      for (var msg in cd.messages) {
        print('📨 رسالة: ${msg.type.name} - "${msg.text}" - مرفق: ${msg.attachment?.fileName}');
      }
      
      setState(() {
        _messages = cd.messages;
        _sha = cd.sha;
        _etag = cd.etag;
        _loading = false;
      });
      // baseline counts (do not ring on first load)
      _otherCount = _messages.where((m) => m.senderPhone == adminPhone).length;
      _initialLoaded = true;
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('تعذر تحميل المحادثة: $e');
    }
  }

  Future<void> _pullUpdates() async {
    try {
      final cd = await GitHubChatApi.fetchChat(_myPhone, etag: _etag);
      if (!mounted) return;
      if (cd.notModified) return;
      // detect new incoming messages from admin
      final newList = cd.messages;
      final newOther = newList.where((m) => m.senderPhone == adminPhone).length;
      final shouldRing = _initialLoaded && newOther > _otherCount;
      setState(() {
        _messages = newList;
        _sha = cd.sha;
        _etag = cd.etag;
        _otherCount = newOther;
      });
      if (shouldRing) {
        FlutterRingtonePlayer().play(
          android: AndroidSounds.notification,
          ios: IosSounds.triTone,
          looping: false,
          volume: 1.0,
          asAlarm: false,
        );
      }
      _scrollToEnd();
    } catch (_) {}
  }

  Future<void> _send({MessageType type = MessageType.text, MessageAttachment? attachment}) async {
    final text = _ctrl.text.trim();
    if (text.isEmpty && attachment == null) return;
    setState(() => _sending = true);
    final now = DateTime.now().toUtc();
    final msg = Message(
      id: '${now.millisecondsSinceEpoch}-$_myPhone',
      senderName: _myName,
      senderPhone: _myPhone,
      text: text,
      timestamp: now.toIso8601String(),
      type: type,
      attachment: attachment,
    );

    // optimistic update
    final prev = List<Message>.from(_messages);
    setState(() {
      _messages = [..._messages, msg];
    });
    _ctrl.clear();
    _scrollToEnd();
    // feedback sound for sender
    FlutterRingtonePlayer().play(
      android: AndroidSounds.notification,
      ios: IosSounds.triTone,
      looping: false,
      volume: 1.0,
      asAlarm: false,
    );

    try {
      final newSha = await GitHubChatApi.saveChat(_myPhone, _messages, sha: _sha);
      if (!mounted) return;
      setState(() => _sha = newSha);
      // Create a notification for admin about the new message
      await _upsertChatNotificationFor(adminPhone, msg);
    } catch (e) {
      if (!mounted) return;
      setState(() => _messages = prev);
      _showSnack('فشل الإرسال:الرجاء التأكد من الاتصال ب الانترنت');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // Media handling methods
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (kIsWeb) {
          await _sendWebMediaMessage(image, MessageType.image);
        } else {
          await _sendMediaMessage(image.path, MessageType.image);
        }
      }
    } catch (e) {
      _showSnack('فشل في اختيار الصورة: $e');
    }
  }

  Future<void> _takePicture() async {
    if (kIsWeb) {
      _showSnack('الكاميرا غير متاحة في المتصفح حالياً');
      return;
    }
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        await _sendMediaMessage(image.path, MessageType.image);
      }
    } catch (e) {
      _showSnack('فشل في التقاط الصورة: $e');
    }
  }

  Future<void> _sendWebMediaMessage(XFile file, MessageType type) async {
    try {
      setState(() => _sending = true);
      
      final fileName = file.name;
      final fileBytes = await file.readAsBytes();
      final fileSize = fileBytes.length;
      final mimeType = file.mimeType ?? lookupMimeType(fileName) ?? 'application/octet-stream';
      
      print('📤 بدء رفع ${type.name}: $fileName (${fileSize} bytes)');
      
      String uploadedUrl;
      
      if (type == MessageType.image) {
        final result = await GitHubChatApi.uploadImage(_myPhone, fileName, fileBytes);
        uploadedUrl = result['fileUrl'] ?? '';
      } else {
        uploadedUrl = await GitHubChatApi.uploadFile(_myPhone, fileName, fileBytes);
      }
      
      print('✅ تم رفع ${type.name}: $uploadedUrl');
      
      final attachment = MessageAttachment(
        fileName: fileName,
        fileUrl: uploadedUrl,
        mimeType: mimeType,
        fileSize: fileSize,
        thumbnailUrl: type == MessageType.image ? uploadedUrl : null,
      );
      
      await _send(type: type, attachment: attachment);
    } catch (e) {
      print('❌ خطأ في رفع ${type.name}: $e');
      _showSnack('فشل في رفع الملف: $e');
    } finally {
      setState(() => _sending = false);
    }
  }

  Future<void> _sendMediaMessage(String filePath, MessageType type) async {
    try {
      setState(() => _sending = true);
      
      final file = File(filePath);
      final fileName = file.path.split('/').last;
      final fileSize = await file.length();
      final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
      final fileBytes = await file.readAsBytes();
      
      String uploadedUrl;
      
      if (type == MessageType.image) {
        final result = await GitHubChatApi.uploadImage(_myPhone, fileName, fileBytes);
        uploadedUrl = result['fileUrl'] ?? '';
      } else {
        uploadedUrl = await GitHubChatApi.uploadFile(_myPhone, fileName, fileBytes);
      }
      
      final attachment = MessageAttachment(
        fileName: fileName,
        fileUrl: uploadedUrl,
        mimeType: mimeType,
        fileSize: fileSize,
        thumbnailUrl: type == MessageType.image ? uploadedUrl : null,
      );
      
      await _send(type: type, attachment: attachment);
    } catch (e) {
      _showSnack('فشل في رفع الملف: $e');
    } finally {
      setState(() => _sending = false);
    }
  }

  Future<void> _pickFile() async {
    try {
      final XFile? file = await openFile();
      if (file != null) {
        if (kIsWeb) {
          await _sendWebMediaMessage(file, MessageType.file);
        } else {
          await _sendMediaMessage(file.path, MessageType.file);
        }
      }
    } catch (e) {
      _showSnack('فشل في اختيار الملف: $e');
    }
  }


  Future<void> _startRecording() async {
    try {
      if (!kIsWeb) {
        final permission = await Permission.microphone.request();
        if (permission != PermissionStatus.granted) {
          _showSnack('يجب السماح بالوصول للميكروفون');
          return;
        }

        final tempDir = Directory.systemTemp;
        final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        final filePath = '${tempDir.path}/$fileName';
        
        await _audioRecorder.start(const RecordConfig(), path: filePath);
        setState(() {
          _isRecording = true;
          _recordingPath = filePath;
          _recordingStartAt = DateTime.now();
          _recordingElapsed = Duration.zero;
        });
        _recordingTicker?.cancel();
        _recordingTicker = Timer.periodic(const Duration(milliseconds: 200), (_) {
          if (!mounted || !_isRecording || _recordingStartAt == null) return;
          setState(() {
            _recordingElapsed = DateTime.now().difference(_recordingStartAt!);
          });
        });
      } else {
        _showWebVoiceRecordingDialog();
      }
    } catch (e) {
      _showSnack('فشل في بدء التسجيل: $e');
    }
  }

  void _showWebVoiceRecordingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رسالة صوتية'),
        content: const Text('تسجيل الصوت غير متاح في المتصفح. يمكنك كتابة نص الرسالة الصوتية:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _sendVoiceTextMessage();
            },
            child: const Text('إرسال كنص'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendVoiceTextMessage() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      _showSnack('اكتب نص الرسالة أولاً');
      return;
    }
    
    final attachment = MessageAttachment(
      fileName: 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
      fileUrl: '',
      mimeType: 'audio/m4a',
      fileSize: text.length,
      duration: 0,
    );
    
    await _send(type: MessageType.voice, attachment: attachment);
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      _recordingTicker?.cancel();
      _recordingTicker = null;
      
      if (path != null) {
        await _sendVoiceMessage(path);
      }
    } catch (e) {
      _showSnack('فشل في إيقاف التسجيل: $e');
    }
  }

  Future<void> _sendVoiceMessage(String path) async {
    try {
      setState(() => _sending = true);
      final file = File(path);
      final bytes = await file.readAsBytes();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      print('📤 بدء رفع الملف الصوتي: $fileName');
      final fileUrl = await GitHubChatApi.uploadFile(_myPhone, fileName, bytes);
      print('✅ تم رفع الملف الصوتي: $fileUrl');
      
      final attachment = MessageAttachment(
        fileName: fileName,
        fileUrl: fileUrl,
        mimeType: 'audio/m4a',
        fileSize: bytes.length,
        duration: 0,
      );

      await _send(
        type: MessageType.voice,
        attachment: attachment,
      );
    } catch (e) {
      print('❌ خطأ في رفع الملف الصوتي: $e');
      _showSnack('فشل في إرسال الرسالة الصوتية: $e');
    } finally {
      setState(() => _sending = false);
    }
  }

  Future<void> _playVoiceMessage(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      _showSnack('فشل في تشغيل الرسالة الصوتية: $e');
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showSnack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/home',
                (r) => false,
                arguments: {'phone': _myPhone},
              );
            },
          ),
          title: const Text('الدعم', style: TextStyle(fontWeight: FontWeight.w800)),
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
            child: Column(
              children: [
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.all(12),
                          itemCount: _messages.length,
                          itemBuilder: (ctx, i) {
                            final m = _messages[i];
                            final isMe = m.senderPhone == _myPhone;
                            return _bubble(m, isMe);
                          },
                        ),
                ),
                _composer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bubble(Message m, bool isMe) {
    final time = _formatTime(m.timestamp);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFFF6F61).withOpacity(0.9) : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(m.senderName.isEmpty ? 'الدعم' : m.senderName,
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
            _buildMessageContent(m),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(time, style: const TextStyle(fontSize: 11, color: Colors.white60)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(Message m) {
    print('🔍 عرض رسالة من نوع: ${m.type.name} - النص: "${m.text}" - المرفق: ${m.attachment?.fileName}');
    
    // Force rebuild with explicit type checking
    if (m.type == MessageType.voice) {
      print('🎤 بناء رسالة صوتية مباشرة');
      return _buildVoiceMessage(m);
    } else if (m.type == MessageType.image) {
      print('🖼️ بناء رسالة صورة مباشرة');
      return _buildImageMessage(m);
    } else if (m.type == MessageType.video) {
      print('🎬 بناء رسالة فيديو');
      return _buildVideoMessage(m);
    } else if (m.type == MessageType.file) {
      print('📎 بناء رسالة ملف مباشرة');
      return _buildFileMessage(m);
    } else {
      print('💬 بناء رسالة نصية');
      return Text(m.text, style: const TextStyle(color: Colors.white, fontSize: 15));
    }
  }

  Widget _buildImageMessage(Message m) {
    final url = m.attachment?.fileUrl ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (m.text.isNotEmpty)
          Text(m.text, style: const TextStyle(color: Colors.white, fontSize: 15)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: 200,
            height: 150,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                width: 200,
                height: 150,
                color: Colors.white.withOpacity(0.1),
                child: const Center(child: CircularProgressIndicator(color: Colors.white)),
              );
            },
            errorBuilder: (context, error, stack) {
              return Container(
                width: 200,
                height: 150,
                color: Colors.white.withOpacity(0.1),
                child: const Icon(Icons.error, color: Colors.white),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: () => _openUrl(url),
              icon: const Icon(Icons.open_in_new, color: Colors.white70, size: 18),
              label: const Text('فتح', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFileMessage(Message m) {
    final fileName = m.attachment?.fileName ?? 'ملف';
    final fileSize = m.attachment?.fileSize;
    final sizeText = fileSize != null ? _formatFileSize(fileSize) : '';
    final url = m.attachment?.fileUrl ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (m.text.isNotEmpty)
          Text(m.text, style: const TextStyle(color: Colors.white, fontSize: 15)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.attach_file, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fileName, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    if (sizeText.isNotEmpty)
                      Text(sizeText, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                onPressed: () => _downloadAndOpen(url, suggestedFileName: fileName),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceMessage(Message m) {
    final url = m.attachment?.fileUrl ?? '';
    final duration = m.attachment?.duration ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (m.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(m.text, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ),
        _VoiceBubble(url: url, initialDurationSec: duration),
      ],
    );
  }

  Widget _buildVideoMessage(Message m) {
    final url = m.attachment?.fileUrl ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (m.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(m.text, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ),
        _VideoBubble(url: url),
      ],
    );
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnack('تعذر فتح الرابط');
    }
  }

  Future<void> _downloadAndOpen(String url, {String? suggestedFileName}) async {
    if (url.isEmpty) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = suggestedFileName?.trim().isNotEmpty == true
          ? suggestedFileName!
          : Uri.parse(url).pathSegments.isNotEmpty
              ? Uri.parse(url).pathSegments.last
              : 'file_${DateTime.now().millisecondsSinceEpoch}';
      final savePath = '${dir.path}/$fileName';
      final f = File(savePath);
      if (!await f.exists()) {
        _showSnack('جارٍ التنزيل...');
        final dio = Dio();
        await dio.download(url, savePath);
        _showSnack('تم التنزيل: $fileName');
      }
      await OpenFile.open(savePath);
    } catch (e) {
      _showSnack('فشل التنزيل: $e');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }


  String _formatTime(String iso) {
    try {
      final dt = DateTime.tryParse(iso)?.toLocal() ?? DateTime.now();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return '';
    }
  }

  Future<void> _upsertChatNotificationFor(String targetPhone, Message msg) async {
    try {
      final data = await NotificationsApi.fetch(targetPhone);
      final items = List<NotificationItem>.from(data.items);
      final id = 'chat-${msg.id}';
      final exists = items.any((e) => e.id == id);
      if (!exists) {
        final item = NotificationItem(
          id: id,
          type: 'chat',
          title: 'رسالة جديدة',
          body: msg.text,
          createdAt: msg.timestamp,
          route: '/chat_admin',
          args: {'phone': _myPhone},
        );
        items.insert(0, item);
        await NotificationsApi.save(targetPhone, items, sha: data.sha);
      }
    } catch (_) {
      // ignore notification errors
    }
  }

  Widget _composer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.12)),
      child: Column(
        children: [
          // Media options panel
          if (_showMediaOptions) _buildMediaOptions(),
          // Main input row
          Row(
            children: [
              // Media button
              IconButton(
                onPressed: () {
                  setState(() {
                    _showMediaOptions = !_showMediaOptions;
                  });
                },
                icon: Icon(
                  _showMediaOptions ? Icons.close : Icons.add,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
              // Text input
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(color: Colors.white),
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Voice/Send button
              _buildSendButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaOptions() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMediaOption(
            icon: Icons.photo_library,
            label: 'معرض الصور',
            onTap: _pickImage,
          ),
          _buildMediaOption(
            icon: Icons.video_library,
            label: 'فيديو',
            onTap: _pickVideo,
          ),
          if (!kIsWeb)
            _buildMediaOption(
              icon: Icons.camera_alt,
              label: 'كاميرا',
              onTap: _takePicture,
            ),
          _buildMediaOption(
            icon: Icons.attach_file,
            label: 'ملف',
            onTap: _pickFile,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6F61).withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    if (_isRecording && !kIsWeb) {
      return ElevatedButton(
        onPressed: _stopRecording,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          children: [
            const Icon(Icons.stop, size: 20),
            const SizedBox(width: 8),
            Text(_formatElapsed(_recordingElapsed), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.mic, color: Colors.white),
          onPressed: _startRecording,
        ),
        ElevatedButton(
          onPressed: _sending ? null : _send,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6F61),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _sending
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send, size: 20),
        ),
      ],
    );
  }

  String _formatElapsed(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        if (kIsWeb) {
          // على الويب نعامل الفيديو كملف عام
          await _sendWebMediaMessage(video, MessageType.video);
        } else {
          await _sendMediaMessage(video.path, MessageType.video);
        }
      }
    } catch (e) {
      _showSnack('فشل في اختيار الفيديو: $e');
    }
  }

}

class _VideoBubble extends StatefulWidget {
  final String url;
  const _VideoBubble({required this.url});

  @override
  State<_VideoBubble> createState() => _VideoBubbleState();
}

class _VideoBubbleState extends State<_VideoBubble> {
  VideoPlayerController? _controller;
  bool _init = false;

  @override
  void initState() {
    super.initState();
    if (widget.url.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..setLooping(false)
        ..initialize().then((_) {
          if (mounted) setState(() => _init = true);
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_init) {
      return Container(
        width: 220,
        height: 140,
        color: Colors.white.withOpacity(0.1),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    final aspect = _controller!.value.aspectRatio == 0 ? 16 / 9 : _controller!.value.aspectRatio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: aspect,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller!),
                if (!_controller!.value.isPlaying)
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
                    onPressed: () => setState(() => _controller!.play()),
                  )
                else
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.pause_circle_filled, color: Colors.white70, size: 32),
                      onPressed: () => setState(() => _controller!.pause()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatElapsed(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _VoiceBubble extends StatefulWidget {
  final String url;
  final int initialDurationSec;
  const _VoiceBubble({required this.url, this.initialDurationSec = 0});

  @override
  State<_VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<_VoiceBubble> {
  final AudioPlayer _player = AudioPlayer();
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setUrl(widget.url);
      _dur = _player.duration ?? Duration(seconds: widget.initialDurationSec);
      _loading = false;
      setState(() {});
      _player.positionStream.listen((p) {
        if (!mounted) return;
        setState(() => _pos = p);
      });
    } catch (_) {
      _loading = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: const SizedBox(width: 180, height: 24, child: LinearProgressIndicator()),
      );
    }
    final progress = _dur.inMilliseconds == 0 ? 0.0 : (_pos.inMilliseconds / _dur.inMilliseconds).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
            child: IconButton(
              icon: Icon(_player.playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 24),
              onPressed: () async {
                if (_player.playing) {
                  await _player.pause();
                } else {
                  await _player.play();
                }
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: progress),
                  ),
                ),
                const SizedBox(height: 6),
                _AnimatedWaves(progress: progress),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(_fmt(_pos) + '/' + _fmt(_dur), style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _AnimatedWaves extends StatelessWidget {
  final double progress;
  const _AnimatedWaves({required this.progress});

  @override
  Widget build(BuildContext context) {
    final t = DateTime.now().millisecondsSinceEpoch / 300.0;
    double h(int i) => 8 + 12 * (0.5 + 0.5 * (math.sin(t + i)));
    return SizedBox(
      height: 20,
      child: Row(
        children: List.generate(8, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 3,
              height: h(i),
              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(2)),
            ),
          );
        }),
      ),
    );
  }
}
