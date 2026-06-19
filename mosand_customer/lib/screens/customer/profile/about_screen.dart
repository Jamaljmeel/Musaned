import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('عن التطبيق'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // App Logo - Professional Circular Design
            Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: Image.asset(
                    'assets/images/loge.png',
                    fit: BoxFit.cover, // This makes the image fill the circle
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.storefront_rounded,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'منصة مُساند',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Text(
              'الإصدار 1.0.0',
              style: TextStyle(fontSize: 14, color: AppColors.textHint),
            ),
            const SizedBox(height: 40),

            // Description Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Text(
                      'مُساند هي منصة وطنية متكاملة تهدف إلى دعم الأسر المنتجة وتمكينها من عرض وبيع منتجاتها المميزة للعملاء بكل سهولة وأمان.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 20),
                    Text(
                      'رؤيتنا',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'أن نكون الخيار الأول والآمن لدعم الاقتصاد المنزلي وتحويل الأسر المنتجة إلى مشاريع تجارية ناجحة ومستدامة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Features List
            _buildInfoTile(
              Icons.verified_user_rounded,
              'موثوقية كاملة',
              'جميع الأسر المسجلة لدينا موثقة ومعتمدة.',
            ),
            _buildInfoTile(
              Icons.support_agent_rounded,
              'دعم فني متواصل',
              'فريقنا متاح دائماً لمساعدتك في أي وقت.',
            ),
            _buildInfoTile(
              Icons.local_shipping_rounded,
              'توصيل سريع وآمن',
              'نحرص على وصول منتجاتكم بأفضل حال.',
            ),

            const SizedBox(height: 50),
            const Text(
              'صنع بكل حب لدعم الأسر المنتجة ❤️',
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
