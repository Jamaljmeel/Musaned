import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('المساعدة والدعم')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  'كيف يمكننا مساعدتك؟',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'فريقنا متاح دائماً للإجابة على استفساراتك',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 30),
                
                // Support Options
                _supportCard(
                  icon: Icons.chat_bubble_rounded,
                  title: 'تواصل عبر واتساب',
                  subtitle: 'رد فوري من خدمة العملاء',
                  color: const Color(0xFF25D366),
                  onTap: () {},
                ),
                _supportCard(
                  icon: Icons.email_rounded,
                  title: 'البريد الإلكتروني',
                  subtitle: 'support@musaned.com',
                  color: AppColors.info,
                  onTap: () {},
                ),
                _supportCard(
                  icon: Icons.phone_in_talk_rounded,
                  title: 'اتصال مباشر',
                  subtitle: '966 500 000 000',
                  color: AppColors.primary,
                  onTap: () {},
                ),
                
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'الأسئلة الشائعة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 16),
                
                // FAQ Items
                _faqItem('كيف يمكنني تتبع طلبي؟', 'يمكنك تتبع حالة طلبك بالتفصيل من خلال قسم "طلباتي" في القائمة السفلية، حيث ستجد التحديثات اللحظية من المتجر.'),
                _faqItem('ما هي طرق الدفع المتاحة؟', 'حالياً تدعم المنصة خدمة الدفع عند الاستلام لضمان ثقة العملاء، وسنقوم بإضافة الدفع الإلكتروني قريباً.'),
                _faqItem('هل يمكنني إلغاء الطلب؟', 'نعم، يمكنك إلغاء الطلب ما لم يتم قبوله من قبل المتجر. بعد القبول، يجب التواصل مع المتجر مباشرة.'),
                
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _supportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint),
        onTap: onTap,
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        shape: const Border(),
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              answer,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
