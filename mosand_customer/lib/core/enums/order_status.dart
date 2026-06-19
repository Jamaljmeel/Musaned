import 'package:flutter/material.dart';
import '../../config/theme.dart';

enum OrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  delivering,
  delivered,
  cancelled;

  String get nameAr {
    switch (this) {
      case OrderStatus.pending:
        return 'في الانتظار';
      case OrderStatus.accepted:
        return 'مقبول';
      case OrderStatus.preparing:
        return 'قيد التحضير';
      case OrderStatus.ready:
        return 'جاهز';
      case OrderStatus.delivering:
        return 'قيد التوصيل';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.pending;
      case OrderStatus.accepted:
        return AppColors.accepted;
      case OrderStatus.preparing:
        return AppColors.preparing;
      case OrderStatus.ready:
        return AppColors.ready;
      case OrderStatus.delivering:
        return AppColors.delivering;
      case OrderStatus.delivered:
        return AppColors.delivered;
      case OrderStatus.cancelled:
        return AppColors.cancelled;
    }
  }

  Color get backgroundColor {
    return color.withValues(alpha: 0.1);
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.schedule_rounded;
      case OrderStatus.accepted:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.preparing:
        return Icons.restaurant_rounded;
      case OrderStatus.ready:
        return Icons.inventory_2_rounded;
      case OrderStatus.delivering:
        return Icons.delivery_dining_rounded;
      case OrderStatus.delivered:
        return Icons.task_alt_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}
