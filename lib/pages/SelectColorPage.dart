import 'package:flutter/material.dart';
import 'AppInfoPage.dart';

class SelectColorPage extends StatefulWidget {
  final String occasionType;
  final String recipientRelation;

  SelectColorPage({
    required this.occasionType,
    required this.recipientRelation,
  });

  @override
  _SelectColorPageState createState() => _SelectColorPageState();
}

class _SelectColorPageState extends State<SelectColorPage> with SingleTickerProviderStateMixin {
  String? selectedColor;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> colors = [
    {
      "name": "أحمر رومانسي",
      "color": Color(0xFFE91E63),
      "gradient": [Color(0xFFE91E63), Color(0xFFAD1457)],
      "icon": "💖",
      "description": "للحب والرومانسية"
    },
    {
      "name": "أزرق هادئ",
      "color": Color(0xFF2196F3),
      "gradient": [Color(0xFF2196F3), Color(0xFF1565C0)],
      "icon": "💙",
      "description": "للهدوء والثقة"
    },
    {
      "name": "بنفسجي ملكي",
      "color": Color(0xFF9C27B0),
      "gradient": [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
      "icon": "💜",
      "description": "للأناقة والفخامة"
    },
    {
      "name": "أخضر طبيعي",
      "color": Color(0xFF4CAF50),
      "gradient": [Color(0xFF4CAF50), Color(0xFF2E7D32)],
      "icon": "💚",
      "description": "للطبيعة والنمو"
    },
    {
      "name": "برتقالي مشرق",
      "color": Color(0xFFFF9800),
      "gradient": [Color(0xFFFF9800), Color(0xFFE65100)],
      "icon": "🧡",
      "description": "للطاقة والحيوية"
    },
    {
      "name": "ذهبي فاخر",
      "color": Color(0xFFFFD700),
      "gradient": [Color(0xFFFFD700), Color(0xFFB8860B)],
      "icon": "💛",
      "description": "للترف والتميز"
    },
    {
      "name": "وردي ناعم",
      "color": Color(0xFFFFB6C1),
      "gradient": [Color(0xFFFFB6C1), Color(0xFFFF69B4)],
      "icon": "🌸",
      "description": "للرقة والأنوثة"
    },
    {
      "name": "تركوازي مميز",
      "color": Color(0xFF00BCD4),
      "gradient": [Color(0xFF00BCD4), Color(0xFF0097A7)],
      "icon": "🩵",
      "description": "للإبداع والتجديد"
    },
    {
      "name": "بني دافئ",
      "color": Color(0xFF8D6E63),
      "gradient": [Color(0xFF8D6E63), Color(0xFF5D4037)],
      "icon": "🤎",
      "description": "للدفء والأمان"
    },
    {
      "name": "رمادي أنيق",
      "color": Color(0xFF607D8B),
      "gradient": [Color(0xFF607D8B), Color(0xFF37474F)],
      "icon": "🩶",
      "description": "للكلاسيكية والأناقة"
    },
    {
      "name": "أسود راقي",
      "color": Color(0xFF424242),
      "gradient": [Color(0xFF424242), Color(0xFF212121)],
      "icon": "🖤",
      "description": "للرقي والغموض"
    },
    {
      "name": "قوس قزح",
      "color": Color(0xFFE91E63),
      "gradient": [
        Color(0xFFE91E63),
        Color(0xFF9C27B0),
        Color(0xFF2196F3),
        Color(0xFF4CAF50),
        Color(0xFFFFD700)
      ],
      "icon": "🌈",
      "description": "لكل الألوان معاً"
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectColor(String colorName) {
    setState(() {
      selectedColor = colorName;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اختيار اللون العام',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF311B92), Color(0xFF8E24AA), Color(0xFFFF6F61)],
          ),
        ),
        child: Column(
          children: [
            // Header Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.palette,
                    size: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'اختر اللون العام للهدية 🎨',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اختر اللون الذي يعبر عن مشاعرك ويناسب المناسبة',
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
            
            // Colors Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final colorData = colors[index];
                  final isSelected = selectedColor == colorData["name"];
                  final isRainbow = colorData["name"] == "قوس قزح";
                  
                  return GestureDetector(
                    onTap: () => _selectColor(colorData["name"]),
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isSelected ? _scaleAnimation.value : 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: isRainbow
                                  ? LinearGradient(
                                      colors: colorData["gradient"],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : LinearGradient(
                                      colors: colorData["gradient"],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected 
                                      ? colorData["color"].withOpacity(0.4)
                                      : Colors.black.withOpacity(0.1),
                                  blurRadius: isSelected ? 15 : 8,
                                  offset: Offset(0, isSelected ? 8 : 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Selection indicator
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: colorData["color"],
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                
                                // Content
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        colorData["icon"],
                                        style: TextStyle(fontSize: 32),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        colorData["name"],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        colorData["description"],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: 20),
            
            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[600]!, Colors.grey[500]!],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    label: Text(
                      'رجوع',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                
                // Next Button
                Container(
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
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedColor == null || selectedColor!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('يرجى اختيار لون للهدية'),
                            backgroundColor: Color(0xFF8E24AA),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AppInfoPage(
                              occasionType: widget.occasionType,
                              recipientRelation: widget.recipientRelation,
                              selectedColor: selectedColor!,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'التالي',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
