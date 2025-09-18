import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class PreviewGiftPage extends StatefulWidget {
  final String appName;
  final File? appIcon;
  final String occasionType;
  final String recipientRelation;
  final String messageText;
  final List<File> images;
  final String imagesText;
  final File? musicFile;
  final String musicText;
  final File? videoFile;
  final String videoText;
  final String selectedColor;

  const PreviewGiftPage({
    super.key,
    required this.appName,
    required this.appIcon,
    required this.occasionType,
    required this.recipientRelation,
    required this.messageText,
    required this.images,
    required this.imagesText,
    required this.musicFile,
    required this.musicText,
    required this.videoFile,
    required this.videoText,
    required this.selectedColor,
  });

  @override
  State<PreviewGiftPage> createState() => _PreviewGiftPageState();
}

class _PreviewGiftPageState extends State<PreviewGiftPage> {
  bool uploading = false;

  Future<void> uploadToGitHub() async {
    setState(() => uploading = true);

    final token = "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";
    final repo = "app_upload";
    final owner = "Mahmoud-Gharib";
    final branch = "main";

    final apiBase = "https://api.github.com";

    Future<String> createBlob(File file) async {
      final bytes = await file.readAsBytes();
      final res = await http.post(
        Uri.parse('$apiBase/repos/$owner/$repo/git/blobs'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/vnd.github+json",
        },
        body: jsonEncode({
          "content": base64Encode(bytes),
          "encoding": "base64",
        }),
      );
      return jsonDecode(res.body)['sha'];
    }

    Future<String> createTextBlob(String text) async {
      final res = await http.post(
        Uri.parse('$apiBase/repos/$owner/$repo/git/blobs'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/vnd.github+json",
        },
        body: jsonEncode({
          "content": text,
          "encoding": "utf-8",
        }),
      );
      return jsonDecode(res.body)['sha'];
    }

    Future<String> getLatestCommitSha() async {
      final res = await http.get(
        Uri.parse('$apiBase/repos/$owner/$repo/git/ref/heads/$branch'),
        headers: {"Authorization": "Bearer $token"},
      );
      return jsonDecode(res.body)['object']['sha'];
    }

    Future<String> getTreeSha(String commitSha) async {
      final res = await http.get(
        Uri.parse('$apiBase/repos/$owner/$repo/git/commits/$commitSha'),
        headers: {"Authorization": "Bearer $token"},
      );
      return jsonDecode(res.body)['tree']['sha'];
    }

    Future<String> createTree(List<Map<String, dynamic>> treeItems, String baseTreeSha) async {
      final res = await http.post(
        Uri.parse('$apiBase/repos/$owner/$repo/git/trees'),
        headers: {"Authorization": "Bearer $token"},
        body: jsonEncode({
          "base_tree": baseTreeSha,
          "tree": treeItems,
        }),
      );
      return jsonDecode(res.body)['sha'];
    }

    Future<String> createCommit(String message, String treeSha, String parentSha) async {
      final res = await http.post(
        Uri.parse('$apiBase/repos/$owner/$repo/git/commits'),
        headers: {"Authorization": "Bearer $token"},
        body: jsonEncode({
          "message": message,
          "tree": treeSha,
          "parents": [parentSha],
        }),
      );
      return jsonDecode(res.body)['sha'];
    }

    Future<void> updateBranch(String newCommitSha) async {
      await http.patch(
        Uri.parse('$apiBase/repos/$owner/$repo/git/refs/heads/$branch'),
        headers: {"Authorization": "Bearer $token"},
        body: jsonEncode({"sha": newCommitSha}),
      );
    }

    try {
      final latestCommitSha = await getLatestCommitSha();
      final baseTreeSha = await getTreeSha(latestCommitSha);

      final treeItems = <Map<String, dynamic>>[];

      // Text blobs
      final textMap = {
        "assets/app/name.txt": widget.appName,
        "assets/app/occasion.txt": widget.occasionType,
        "assets/app/recipient.txt": widget.recipientRelation,
        "assets/message/message.txt": widget.messageText,
        "assets/images/text.txt": widget.imagesText,
        "assets/music/text.txt": widget.musicText,
        "assets/video/text.txt": widget.videoText,
      };

      for (final entry in textMap.entries) {
        final sha = await createTextBlob(entry.value);
        treeItems.add({
          "path": entry.key,
          "mode": "100644",
          "type": "blob",
          "sha": sha,
        });
      }

      // Files
      Future<void> addFile(File? file, String pathPrefix, String name) async {
        if (file == null) return;
        final sha = await createBlob(file);
        treeItems.add({
          "path": "$pathPrefix/$name${path.extension(file.path)}",
          "mode": "100644",
          "type": "blob",
          "sha": sha,
        });
      }

      await addFile(widget.appIcon, "assets/app", "icon");
      for (int i = 0; i < widget.images.length; i++) {
        await addFile(widget.images[i], "assets/images", "${i + 1}");
      }
      await addFile(widget.musicFile, "assets/music", "song");
      await addFile(widget.videoFile, "assets/video", "video");

      final newTreeSha = await createTree(treeItems, baseTreeSha);
      final commitSha = await createCommit("🎁 Upload all gift files", newTreeSha, latestCommitSha);
      await updateBranch(commitSha);

      setState(() => uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم رفع الهدية في commit واحد 🎉")),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      setState(() => uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ حدث خطأ في الرفع: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('معاينة الهدية', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF311B92), Color(0xFF8E24AA), Color(0xFFFF6F61)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF311B92), Color(0xFF8E24AA), Color(0xFFFF6F61)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      size: 50,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'معاينة هديتك الجميلة 🎁',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'مراجعة نهائية قبل رفع الهدية',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF8E24AA).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.app_registration, color: Color(0xFF8E24AA), size: 24),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اسم التطبيق',
                                style: TextStyle(
                                  color: Color(0xFF8E24AA),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.appName,
                                style: TextStyle(
                                  color: Color(0xFF311B92),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.appIcon != null) 
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(widget.appIcon!, height: 100, width: 100, fit: BoxFit.cover),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF6F61).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.celebration, color: Color(0xFFFF6F61), size: 24),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'نوع المناسبة',
                                style: TextStyle(
                                  color: Color(0xFFFF6F61),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.occasionType,
                                style: TextStyle(
                                  color: Color(0xFF311B92),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF8E24AA).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person, color: Color(0xFF8E24AA), size: 24),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الشخص المُهدى إليه',
                                style: TextStyle(
                                  color: Color(0xFF8E24AA),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.recipientRelation,
                                style: TextStyle(
                                  color: Color(0xFF311B92),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF311B92).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.message, color: Color(0xFF311B92), size: 24),
                        ),
                        SizedBox(width: 15),
                        Text(
                          'الرسالة الافتتاحية',
                          style: TextStyle(
                            color: Color(0xFF311B92),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color(0xFF311B92).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Color(0xFF8E24AA).withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.messageText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF311B92),
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(thickness: 2),

              const Text("🖼️ الصور", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              if (widget.images.isNotEmpty)
                Container(
                  height: 120,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            widget.images[index], 
                            width: 100, 
                            height: 100, 
                            fit: BoxFit.cover
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (widget.imagesText.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(widget.imagesText, style: TextStyle(fontSize: 14)),
                ),

              const Divider(thickness: 2),

              const Text("🎵 الأغنية", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(widget.musicFile?.path.split('/').last ?? 'لم يتم اختيار أغنية', 
                   style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              if (widget.musicText.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(widget.musicText, style: TextStyle(fontSize: 14)),
                ),

              const Divider(thickness: 2),

              const Text("🎬 الفيديو", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(widget.videoFile?.path.split('/').last ?? 'لم يتم اختيار فيديو',
                   style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              if (widget.videoText.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(widget.videoText, style: TextStyle(fontSize: 14)),
                ),

              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6F61), Color(0xFF8E24AA)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF6F61).withOpacity(0.4),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: uploading ? null : uploadToGitHub,
                  icon: uploading 
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.cloud_upload, color: Colors.white),
                  label: Text(
                    uploading ? "جاري الرفع..." : "رفع الهدية إلى GitHub 🚀",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
