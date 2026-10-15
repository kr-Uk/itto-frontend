# itto

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# 공개 저장소와 빌드 설정

`pubspec.yaml`에서 `.env`를 Flutter asset으로 포함하므로 앱과 웹 빌드에서 내용을 읽을 수 있다. `.env`에는 공개 가능한 API URL과 클라이언트 ID만 넣는다. 네이버 클라이언트 시크릿과 다른 서버 비밀값은 백엔드에서만 사용한다.

Transistorsoft 위치 SDK 라이선스는 저장소 밖에서 빌드 시 제공한다.

- Android: 릴리스 빌드 환경 변수 `BG_GEO_LICENSE`를 설정한다.
- iOS: Git에서 무시되는 `ios/Flutter/BackgroundGeolocation.xcconfig` 파일에 `BG_GEO_LICENSE=<라이선스 값>`을 설정한다.
- Debug 빌드는 라이선스 없이 실행할 수 있다. 릴리스 빌드에는 이 앱용 유효한 라이선스가 필요하다.
