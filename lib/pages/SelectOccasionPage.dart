import 'package:flutter/material.dart';
import 'SelectRelationshipPage.dart';

class SelectOccasionPage extends StatefulWidget {
  @override
  _SelectOccasionPageState createState() => _SelectOccasionPageState();
}

class _SelectOccasionPageState extends State<SelectOccasionPage> {
  String? selectedOccasion;
  TextEditingController otherController = TextEditingController();

  final List<Map<String, String>> occasions = [
    {"icon": "🎂", "name": "عيد ميلاد"},
    {"icon": "🎓", "name": "تخرج"},
    {"icon": "💖", "name": "عيد الحب"},
    {"icon": "🕌", "name": "عيد الأضحى"},
    {"icon": "🌙", "name": "عيد الفطر"},
    {"icon": "🌙", "name": "رمضان"},
    {"icon": "🕌", "name": "المولد النبوي"},
    {"icon": "👩‍👧‍👦", "name": "عيد الأم"},
    {"icon": "🕋", "name": "حج"},
    {"icon": "🕋", "name": "عمرة"},
    {"icon": "💍", "name": "زواج"},
    {"icon": "💑", "name": "خطوبة"},
    {"icon": "🎄", "name": "رأس السنة"},
    {"icon": "💪", "name": "دعم نفسي"},
    {"icon": "🏆", "name": "تشجيع"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختيار المناسبة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                    Icons.celebration,
                    size: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'اختر المناسبة 🎉',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اختر المناسبة المناسبة لهديتك الخاصة',
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
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  ...occasions.map((occasion) {
                    bool isSelected = selectedOccasion == occasion["name"];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedOccasion = occasion["name"];
                          otherController.clear();
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xFFFF6F61).withOpacity(0.2) : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected ? Color(0xFFFF6F61) : Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                occasion["icon"]!,
                                style: TextStyle(fontSize: 30),
                              ),
                              SizedBox(height: 8),
                              Text(
                                occasion["name"]!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Color(0xFF311B92) : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOccasion = '';
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selectedOccasion == '' ? Color(0xFFFF6F61).withOpacity(0.2) : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: selectedOccasion == '' ? Color(0xFFFF6F61) : Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, color: Colors.blue, size: 30),
                          SizedBox(height: 10),
                          Text(
                            'أخرى',
                            style: TextStyle(
                              fontSize: 15,
                              color: selectedOccasion == '' ? Colors.white : Colors.blue[800],
                            ),
                          ),
                          if (selectedOccasion == '') ...[
                            SizedBox(height: 10),
                            TextField(
                              controller: otherController,
                              decoration: InputDecoration(
                                hintText: 'اكتب المناسبة',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                    label: Text('رجوع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      String finalOccasion = selectedOccasion == '' ? otherController.text.trim() : selectedOccasion ?? '';

                      if (finalOccasion.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('يرجى اختيار المناسبة'),
                            backgroundColor: Color(0xFF8E24AA),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SelectRelationshipPage(
                              occasionType: finalOccasion,
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
