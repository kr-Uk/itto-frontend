import 'package:flutter/material.dart';

class ProfileData {
  final String id;
  final String name;
  final int age;
  final String intro;
  final List<String> hashtags;
  final List<Color> photoGradientColors;

  const ProfileData({
    required this.id,
    required this.name,
    required this.age,
    required this.intro,
    required this.hashtags,
    required this.photoGradientColors,
  });
}

class MockProfiles {
  MockProfiles._();

  static const _gradients = [
    [Color(0xFFE8A0BF), Color(0xFF9B7BFF)],
    [Color(0xFF6366F1), Color(0xFFA78BFA)],
    [Color(0xFF14B8A6), Color(0xFF06B6D4)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    [Color(0xFF10B981), Color(0xFF3B82F6)],
    [Color(0xFFF472B6), Color(0xFFFBBF24)],
    [Color(0xFF6EE7B7), Color(0xFF3B82F6)],
    [Color(0xFFE879F9), Color(0xFF7C3AED)],
    [Color(0xFFFCA5A5), Color(0xFFFBBF24)],
  ];

  static final List<ProfileData> inyeonProfiles = [
    ProfileData(
      id: '1',
      name: '수수',
      age: 26,
      intro: '음악 좋아하는 감성파',
      hashtags: ['#음악', '#산책', '#카페'],
      photoGradientColors: _gradients[0],
    ),
    ProfileData(
      id: '2',
      name: '하늘',
      age: 24,
      intro: '영화 보는 걸 좋아해요',
      hashtags: ['#영화', '#드라마', '#팝콘'],
      photoGradientColors: _gradients[1],
    ),
    ProfileData(
      id: '3',
      name: '별이',
      age: 28,
      intro: '여행과 사진이 취미입니다',
      hashtags: ['#여행', '#사진', '#맛집'],
      photoGradientColors: _gradients[2],
    ),
    ProfileData(
      id: '4',
      name: '도윤',
      age: 25,
      intro: '운동 좋아하는 활동파',
      hashtags: ['#운동', '#등산', '#러닝'],
      photoGradientColors: _gradients[3],
    ),
    ProfileData(
      id: '5',
      name: '서연',
      age: 27,
      intro: '책과 커피를 좋아합니다',
      hashtags: ['#독서', '#커피', '#글쓰기'],
      photoGradientColors: _gradients[4],
    ),
    ProfileData(
      id: '6',
      name: '지호',
      age: 23,
      intro: '게임과 코딩이 일상',
      hashtags: ['#게임', '#코딩', '#야식'],
      photoGradientColors: _gradients[5],
    ),
    ProfileData(
      id: '7',
      name: '민서',
      age: 26,
      intro: '요리하는 것을 좋아해요',
      hashtags: ['#요리', '#베이킹', '#맛집'],
      photoGradientColors: _gradients[6],
    ),
    ProfileData(
      id: '8',
      name: '윤아',
      age: 25,
      intro: '댄스와 노래가 취미',
      hashtags: ['#댄스', '#노래', '#공연'],
      photoGradientColors: _gradients[7],
    ),
  ];

  static final List<ProfileData> pilyeonProfiles = [
    ProfileData(
      id: '9',
      name: '재민',
      age: 27,
      intro: '음악과 여행을 사랑하는',
      hashtags: ['#음악', '#여행', '#기타'],
      photoGradientColors: _gradients[8],
    ),
    ProfileData(
      id: '10',
      name: '유진',
      age: 24,
      intro: '드라마 덕후입니다',
      hashtags: ['#드라마', '#넷플릭스', '#간식'],
      photoGradientColors: _gradients[9],
    ),
    ProfileData(
      id: '11',
      name: '소율',
      age: 26,
      intro: '산책과 독서를 좋아해요',
      hashtags: ['#산책', '#독서', '#카페'],
      photoGradientColors: _gradients[0],
    ),
    ProfileData(
      id: '12',
      name: '시우',
      age: 28,
      intro: '카페 투어가 취미입니다',
      hashtags: ['#카페', '#디저트', '#사진'],
      photoGradientColors: _gradients[3],
    ),
    ProfileData(
      id: '13',
      name: '하린',
      age: 25,
      intro: '그림 그리는 것을 좋아해요',
      hashtags: ['#그림', '#전시회', '#미술'],
      photoGradientColors: _gradients[5],
    ),
    ProfileData(
      id: '14',
      name: '은수',
      age: 23,
      intro: '영화광이에요',
      hashtags: ['#영화', '#팝콘', '#시네마'],
      photoGradientColors: _gradients[2],
    ),
    ProfileData(
      id: '15',
      name: '지안',
      age: 27,
      intro: '요가와 명상을 즐겨요',
      hashtags: ['#요가', '#명상', '#건강'],
      photoGradientColors: _gradients[4],
    ),
  ];

  static final List<ProfileData> pastInyeonProfiles = [
    ProfileData(
      id: '50',
      name: '예진',
      age: 25,
      intro: '같이 산책해요',
      hashtags: ['#산책', '#카페', '#음악'],
      photoGradientColors: _gradients[6],
    ),
    ProfileData(
      id: '51',
      name: '준혁',
      age: 27,
      intro: '커피 한잔 할래요?',
      hashtags: ['#커피', '#독서', '#영화'],
      photoGradientColors: _gradients[1],
    ),
    ProfileData(
      id: '52',
      name: '소희',
      age: 24,
      intro: '여행을 좋아하는 사람',
      hashtags: ['#여행', '#사진', '#맛집'],
      photoGradientColors: _gradients[4],
    ),
    ProfileData(
      id: '53',
      name: '태민',
      age: 26,
      intro: '운동과 음악이 취미',
      hashtags: ['#운동', '#음악', '#헬스'],
      photoGradientColors: _gradients[8],
    ),
    ProfileData(
      id: '54',
      name: '지수',
      age: 23,
      intro: '그림 그리는 것을 좋아해요',
      hashtags: ['#그림', '#전시회', '#카페'],
      photoGradientColors: _gradients[2],
    ),
  ];

  static final List<ProfileData> uyeonProfiles = List.generate(
    21,
    (i) {
      final names = [
        '서준', '도현', '예은', '시현', '지원',
        '유나', '민재', '소영', '태윤', '수빈',
        '하윤', '준서', '채원', '건우', '다은',
        '성민', '예린', '우진', '나연', '현우',
        '지유',
      ];
      final intros = [
        '산책을 좋아해요', '게임 마니아', '음악 좋아해요',
        '카페 투어 중', '영화 마니아', '여행 좋아해요',
        '독서가 취미', '운동 좋아해요', '사진 찍기 좋아해요',
        '요리를 즐겨요', '드라마 덕후', '코딩이 취미',
        '댄스를 좋아해요', '그림 그려요', '노래 좋아해요',
        '등산 좋아해요', '베이킹 취미', '맛집 탐방',
        '카페 좋아해요', '러닝 중', '요가를 즐겨요',
      ];
      final allTags = [
        ['#산책', '#카페'], ['#게임', '#야식'], ['#음악', '#기타'],
        ['#카페', '#디저트'], ['#영화', '#팝콘'], ['#여행', '#사진'],
        ['#독서', '#글쓰기'], ['#운동', '#러닝'], ['#사진', '#여행'],
        ['#요리', '#맛집'], ['#드라마', '#넷플릭스'], ['#코딩', '#게임'],
        ['#댄스', '#공연'], ['#그림', '#전시회'], ['#노래', '#음악'],
        ['#등산', '#자연'], ['#베이킹', '#요리'], ['#맛집', '#카페'],
        ['#카페', '#산책'], ['#러닝', '#운동'], ['#요가', '#명상'],
      ];
      return ProfileData(
        id: '${100 + i}',
        name: names[i],
        age: 22 + (i % 8),
        intro: intros[i],
        hashtags: allTags[i],
        photoGradientColors: _gradients[i % _gradients.length],
      );
    },
  );
}
