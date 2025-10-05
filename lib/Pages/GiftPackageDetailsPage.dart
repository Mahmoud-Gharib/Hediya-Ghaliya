import 'package:flutter/material.dart';
import 'package:hediya_ghaliya/Models/GiftPackage.dart';

class GiftPackageDetailsPage extends StatefulWidget {
  static const routeName = '/gift-package-details';
  const GiftPackageDetailsPage({super.key});

  @override
  State<GiftPackageDetailsPage> createState() => _GiftPackageDetailsPageState();
}

class _GiftPackageDetailsPageState extends State<GiftPackageDetailsPage>
    with TickerProviderStateMixin {
  GiftPackage? package;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['package'] is GiftPackage) {
      package = args['package'] as GiftPackage;
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (package == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(package!.nameAr, style: const TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(int.parse(package!.color)).withOpacity(0.8),
                  Color(int.parse(package!.color)),
                  const Color(0xFFFF6F61),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(int.parse(package!.color)).withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPackageHeader(),
                    const SizedBox(height: 24),
                    _buildFeaturesSection(),
                    const SizedBox(height: 24),
                    _buildLimitationsSection(),
                    const SizedBox(height: 24),
                    _buildValiditySection(),
                    const SizedBox(height: 24),
                    _buildComparisonSection(),
                    const SizedBox(height: 32),
                    _buildStartButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(int.parse(package!.color)).withOpacity(0.1),
            Color(int.parse(package!.color)).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(int.parse(package!.color)).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(int.parse(package!.color)).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              package!.icon,
              style: const TextStyle(fontSize: 48),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            package!.nameAr,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(int.parse(package!.color)),
            ),
          ),
          const SizedBox(height: 8),
          if (package!.price > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(int.parse(package!.color)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${package!.price.toInt()} ${package!.currency}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'مجاناً',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return _buildSection(
      title: 'المميزات المتاحة',
      icon: Icons.star,
      children: package!.featuresAr.map((feature) => _buildFeatureItem(feature, true)).toList(),
    );
  }

  Widget _buildLimitationsSection() {
    List<String> limitations = [];
    
    if (package!.maxMediaFiles > 0) {
      limitations.add('حد أقصى ${package!.maxMediaFiles} ملف وسائط');
    }
    if (package!.maxTextLength > 0) {
      limitations.add('حد أقصى ${package!.maxTextLength} حرف للرسالة');
    }
    if (!package!.hasCustomThemes) {
      limitations.add('قوالب محدودة');
    }
    if (!package!.hasAnimations) {
      limitations.add('بدون تأثيرات متحركة');
    }
    if (!package!.hasMusic) {
      limitations.add('بدون موسيقى خلفية');
    }
    if (!package!.hasVoiceRecording) {
      limitations.add('بدون تسجيل صوتي');
    }
    if (!package!.hasVideoRecording) {
      limitations.add('بدون تسجيل مرئي');
    }
    if (!package!.hasScheduledDelivery) {
      limitations.add('بدون جدولة الإرسال');
    }
    if (!package!.hasReadReceipts) {
      limitations.add('بدون إشعارات القراءة');
    }

    if (limitations.isEmpty) {
      limitations.add('لا توجد قيود - استمتع بجميع المميزات!');
    }

    return _buildSection(
      title: 'القيود والحدود',
      icon: Icons.info_outline,
      children: limitations.map((limitation) => _buildFeatureItem(limitation, false)).toList(),
    );
  }

  Widget _buildValiditySection() {
    return _buildSection(
      title: 'مدة الصلاحية',
      icon: Icons.schedule,
      children: [
        _buildFeatureItem(
          'صالحة لمدة ${package!.validityDays} ${package!.validityDays == 1 ? 'يوم' : package!.validityDays <= 10 ? 'أيام' : 'يوماً'}',
          true,
        ),
        _buildFeatureItem(
          package!.validityDays >= 365 
              ? 'صالحة لسنة كاملة - وقت كافي لجميع المناسبات'
              : package!.validityDays >= 60
                  ? 'مدة ممتازة للمناسبات المهمة'
                  : package!.validityDays >= 30
                      ? 'مدة جيدة للرسائل الشخصية'
                      : 'مدة قصيرة للتجربة السريعة',
          true,
        ),
      ],
    );
  }

  Widget _buildComparisonSection() {
    final allPackages = GiftPackage.availablePackages;
    final currentIndex = allPackages.indexWhere((p) => p.type == package!.type);
    
    List<Widget> comparisons = [];
    
    if (currentIndex > 0) {
      final previousPackage = allPackages[currentIndex - 1];
      comparisons.add(_buildComparisonItem(
        'ترقية من ${previousPackage.nameAr}',
        'مميزات إضافية وحدود أعلى',
        Icons.upgrade,
        Colors.green,
      ));
    }
    
    if (currentIndex < allPackages.length - 1) {
      final nextPackage = allPackages[currentIndex + 1];
      comparisons.add(_buildComparisonItem(
        'ترقية إلى ${nextPackage.nameAr}',
        'مميزات أكثر وحرية أكبر',
        Icons.arrow_upward,
        Colors.blue,
      ));
    }

    if (comparisons.isEmpty) {
      if (package!.type == GiftPackageType.free) {
        comparisons.add(_buildComparisonItem(
          'الباقة الأساسية',
          'نقطة البداية المثالية للتجربة',
          Icons.start,
          Colors.green,
        ));
      } else {
        comparisons.add(_buildComparisonItem(
          'الباقة الأفضل',
          'أعلى مستوى من المميزات والحرية',
          Icons.diamond,
          Colors.amber,
        ));
      }
    }

    return _buildSection(
      title: 'مقارنة الباقات',
      icon: Icons.compare_arrows,
      children: comparisons,
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(int.parse(package!.color)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Color(int.parse(package!.color)),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(int.parse(package!.color)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.check : Icons.info,
              color: isPositive ? Colors.green : Colors.orange,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(int.parse(package!.color)),
            Color(int.parse(package!.color)).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(int.parse(package!.color)).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          switch (package!.type) {
            case GiftPackageType.free:
              Navigator.pushNamed(context, '/free-gift-templates');
              break;
            case GiftPackageType.bronze:
              Navigator.pushNamed(context, '/bronze-gift-templates');
              break;
            case GiftPackageType.silver:
              Navigator.pushNamed(context, '/silver-gift-templates');
              break;
            case GiftPackageType.gold:
              Navigator.pushNamed(context, '/gold-gift-templates');
              break;
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.rocket_launch,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'ابدأ الآن',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
