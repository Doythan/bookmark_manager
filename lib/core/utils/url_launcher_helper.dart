import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';

class UrlLauncherHelper {
  // URL 열기
  static Future<void> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // 외부 브라우저에서 열기
        );
      } else {
        Fluttertoast.showToast(
          msg: 'URL을 열 수 없습니다: $url',
          backgroundColor: AppColors.error,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'URL 열기 실패: $e',
        backgroundColor: AppColors.error,
      );
    }
  }

  // 웹에서 새 탭으로 열기
  static Future<void> openUrlInNewTab(String url) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault, // 플랫폼 기본 방식
        );
      } else {
        Fluttertoast.showToast(
          msg: 'URL을 열 수 없습니다: $url',
          backgroundColor: AppColors.error,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'URL 열기 실패: $e',
        backgroundColor: AppColors.error,
      );
    }
  }

  // 인앱 브라우저로 열기 (선택사항)
  static Future<void> openUrlInApp(String url) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView, // 앱 내 웹뷰
        );
      } else {
        Fluttertoast.showToast(
          msg: 'URL을 열 수 없습니다: $url',
          backgroundColor: AppColors.error,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'URL 열기 실패: $e',
        backgroundColor: AppColors.error,
      );
    }
  }

  // URL 유효성 검사
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
