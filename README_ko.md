# LedgerLearn — 회계 학습 시뮬레이션

<p align="center">
  <img src="logo.png" alt="LedgerLearn Logo" width="128" height="128">
</p>

<p align="center">
  <a href="README.md">中文</a> · <a href="README_en.md">English</a> · <b>한국어</b>
</p>

<p align="center">
  <a href="https://github.com/Maicarons/ledgerlearn/releases"><img src="https://img.shields.io/github/v/release/Maicarons/ledgerlearn?color=blue&label=Release" alt="GitHub Release"></a>
  <a href="https://github.com/Maicarons/ledgerlearn/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-GPLv3-blue.svg" alt="License: GPL v3"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://maicarons.github.io/LedgerLearn/"><img src="https://img.shields.io/badge/Web-Demo-4285F4?logo=googlechrome&logoColor=white" alt="Web Demo"></a>
</p>

초보자를 위한 다언어 **회계 학습 시뮬레이터**입니다. 복식부기를 직접 실습하며 배웁니다: 전표, 장부, 시산표, 재무제표 — 연습 문제와 지식 카드가 함께 제공됩니다.

> ⚠️ **적용 범위**: 계정 과목과 학습 내용은 **중국 기업회계기준(ASBE)**을 따릅니다. 다른 국가/지역의 회계 기준과는 다를 수 있습니다.

## 다운로드

| 플랫폼 | 출처 |
|---|---|
| Android | [GitHub Releases](https://github.com/Maicarons/ledgerlearn/releases) · F-Droid (심사 중) |
| Web | [라이브 데모](https://maicarons.github.io/LedgerLearn/) |
| 데스크톱 / iOS | 소스에서 빌드 |

## 기능

| 모듈 | 설명 |
|---|---|
| **대시보드** | 회계기간 개요: 전표 수, 차변/대변 합계, 균형 상태, 6기간 추이 차트 |
| **전표** | 생성/수정/삭제, 동적 분개, 차대균형 검증, 업무 템플릿 8종, 검색 |
| **계정과목** | ASBE 표준 62개 (자산/부채/자본/원가/손익), 사용자 정의 가능 |
| **장부** | 총계정원장 · 명세원장 |
| **재무제표** | 시산표, 손익계산서, 재무상태표, 비용/자산 차트, 결산 마법사 |
| **연습** | 실제 업무 시나리오 10종 자동 채점 + 오답노트 |
| **지식카드** | 다언어 카드 70+ (실무/법률/세무), 마크다운 |
| **내보내기** | 전표·장부·보고서 CSV / PDF |
| **설정** | zh / en / ko / ja / vi / th, 테마, 데이터 초기화 |

## 기술 스택

Flutter 3.x · GetX · GetStorage · fl_chart · pdf · intl

## 시작하기

```bash
git clone https://github.com/Maicarons/ledgerlearn.git
cd ledgerlearn
flutter pub get
flutter analyze
flutter test
flutter run -d chrome      # 또는 windows / android
```

## 번역

번역은 **GitHub Pull Request**로 기여합니다.

1. Fork → `i18n/<locale>.json` 편집 (키는 `zh-CN`와 동일)
2. `dart run scripts/gen_i18n.dart`
3. PR 제목: `l10n(<locale>): …`

자세한 내용: [doc/translation-guide.md](doc/translation-guide.md)

## 프로젝트 구조

```
lib/
├── app/           # 라우팅, 테마, i18n, 기본 계정과목
├── data/          # 모델, 리포지토리, 서비스
├── modules/       # home, voucher, accounts, ledger, reports, practice, knowledge, settings, about
└── shared/        # 위젯, 금액 유틸
i18n/              # UI 문자열 (JSON)
knowledge_card/    # 학습 카드 (JSON)
```

## 라이선스

[GNU GPL v3.0](LICENSE) · Copyright (C) 2026 Maicarons
