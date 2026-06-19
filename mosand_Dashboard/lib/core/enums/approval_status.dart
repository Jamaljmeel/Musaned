import 'package:flutter/material.dart';
import '../../config/theme.dart';

enum ApprovalStatus {
  pending,
  approved,
  rejected;

  String get nameAr {
    switch (this) {
      case ApprovalStatus.pending:
        return 'قيد المراجعة';
      case ApprovalStatus.approved:
        return 'مقبول';
      case ApprovalStatus.rejected:
        return 'مرفوض';
    }
  }

  Color get color {
    switch (this) {
      case ApprovalStatus.pending:
        return AppColors.warning;
      case ApprovalStatus.approved:
        return AppColors.success;
      case ApprovalStatus.rejected:
        return AppColors.error;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ApprovalStatus.pending:
        return AppColors.warningLight;
      case ApprovalStatus.approved:
        return AppColors.successLight;
      case ApprovalStatus.rejected:
        return AppColors.errorLight;
    }
  }

  IconData get icon {
    switch (this) {
      case ApprovalStatus.pending:
        return Icons.hourglass_empty_rounded;
      case ApprovalStatus.approved:
        return Icons.verified_rounded;
      case ApprovalStatus.rejected:
        return Icons.block_rounded;
    }
  }

  static ApprovalStatus fromString(String value) {
    return ApprovalStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ApprovalStatus.pending,
    );
  }
}
