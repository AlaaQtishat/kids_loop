import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class DateHelper {
  static String getTimeAgo(dynamic createdAtData) {
    if (createdAtData == null) return "date_helper.just_now".tr();

    DateTime? postDate;

    if (createdAtData is Timestamp) {
      postDate = createdAtData.toDate();
    } else if (createdAtData is String) {
      postDate = DateTime.tryParse(createdAtData);
    }

    if (postDate == null) return "date_helper.just_now".tr();

    final diff = DateTime.now().difference(postDate);

    if (diff.inDays > 0) {
      return "date_helper.posted_days_ago".tr(
        namedArgs: {'days': diff.inDays.toString()},
      );
    }

    if (diff.inHours > 0) {
      return "date_helper.posted_hours_ago".tr(
        namedArgs: {'hours': diff.inHours.toString()},
      );
    }

    if (diff.inMinutes > 0) {
      return "date_helper.posted_minutes_ago".tr(
        namedArgs: {'minutes': diff.inMinutes.toString()},
      );
    }

    return "date_helper.just_now".tr();
  }
}
