# HSK 단어마스터 (HSK 单词大师)

> HSK 3.0 **3급~6급 764단어**를 매일 조금씩 익히는 플래시카드 학습 앱

중국어 학습자 대부분이 겪는 문제는 "단어를 외워도 금방 잊는다"는 것입니다.
이 앱은 **라이트너 간격 반복(Spaced Repetition)** 방식으로 이미 아는 단어는
간격을 늘리고, 틀린 단어는 더 자주 다시 만나게 해서 **하루 20단어, 부담 없이**
꾸준히 학습할 수 있도록 설계했습니다.

---

## 주요 기능

### 📚 3~6급 단어장 (764단어)
| 급수 | 단어 수 | 난이도 |
|:---:|:---:|---|
| HSK 3급 | 110 | 일상 회화 기초 |
| HSK 4급 | 256 | 폭넓은 주제 대화 |
| HSK 5급 | 204 | 신문·업무 수준 |
| HSK 6급 | 193 | 전문적·추상적 표현 |

각 단어는 **한자 · 병음 · 품사 · 한국어 뜻 · 중국어 예문 · 예문 해석**을 포함합니다.

### 🔊 중국어 발음 재생 (TTS)
학습 카드, 단어장 목록, 단어 상세 어디서든 발음 버튼 한 번으로 원어민 발음을 듣습니다.
- Android: 기기 내장 TTS 엔진 (zh-CN)
- Web: 브라우저 Web Speech API

### 🎯 간격 반복 학습 (Leitner System)
답변 결과에 따라 단어를 6단계 박스로 이동시키고, 다음 복습 시점을 자동 계산합니다.

| 박스 | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| 복습 간격 | 1일 | 2일 | 4일 | 7일 | 14일 | 30일 |

- **알아요** → 다음 박스로 이동 (간격 늘어남)
- **몰라요** → 박스 0으로 복귀 (바로 다음날 다시)
- 박스 5 도달 = **암기 완료**

### 📝 4지선다 퀴즈
- `한자 → 뜻`, `뜻 → 한자` 두 가지 방향
- 오답은 같은 급수 단어에서 무작위 추출
- 퀴즈 결과도 학습 진도에 반영

### 📊 학습 통계
- 급수별 암기 / 학습 중 / 미학습 비율
- 연속 학습일(스트릭) 및 최고 기록
- 최근 30일 학습 히트맵

### 🔖 단어장 & 검색
- 한자·병음·뜻·예문 통합 검색
- 급수 필터, 즐겨찾기 모아보기

---

## 스크린샷

| 홈 (대시보드) | 학습 카드 | 카드 뒷면 |
|:---:|:---:|:---:|
| 오늘의 목표 · 급수별 진입 | 한자 + 발음 버튼 | 뜻 · 예문 · 예문 해석 |

*(스크린샷은 `docs/screenshots/`에 추가 예정)*

---

## 기술 스택

| 구분 | 사용 기술 |
|---|---|
| 프레임워크 | Flutter 3.35.4 / Dart 3.9.2 |
| 상태 관리 | Provider (`ChangeNotifierProvider`) |
| 로컬 저장소 | Hive 2.2.3 + hive_flutter 1.1.0 |
| TTS | flutter_tts 4.2.5 (zh-CN) |
| 디자인 | Material Design 3 (커스텀 코랄 테마) |
| 타겟 플랫폼 | Android / Web |

### 아키텍처

```
lib/
├── main.dart                  # 앱 진입점, Provider 주입
├── models/
│   └── word.dart              # Word 모델
├── data/
│   ├── parse_helper.dart      # 단어 테이블 파서
│   ├── hsk_level3~6.dart      # 급수별 단어 데이터
│   └── word_repository.dart   # 단어 조회 파사드
├── services/
│   ├── progress_service.dart  # 학습 진도 / 스트릭 / Hive
│   ├── speech_service.dart    # TTS 래퍼 (Android + Web)
│   └── study_queue_builder.dart # 학습 큐 · 오답 선택
├── screens/
│   ├── home_screen.dart       # 4탭 셸 + 대시보드
│   ├── study_screen.dart      # 3D 플립 학습 카드
│   ├── word_list_screen.dart  # 단어장 · 검색 · 상세
│   ├── quiz_screen.dart       # 퀴즈 설정 · 진행
│   └── stats_screen.dart      # 통계 · 히트맵
├── widgets/                   # 공용 UI 컴포넌트
└── theme/
    └── app_theme.dart         # 디자인 시스템
```

---

## 시작하기

### 요구 사항
- Flutter 3.35.4 이상 (Dart 3.9.2)
- Android SDK 35 (APK 빌드 시)

### 실행

```bash
git clone https://github.com/<your-id>/hsk-word-master.git
cd hsk-word-master
flutter pub get

# 웹 실행
flutter run -d chrome

# Android 실행
flutter run -d android
```

### 릴리스 APK 빌드

서명 키가 필요한 경우 `android/key.properties`를 생성합니다.

```properties
storePassword=<your-password>
keyPassword=<your-password>
keyAlias=release
storeFile=../release-key.jks
```

```bash
flutter build apk --release
# 결과: build/app/outputs/flutter-apk/app-release.apk
```

> ⚠️ `key.properties`와 `*.jks`는 `.gitignore`에 등록되어 저장소에 포함되지 않습니다.
> 서명 키는 반드시 별도의 안전한 장소에 백업하세요.

---

## 로드맵

- [x] 3~6급 764단어 데이터
- [x] 간격 반복 학습 · 스트릭 · 일일 목표
- [x] 4지선다 퀴즈
- [x] 중국어 발음 TTS 재생
- [x] 학습 통계 · 히트맵
- [ ] 예문 전체 발음 재생
- [ ] 오프라인 발음용 음성 파일 캐싱
- [ ] 단어 데이터 오탈자 검수 (이슈로 제보 환영)
- [ ] 다크 모드

---

## 기여

단어 오탈자, 병음 오류, 예문 개선 제보는 언제든 환영합니다.
[이슈](../../issues)로 등록해 주세요.

## 라이선스

MIT License — 자유롭게 사용·수정·배포할 수 있습니다.

> 단어 데이터는 HSK 3.0 공식 어휘 목록을 기반으로 학습용 예문과 함께 정리한 것입니다.
