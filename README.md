# 📚 Bookmark Manager

> Flutter + Firebase를 활용한 크로스 플랫폼 북마크 관리 웹 애플리케이션

[![Flutter](https://img.shields.io/badge/Flutter-3.35.4-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Hosting-FFCA28?logo=firebase)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-3.0.3-00A8E1)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[🌐 Live Demo](https://bookmark-manager-24e55.web.app) | [📖 개발 블로그](https://github.com/Doythan/bookmark_manager)

## 📝 프로젝트 소개

처음으로 실제 배포까지 완료한 토이 프로젝트입니다. Flutter와 Firebase를 활용하여 웹과 모바일 모두에서 동작하는 북마크 관리 애플리케이션을 개발했습니다.

### 🎯 개발 목표

- ✅ 첫 배포 경험 쌓기: 개발부터 배포까지 전체 프로세스 학습
- ✅ 실시간 동기화: Firestore를 활용한 실시간 데이터 관리
- ✅ 크로스 플랫폼: 단일 코드베이스로 웹/모바일 지원
- ✅ 현대적 아키텍처: Clean Architecture와 Riverpod 상태 관리

## ✨ 주요 기능

### 🔐 사용자 인증
- 이메일/비밀번호 회원가입 및 로그인
- Firebase Authentication 연동
- 세션 자동 관리 및 보안 처리

### 📌 북마크 관리
- 추가: URL, 제목, 설명, 카테고리 설정
- 수정: 기존 북마크 정보 업데이트
- 삭제: 확인 다이얼로그와 함께 안전한 삭제
- 실시간 동기화: Firestore Stream으로 자동 업데이트

### 🔍 검색 및 필터링
- 카테고리 필터: 카테고리별 북마크 분류
- 실시간 검색: 제목, URL, 설명에서 검색
- FilterChip UI: 직관적인 필터 인터페이스

### 🌐 URL 관리
- 북마크 클릭으로 새 탭에서 URL 열기
- URL 복사 기능
- 유효성 검사 (http/https)

## 🛠 기술 스택

### Frontend
- Flutter 3.35.4: 크로스 플랫폼 UI 프레임워크
- Dart 3.9.2: 프로그래밍 언어
- Material Design 3: UI/UX 디자인 시스템

### Backend & Services
- Firebase Authentication: 사용자 인증 관리
- Cloud Firestore: NoSQL 실시간 데이터베이스
- Firebase Hosting: 정적 웹 호스팅 (CDN)

### State Management & Navigation
- flutter_riverpod ^3.0.3: 상태 관리
- go_router ^16.2.4: 선언적 라우팅

### Utilities
- url_launcher ^6.3.2: URL 실행
- fluttertoast ^9.0.0: 토스트 알림
- intl ^0.20.2: 날짜/시간 포맷팅

## 🏗 프로젝트 구조

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_strings.dart
│   └── utils/
│       └── url_launcher_helper.dart
├── features/
│   ├── auth/
│   │   ├── models/
│   │   ├── screens/
│   │   └── services/
│   └── bookmarks/
│       ├── models/
│       ├── screens/
│       ├── services/
│       └── widgets/
└── routes/
    └── app_router.dart
```

## 🚀 시작하기

### 사전 요구사항
- Flutter SDK 3.24.0 이상
- Firebase CLI 14.0.0 이상
- Dart 3.9.0 이상

### 설치 및 실행

```bash
# 1. 저장소 클론
git clone https://github.com/Doythan/bookmark_manager.git
cd bookmark_manager

# 2. 의존성 설치
flutter pub get

# 3. Firebase 설정
firebase login
dart pub global activate flutterfire_cli
flutterfire configure

# 4. 앱 실행 (웹)
flutter run -d chrome

# 4. 앱 실행 (Android)
flutter run -d android
```

## 🌐 배포

### 웹 배포 (Firebase Hosting)

```bash
# 빌드
flutter build web --release

# 배포
firebase deploy --only hosting
```

**배포된 URL**
- Production: https://bookmark-manager-24e55.web.app
- Alternative: https://bookmark-manager-24e55.firebaseapp.com

## 📱 지원 플랫폼

- 🌐 Web: ✅ 배포 완료 (Firebase Hosting)
- 🤖 Android: 🚧 준비 중 (APK 빌드 예정)
- 🍎 iOS: 📋 계획 중 (macOS 환경 필요)
- 💻 macOS: ⚙️ 개발 가능 (로컬 테스트)

## 🔐 보안

### Firestore 보안 규칙
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /bookmarks/{bookmarkId} {
      allow read, write: if request.auth != null 
                         && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null 
                    && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

## 📊 성능 최적화

- Tree-shaking: 폰트 파일 99.4% 감소 (1.6MB → 9.6KB)
- 캐싱 전략: 이미지/폰트/JS/CSS 장기 캐싱
- CDN: Firebase Hosting의 전 세계 CDN
- HTTP/2 및 자동 SSL 지원

## 🐛 트러블슈팅

### Firestore 인덱스 에러
```
[cloud_firestore/failed-precondition] The query requires an index.
```
해결: 에러 메시지의 URL 클릭 → 자동 인덱스 생성

### Riverpod 3.x StateProvider
```
The function 'StateProvider' isn't defined.
```
해결: `import 'package:flutter_riverpod/legacy.dart';` 추가

## 📚 개발 블로그 시리즈

1. 프로젝트 초기 설정 및 Firebase 연동
2. 프로젝트 구조 설계 및 Riverpod 적용
3. Firebase Authentication 연동 및 로그인 구현
4. Firestore 연동 및 북마크 CRUD 구현
5. Firebase Hosting으로 웹 배포하기

## 🔮 향후 계획

### 단기 (1개월)
- [ ] Android APK 빌드 및 테스트
- [ ] Firebase Analytics 연동
- [ ] PWA 기능 추가

### 중기 (3개월)
- [ ] iOS 앱 빌드
- [ ] Google Play 배포
- [ ] 커스텀 도메인 연결

### 장기 (6개월)
- [ ] 북마크 태그 기능
- [ ] 북마크 폴더 계층 구조
- [ ] 다크 모드 지원
- [ ] 다국어 지원


## 🤝 기여

이슈와 풀 리퀘스트는 언제나 환영합니다!

## 📧 연락처

- GitHub: [@Doythan](https://github.com/Doythan)
- Email: won03289@gmail.com

---

<div align="center">

**⭐ 이 프로젝트가 도움이 되었다면 Star를 눌러주세요! ⭐**

</div>
```