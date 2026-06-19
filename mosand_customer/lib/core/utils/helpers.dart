import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';

class Helpers {
  static String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'ar_SA',
      symbol: 'ر.س',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  static String formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy/MM/dd HH:mm').format(date);
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء النور';
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static String generateOrderNumber() {
    return DateTime.now().millisecondsSinceEpoch.toString().substring(7);
  }

  static Color getOrderStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'prepared': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  static String getOrderStatusArabic(String status) {
    switch (status) {
      case 'pending': return 'قيد الانتظار';
      case 'accepted': return 'تم القبول';
      case 'prepared': return 'جاري التجهيز';
      case 'delivered': return 'تم التوصيل';
      case 'cancelled': return 'ملغي';
      default: return 'غير معروف';
    }
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    Color? confirmColor,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title, textAlign: TextAlign.right),
            content: Text(message, textAlign: TextAlign.right),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(title, style: TextStyle(color: confirmColor ?? AppColors.primary)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
