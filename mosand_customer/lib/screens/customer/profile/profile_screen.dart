import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/auth_provider.dart';

import '../favorites_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Professional Header with Gradient
          SliverToBoxAdapter(
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -50,
                    right: -50,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              backgroundImage:
                                  user?.avatarUrl != null &&
                                      user!.avatarUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(user.avatarUrl)
                                  : null,
                              child:
                                  user?.avatarUrl == null ||
                                      user!.avatarUrl.isEmpty
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.displayName ?? 'اسم المستخدم',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionTitle('الإعدادات العامة'),
                _menuCard(
                  icon: Icons.person_outline_rounded,
                  title: 'تعديل الملف الشخصي',
                  subtitle: 'تغيير الاسم، رقم الهاتف، وصورة الحساب',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                ),
                _menuCard(
                  icon: Icons.lock_outline_rounded,
                  title: 'تغيير كلمة المرور',
                  subtitle: 'تحديث كلمة المرور الخاصة بك',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  ),
                ),

                // _menuCard(
                //   icon: Icons.favorite_border_rounded,
                //   title: 'المفضلة',
                //   subtitle: 'منتجاتك التي قمت بحفظها',
                //   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
                // ),
                const SizedBox(height: 20),
                _sectionTitle('الدعم والمساعدة'),
                _menuCard(
                  icon: Icons.help_outline_rounded,
                  title: 'المساعدة والدعم',
                  subtitle: 'تواصل معنا أو اقرأ الأسئلة الشائعة',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HelpSupportScreen(),
                    ),
                  ),
                ),
                _menuCard(
                  icon: Icons.info_outline_rounded,
                  title: 'عن التطبيق',
                  subtitle: 'معلومات عن منصة مُساند',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                ),

                const SizedBox(height: 40),
                CustomButton(
                  text: 'تسجيل الخروج',
                  color: AppColors.error,
                  icon: Icons.logout_rounded,
                  onPressed: () async {
                    final confirm = await Helpers.showConfirmDialog(
                      context,
                      title: 'تسجيل الخروج',
                      message: 'هل أنت متأكد من تسجيل الخروج؟',
                      confirmColor: AppColors.error,
                    );
                    if (confirm && context.mounted) {
                      await context.read<AuthProvider>().signOut();
                    }
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppColors.textHint,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
