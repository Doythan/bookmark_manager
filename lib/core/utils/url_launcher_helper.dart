import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';

// URL 타입 enum
enum UrlType { youtube, instagram, twitter, facebook, tiktok, general }

class UrlLauncherHelper {
  // ==================== URL 타입 감지 ====================

  static UrlType detectUrlType(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();

      if (host.contains('youtube.com') || host.contains('youtu.be')) {
        return UrlType.youtube;
      } else if (host.contains('instagram.com')) {
        return UrlType.instagram;
      } else if (host.contains('twitter.com') || host.contains('x.com')) {
        return UrlType.twitter;
      } else if (host.contains('facebook.com') || host.contains('fb.com')) {
        return UrlType.facebook;
      } else if (host.contains('tiktok.com')) {
        return UrlType.tiktok;
      }

      return UrlType.general;
    } catch (e) {
      return UrlType.general;
    }
  }

  /// 웹 버전 URL로 변환 (앱 우회용)
  static String convertToWebVersion(String url, UrlType type) {
    try {
      final uri = Uri.parse(url);

      switch (type) {
        case UrlType.youtube:
          // youtube.com → m.youtube.com
          if (uri.host.contains('youtube.com')) {
            return url.replaceFirst('youtube.com', 'm.youtube.com');
          } else if (uri.host.contains('youtu.be')) {
            // youtu.be/abc → m.youtube.com/watch?v=abc
            final videoId = uri.pathSegments.isNotEmpty
                ? uri.pathSegments[0]
                : '';
            return 'https://m.youtube.com/watch?v=$videoId';
          }
          break;

        case UrlType.instagram:
          // instagram.com은 자동 전환 안 됨 (대부분)
          return url;

        case UrlType.twitter:
          // twitter.com → mobile.twitter.com
          if (uri.host.contains('twitter.com')) {
            return url.replaceFirst('twitter.com', 'mobile.twitter.com');
          } else if (uri.host.contains('x.com')) {
            return url.replaceFirst('x.com', 'mobile.x.com');
          }
          break;

        case UrlType.facebook:
          // facebook.com → m.facebook.com
          if (uri.host.contains('facebook.com')) {
            return url.replaceFirst('facebook.com', 'm.facebook.com');
          }
          break;

        case UrlType.tiktok:
          // tiktok.com → m.tiktok.com
          if (uri.host.contains('tiktok.com')) {
            return url.replaceFirst('tiktok.com', 'm.tiktok.com');
          }
          break;

        case UrlType.general:
          return url;
      }

      return url;
    } catch (e) {
      return url;
    }
  }

  // ==================== URL 타입별 정보 ====================

  static String getAppName(UrlType type) {
    switch (type) {
      case UrlType.youtube:
        return 'YouTube';
      case UrlType.instagram:
        return 'Instagram';
      case UrlType.twitter:
        return 'X';
      case UrlType.facebook:
        return 'Facebook';
      case UrlType.tiktok:
        return 'TikTok';
      case UrlType.general:
        return '브라우저';
    }
  }

  static IconData getIcon(UrlType type) {
    switch (type) {
      case UrlType.youtube:
        return Icons.play_circle_outline;
      case UrlType.instagram:
        return Icons.camera_alt_outlined;
      case UrlType.twitter:
        return Icons.alternate_email;
      case UrlType.facebook:
        return Icons.facebook;
      case UrlType.tiktok:
        return Icons.music_note;
      case UrlType.general:
        return Icons.language;
    }
  }

  static Color? getColor(UrlType type) {
    switch (type) {
      case UrlType.youtube:
        return Colors.red[700];
      case UrlType.instagram:
        return Colors.purple[400];
      case UrlType.twitter:
        return Colors.blue[400];
      case UrlType.facebook:
        return Colors.blue[800];
      case UrlType.tiktok:
        return Colors.black;
      case UrlType.general:
        return null;
    }
  }

  // ==================== 메인 URL 열기 함수 ====================

  /// URL을 열기 (SNS는 선택 다이얼로그, 일반 웹은 바로 실행)
  static Future<void> openUrl(String url, BuildContext context) async {
    final urlType = detectUrlType(url);

    // 일반 웹사이트면 바로 인앱 브라우저로
    if (urlType == UrlType.general) {
      await _launchInApp(url, context);
      return;
    }

    // SNS 링크면 선택 다이얼로그
    _showLaunchOptions(url, urlType, context);
  }

  // ==================== 선택 다이얼로그 ====================

  static void _showLaunchOptions(
    String url,
    UrlType urlType,
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 헤더
              Text(
                '링크 열기',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                url,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),

              // 앱으로 열기 버튼
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _launchInExternalApp(url, context);
                },
                icon: Icon(getIcon(urlType)),
                label: Text('${getAppName(urlType)} 앱으로 열기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: getColor(urlType),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // 웹 버전으로 열기 버튼 (수정됨)
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // 웹 버전 URL로 변환해서 열기
                  final webUrl = convertToWebVersion(url, urlType);
                  _launchInApp(webUrl, context);
                },
                icon: const Icon(Icons.language),
                label: const Text('웹 버전으로 열기'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              // 설명 텍스트 추가
              const SizedBox(height: 4),
              Text(
                '앱으로 자동 전환되지 않는 웹 버전',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // 취소 버튼
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 내부 실행 함수들 ====================

  /// 인앱 브라우저로 열기 (Custom Tabs)
  static Future<void> _launchInApp(String url, BuildContext context) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } else {
        Fluttertoast.showToast(
          msg: 'URL을 열 수 없습니다',
          backgroundColor: AppColors.error,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: '브라우저를 열 수 없습니다',
        backgroundColor: AppColors.error,
      );
    }
  }

  /// 외부 앱으로 열기
  static Future<void> _launchInExternalApp(
    String url,
    BuildContext context,
  ) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Fluttertoast.showToast(
          msg: '앱이 설치되어 있지 않습니다',
          backgroundColor: AppColors.error,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: '앱을 열 수 없습니다',
        backgroundColor: AppColors.error,
      );
    }
  }

  // ==================== 기존 함수들 (호환성 유지) ====================

  /// 웹에서 새 탭으로 열기
  static Future<void> openUrlInNewTab(String url) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
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

  /// 인앱 브라우저로 열기 (공개 API)
  static Future<void> openUrlInApp(String url) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
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

  /// URL 유효성 검사
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
