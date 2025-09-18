import 'package:flutter/material.dart';

/// صفحة اختيار العلاقة 💞
class SelectRelationshipPage extends StatefulWidget {
  final String occasionType;

  const SelectRelationshipPage({
    super.key,
    required this.occasionType,
  });

  @override
  State<SelectRelationshipPage> createState() => _SelectRelationshipPageState();
}

class _SelectRelationshipPageState extends State<SelectRelationshipPage> {
  String? selectedRelationship;

  final List<Map<String, String>> relationships = [
    {"icon": "❤️", "name": "حبيبي / حبيبتي"},
    {"icon": "👨‍👧", "name": "أخويا / أختي"},
    {"icon": "👨‍👩‍👧", "name": "أبويا / أمي"},
    {"icon": "💍", "name": "زوجي / زوجتي"},
    {"icon": "🤝", "name": "صديقي / صديقتي"},
    {"icon": "🏠", "name": "جاري / جارتي"},
    {"icon": "💑", "name": "خطيبي / خطيبتي"},
    {"icon": "⭐", "name": "شخص غالي عليا"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '💞 اختيار العلاقة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6C63FF).withOpacity(0.1),
              const Color(0xFFF8F9FA),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // عنوان الصفحة
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '💞',
                      style: TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اختر نوع العلاقة',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'المناسبة: ${widget.occasionType}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // شبكة العلاقات
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: relationships.length,
                  itemBuilder: (context, index) {
                    final relation = relationships[index];
                    final isSelected = selectedRelationship == relation["name"];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRelationship = relation["name"];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF6C63FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF6C63FF)
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected 
                                  ? const Color(0xFF6C63FF).withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.1),
                              blurRadius: isSelected ? 12 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              relation["icon"]!,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                relation["name"]!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected 
                                      ? Colors.white
                                      : const Color(0xFF2D3748),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // أزرار التنقل
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('السابق'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: selectedRelationship != null ? _navigateNext : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('التالي'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateNext() {
    if (selectedRelationship == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار العلاقة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // التنقل لصفحة معلومات التطبيق
    Navigator.pushNamed(
      context,
      '/app-info',
      arguments: {
        'occasionType': widget.occasionType,
        'recipientRelation': selectedRelationship!,
      },
    );
  }
}
