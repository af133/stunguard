# StuntGuard — Product Requirements Document (PRD)

**Version**: 1.0.0  
**Date**: August 2026  
**Product Owner**: StuntGuard Team  
**Tech Stack**: Flutter (Dart), Android API 26+, TFLite, SQLite, Riverpod  

---

## 1. Overview & Problem Statement

### 1.1 Problem

Stunting (keterlambatan pertumbuhan) remains a critical public health challenge in Indonesia. According to the 2023 Integrated Survey of Stunting (SSGI), approximately **30.8%** of Indonesian toddlers (0–59 months) are stunted. Early detection and intervention during the first 1,000 days of life is the most effective strategy for prevention, but:

- **Manual z-score calculations** are error-prone and time-consuming in field conditions.
- **Posyandu cadres** lack digital tools to systematically track child growth.
- **AI-assisted screening** is not accessible offline in remote, low-connectivity areas.
- **Nutritional logging and follow-up recommendations** are fragmented and paper-based.

### 1.2 Solution

**StuntGuard** is a Flutter-based, **offline-first** mobile application designed for **posyandu cadres** to:

1. Register and manage toddler (balita) profiles (0–59 months).
2. Record routine anthropometric measurements (TB, BB, LiLA, lingkar kepala).
3. Automatically compute **WHO z-scores** using the LMS method.
4. Run **on-device AI risk assessment** (TFLite ensemble model).
5. Capture child face photos for supplementary computer vision analysis.
6. Log daily food intake via photo classification (50 local/MPASI categories).
7. Visualize growth trajectories against WHO reference curves.
8. Generate and deliver targeted nutritional recommendations.
9. Synchronize data when connectivity is restored.
10. Send scheduled reminders via local notifications.

### 1.3 Key Value Propositions

| Stakeholder | Value |
|---|---|
| Posyandu Kader | Streamlined, offline-capable screening tool with automated risk scoring |
| Public Health System | Scalable, data-driven early intervention for stunting reduction |
| Orang Tua | Receives timely alerts and recommendations via notifications/WhatsApp |

---

## 2. Goals & Success Metrics

### 2.1 Product Goals

| Goal | Description |
|---|---|
| **G-01** | Digitize and standardize anthropometric screening for 1,000+ posyandu cadres |
| **G-02** | Reduce stunting detection and referral time from visit-to-decision |
| **G-03** | Maintain 100% functionality for core features (F-01 through F-08) without an internet connection |
| **G-04** | Achieve sub-50ms on-device AI inference latency for risk assessment |
| **G-05** | Support multilingual-free operation in Bahasa Indonesia only (v1 scope) |

### 2.2 Success Metrics

| Metric | Target | Measurement Method |
|---|---|---|
| M-01 | ≥ 500 children screened per active cadre per month | App analytics (local) |
| M-02 | ≥ 95% offline task completion rate | Local task success logging |
| M-03 | ≤ 50ms average AI inference latency | On-device benchmark |
| M-04 | < 1% sync data loss rate | Server-side reconciliation |
| M-05 | ≥ 80% unit test coverage on core logic | `flutter test --coverage` |
| M-06 | 0 `flutter analyze` errors | CI pipeline |

---

## 3. User Personas

### 3.1 Primary Persona: Posyandu Kader

| Attribute | Detail |
|---|---|
| **Name** | Ibu Siti, 42 |
| **Role** | Posyandu cadre in Desa Suka Maju |
| **Device** | Android smartphone (API 26+) |
| **Tech Literacy** | Basic — familiar with WhatsApp, camera, basic forms |
| **Goals** | Quickly screen children, identify at-risk toddlers, refer to relevant programs |
| **Pain Points** | No digital tools, manual calculations, limited connectivity in field |
| **Behaviors** | Works primarily offline, visits homes, conducts monthly posyandu sessions |

### 3.2 Secondary Persona: Orang Tua

| Attribute | Detail |
|---|---|
| **Name** | Bapak Ahmad, 35 |
| **Role** | Parent of a monitored toddler |
| **Device** | Basic Android phone |
| **Tech Literacy** | Very basic — uses WhatsApp and calls |
| **Goals** | Receive updates on child's growth, follow recommendations |
| **Pain Points** | Cannot visit posyandu frequently, needs guidance at home |
| **Behaviors** | Receives summary notifications via WhatsApp/share; no full app access in v1 |

---

## 4. Feature Requirements

### 4.1 Feature Inventory

| ID | Feature | Priority | Status |
|---|---|---|---|
| F-01 | Manajemen Data Balita | High | Not Started |
| F-02 | Input Pengukuran Rutin | High | Not Started |
| F-03 | Kalkulasi Z-Score Otomatis | High | **Implemented** (core/utils/zscore_calculator.dart) |
| F-04 | Deteksi Risiko AI | High | Stub/Mock |
| F-05 | Scan Wajah CV | Medium | Not Started |
| F-06 | Log Nutrisi Harian | Medium | Not Started |
| F-07 | Riwayat Pertumbuhan | High | Not Started |
| F-08 | Rekomendasi Intervensi | High | Not Started |
| F-09 | Mode Offline & Sinkronisasi | High | Not Started |
| F-10 | Notifikasi Jadwal | Low | Not Started |
| Auth | Registrasi & Login Kader | High | **UI Implemented**, logic stubbed |

### 4.2 Feature Details

#### F-01: Manajemen Data Balita (Child Management)
- **Priority**: High
- **User Story**: As a kader, I want to register and manage toddler profiles so that I can track their growth over time.
- **Requirements**:
  - CRUD operations for child records: name, NIK (optional), birth date, gender, mother's name, address, BBLR history, exclusive breastfeeding duration, MPASI start age.
  - Search and filter by name, age, or risk status.
  - Age validation: must be 0–59 months.
- **Acceptance Criteria**:
  - Form validates all required fields.
  - Child list supports search and filtering.
  - Age outside 0–59 months is rejected at entry.

#### F-02: Input Pengukuran Rutin (Routine Measurements)
- **Priority**: High
- **User Story**: As a kader, I want to record anthropometric measurements so that z-scores can be computed automatically.
- **Requirements**:
  - Input fields: TB/panjang badan (cm), BB (kg), LiLA (cm, 6–59 months), lingkar kepala (cm).
  - Physiological range validation: reject TB < 30cm or > 130cm.
  - Save with timestamp.
- **Acceptance Criteria**:
  - Invalid inputs are rejected with clear error messages.
  - Measurements save locally before any sync attempt.

#### F-03: Kalkulasi Z-Score Otomatis (Z-Score Calculation)
- **Priority**: High
- **Status**: **Implemented** — `lib/core/utils/zscore_calculator.dart`
- **User Story**: As a kadle, I want z-scores to be calculated automatically so that I don't have to do manual math.
- **Requirements**:
  - LMS method per WHO standards:
    - If L(t) ≠ 0: `z = (((y / M(t))^L(t)) - 1) / (L(t) * S(t))`
    - If L(t) = 0: `z = ln(y / M(t)) / S(t)`
  - Extreme value correction for weight-based indicators (z > 3 or z < -3).
  - Categories:
    - TB/U: < -3 → severely stunted, -3 to -2 → stunted, ≥ -2 → normal
    - BB/U: < -3 → severely underweight, -3 to -2 → underweight, ≥ -2 → normal
    - BB/TB: < -3 → severely wasted, -3 to -2 → wasted, ≥ -2 → normal
  - WHO LMS tables stored in `assets/who_tables/` as JSON, separated by indicator and gender.
- **Acceptance Criteria**:
  - Pure function with no UI dependency.
  - 11 unit tests pass (in `test/core/utils/zscore_calculator_test.dart`).
  - Results match WHO Anthro reference values for validation cases.

#### F-04: Deteksi Risiko AI (AI Risk Detection)
- **Priority**: High
- **User Story**: As a kader, I want an AI-powered risk score so that I can prioritize high-risk children.
- **Requirements**:
  - TFLite ensemble model (XGBoost + Random Forest converted to TFLite).
  - 14 input features: `[zscore_tbu, zscore_bbu, zscore_bbtb, lila, usia_bulan, jenis_kelamin, urutan_kelahiran, jarak_kelahiran, riwayat_bblr, durasi_asi_eksklusif, usia_mulai_mpaci, pendidikan_ibu, sumber_air_minum, akses_sanitasi]`
  - Output: `{ skor: float (0-1), kategori: "rendah"|"sedang"|"tinggi", confidence: float }`
  - Latency target: < 50ms on-device.
- **Acceptance Criteria**:
  - Model wrapper interface is stable and replaceable.
  - Stub returns consistent dummy scores with TODO comments for production model.
  - Result screen displays disclaimer: "Bukan diagnosis medis".

#### F-05: Scan Wajah CV (Face Scan CV)
- **Priority**: Medium
- **User Story**: As a kader, I want to scan a child's face so that supplementary CV features can be included in risk assessment.
- **Requirements**:
  - Camera capture with oval frame guide.
  - TFLite MobileNetV2 model on-device.
  - Brightness validation before capture (minimal lighting check).
  - **Skip button** — face scan is supplementary and never blocks the workflow.
  - If scan fails: show guidance message (lighting, lens, positioning) + skip option.
- **Acceptance Criteria**:
  - Face scan result modifies (not replaces) the anthropometric risk score.
  - Skip button is always visible and functional.

#### F-06: Log Nutrisi Harian (Daily Nutrition Logging)
- **Priority**: Medium
- **User Story**: As a kader, I want to log a child's daily food intake via photo so that nutritional deficiencies can be tracked.
- **Requirements**:
  - TFLite EfficientNet-B0 classifies food into 50 categories (MPASI + local dishes).
  - Output: `{ kategori, confidence, estimasi_porsi, kalori, protein, zat_besi }`
  - Confidence threshold: 0.5. Below threshold → manual input fallback.
  - Manual fallback: user enters food name + estimated portion manually.
- **Acceptance Criteria**:
  - No dead-end: unrecognized food always falls back to manual entry.
  - Estimated calories/protein/iron are displayed per log entry.

#### F-07: Riwayat Pertumbuhan (Growth History)
- **Priority**: High
- **User Story**: As a kader, I want to see a child's growth trajectory so that I can spot trends.
- **Requirements**:
  - Line charts using `fl_chart`.
  - Overlay WHO reference curves (TB/U, BB/U, BB/TB).
  - Plot actual measurements against reference.
- **Acceptance Criteria**:
  - Charts render correctly for all three indicators.
  - Data loads from local SQLite storage.

#### F-08: Rekomendasi Intervensi (Intervention Recommendations)
- **Priority**: High
- **User Story**: As a kader, I want specific recommendations so that I can take the right action.
- **Requirements**:
  - Rule-based engine mapping risk score + child profile → recommendations.
  - Recommendations cover: supplementary feeding, referral to health services, nutrition education topics.
- **Acceptance Criteria**:
  - Recommendations vary by risk category (rendah/sedang/tinggi).
  - Each recommendation links to actionable next steps.

#### F-09: Mode Offline & Sinkronisasi (Offline-First & Sync)
- **Priority**: High
- **User Story**: As a kader working in remote areas, I want all features to work offline so that I can screen children without internet.
- **Requirements**:
  - All features F-01–F-08 work 100% offline.
  - Write operations always persist to SQLite first (`syncStatus: PENDING`, `retryCount: 0`).
  - **Push Phase**: On connectivity, `SyncManager` reads all `PENDING` records and upserts to backend API. Success → `SYNCED`. Failure → exponential backoff: `delay = 2^retryCount * base_delay`.
  - **Pull Phase**: After push, fetch latest server data by `lastSyncTimestamp`. Apply **server-wins** conflict resolution.
  - Background sync via `workmanager`.
  - Manual sync trigger in Settings: "Paksa Sinkronisasi".
- **Acceptance Criteria**:
  - Unit tests for: push success, push fail + retry, pull with server-wins conflict.
  - Manual sync button shows error codes if sync fails persistently.

#### F-10: Notifikasi Jadwal (Scheduled Notifications)
- **Priority**: Low
- **User Story**: As a kader, I want reminders for scheduled visits so that I don't miss follow-ups.
- **Requirements**:
  - Local notifications via `flutter_local_notifications`.
  - Monthly posyandu session reminders.
  - Automated follow-ups for medium/high-risk children.
- **Acceptance Criteria**:
  - Notifications respect device notification settings.
  - Customizable via Settings.

### 4.3 Authentication

#### Auth: Registrasi & Login Kader
- **Priority**: High (prerequisite)
- **Status**: UI implemented (`login_page.dart`, `register_page.dart`); logic stubbed
- **User Story**: As a kader, I want to register my posyandu details and log in with my phone number so that my data is associated with my identity.
- **Requirements**:
  - Registration: name, NIK, phone (WhatsApp/HP), posyandu name, work area.
  - Login: role selection (kader vs orang_tua), phone number entry, OTP flow (TODO).
  - State management via Riverpod (`auth_provider.dart`).
  - Entity: `UserEntity` (id, name, nik, phone, posyanduName, workArea, role).
- **Acceptance Criteria**:
  - Registration form validates all required fields.
  - OTP logic is stubbed with clear TODO comments for backend integration.

---

## 5. User Stories

### Epic: Child Data Management
```
As a kader,
I want to register a new child (F-01),
so that I can track their growth metrics from birth.

Acceptance Criteria:
- Form requires: name, birth date, gender, mother's name.
- Age auto-calculated; must be 0–59 months.
- Child appears in searchable list after registration.
- Child can be edited or deleted.
```

### Epic: Measurement & Z-Score
```
As a kader,
I want to record TB, BB, and optional LiLA/lingkar kepala (F-02),
so that the app can calculate z-scores automatically (F-03).

Acceptance Criteria:
- Input validates physiological ranges (e.g., TB 30–130cm).
- Z-score computed instantly using WHO LMS tables.
- Result shows category (normal/stunted/underweight/wasted) with color coding.
- Disclaimer "Bukan diagnosis medis" is displayed.
```

### Epic: AI Risk Assessment
```
As a kader,
I want an AI-generated risk score (F-04),
so that I can prioritize children who need immediate attention.

Acceptance Criteria:
- Risk score computed on-device from 14 input features.
- Output: score (0–1), category (rendah/sedang/tinggi), confidence.
- Latency < 50ms on target devices.
- Face scan (F-05) can modify the score but is optional.
```

### Epic: Nutrition Logging
```
As a kader,
I want to photograph a child's meal (F-06),
so that I can log nutritional intake and spot deficiencies.

Acceptance Criteria:
- Food photo processed by EfficientNet-B0 (50 categories).
- If confidence < 0.5, prompt for manual entry.
- Display kalori, protein, zat_besi estimates.
```

### Epic: Offline Sync
```
As a kadar working offline,
I want my data to sync automatically when online (F-09),
so that nothing is lost when connectivity returns.

Acceptance Criteria:
- All writes persist to local DB first.
- Sync triggers on connectivity restoration.
- Retry uses exponential backoff.
- Settings menu has "Paksa Sinkronisasi" button.
- Server-wins conflict resolution applied on pull.
```

---

## 6. Technical Requirements

### 6.1 Framework & Platforms

| Layer | Technology | Justification |
|---|---|---|
| Framework | Flutter (Dart) | Cross-platform, strong community, proposal-specified |
| Target Platform | Android API 26+ (Android 8.0+) | Minimum viable target for TFLite, per spec |
| iOS | **Out of scope** for v1 | Per agent.md constraint §2.32 |
| AI Inference | TensorFlow Lite (TFLite) | On-device, low-latency, no internet dependency |
| Local Database | SQLite via `sqflite` | Embedded, reliable offline storage |
| State Management | Riverpod | Per `pubspec.yaml`; chosen for testability |
| HTTP Client | `dio` | For sync API calls to backend |
| Camera | `camera` plugin | Photo capture for CV tasks |
| Background Sync | `workmanager` | Scheduled background sync retries |
| Charts | `fl_chart` | Growth curve visualization |
| Notifications | `flutter_local_notifications` | Local scheduling |
| Typography | `google_fonts` (Inter) | Consistent, accessible typography |

### 6.2 Architecture

**Feature-First Clean Architecture** with three layers per feature:

```
lib/
  core/
    constants/       # AppColors, strings
    theme/           # AppTheme (blue-teal Material 3)
    utils/           # ZScoreCalculator, validators
    network/         # Dio client, interceptors (planned)
    database/        # SQLite setup, migrations (planned)
    ai/              # TFLite wrapper (planned)
  features/
    auth/
      data/          # Models, datasources (planned)
      domain/        # Entities (UserEntity ✅), repository interface (planned)
      presentation/  # LoginPage ✅, RegisterPage ✅, AuthProvider ✅
    balita/          # Child management (planned)
    pengukuran/      # Measurements (planned)
    deteksi_risiko/  # AI risk detection (planned)
    scan_wajah/      # Face CV (planned)
    log_nutrisi/     # Nutrition logging (planned)
    riwayat_pertumbuhan/ # Growth charts (planned)
    rekomendasi/     # Recommendations (planned)
    sync/            # Offline sync (planned)
    notifikasi/      # Notifications (planned)
  app.dart           # (planned)
  main.dart          # ✅ Entry point; MaterialApp with blue-teal theme, routes to LoginPage
```

### 6.3 Data Model

#### Entity: UserEntity (Implemented)
| Field | Type | Required | Description |
|---|---|---|---|
| id | String | Yes | Unique user identifier |
| name | String | Yes | Full name of cadre |
| nik | String? | No | 16-digit NIK |
| phone | String | Yes | WhatsApp/HP number |
| posyanduName | String | Yes | Posyandu unit name |
| workArea | String | Yes | Desa/Kelurahan/Kecamatan |
| role | String | Yes | 'kader' or 'orang_tua' |

#### Entity: Balita (Child) — Planned
| Field | Type | Required | Description |
|---|---|---|---|
| id | String | Yes | UUID |
| name | String | Yes | Child's full name |
| nik | String? | No | Child's NIK |
| birthDate | DateTime | Yes | Date of birth |
| gender | String | Yes | 'L' or 'P' |
| motherName | String | Yes | Mother's name |
| address | String | Yes | Home address |
| bblrHistory | String? | No | Birth length/weight history |
| asiEksklusifDuration | int | Yes | Months |
| mpasiStartAge | int | Yes | Months |
| syncStatus | String | Yes | PENDING / SYNCED |
| retryCount | int | Yes | Default 0 |
| createdAt | DateTime | Yes | Record creation timestamp |
| updatedAt | DateTime | Yes | Last modification timestamp |

#### Entity: Measurement — Planned
| Field | Type | Required | Description |
|---|---|---|---|
| id | String | Yes | UUID |
| childId | String | Yes | Foreign key to Balita |
| date | DateTime | Yes | Measurement date |
| tinggiBadan | double | Yes | TB/cm |
| beratBadan | double | Yes | BB/kg |
| lila | double? | No | Lingkar lengan atas (6–59 mo) |
| lingkarKepala | double? | No | Head circumference |
| zScoreTbu | double | Yes | Computed z-score |
| zScoreBbu | double | Yes | Computed z-score |
| zScoreBbtb | double? | No | Computed if applicable |
| syncStatus | String | Yes | PENDING / SYNCED |
| retryCount | int | Yes | Default 0 |

#### Entity: RiskAssessment — Planned
| Field | Type | Required | Description |
|---|---|---|---|
| id | String | Yes | UUID |
| childId | String | Yes | Foreign key to Balita |
| measurementId | String | Yes | Foreign key to Measurement |
| score | double | Yes | Risk score 0–1 |
| category | String | Yes | rendah / sedang / tinggi |
| confidence | double | Yes | Model confidence |
| faceModified | bool | Yes | Whether CV face scan contributed |
| recommendations | List<String> | Yes | List of recommendation IDs |
| createdAt | DateTime | Yes | Timestamp |

### 6.4 AI Model Interface Contracts

#### 8.1 Stunting Risk Model (Ensemble XGBoost + RF → TFLite)
- **Input (14 features)**: `[zscore_tbu, zscore_bbu, zscore_bbtb, lila, usia_bulan, jenis_kelamin, urutan_kelahihan, jarak_kelahiran, riwayat_bblr, durasi_asi_eksklusif, usia_mulai_mpami, pendidikan_ibu, sumber_air_minum, akses_sanitasi]`
- **Output**: `{ skor: float (0–1), kategori: "rendah"|"sedang"|"tinggi", confidence: float }`

#### 8.2 Face CV Model (MobileNetV2)
- **Input**: Cropped face image, preprocessed to model input size.
- **Output**: Feature vector / modifier score — combined into final risk score, never replaces anthropometric score.

#### 8.3 Food Classification Model (EfficientNet-B0)
- **Input**: Food photo.
- **Output**: `{ kategori: string (1/50), confidence: float, estimasi_porsi: float, kalori: float, protein: float, zat_besi: float }`
- **Threshold**: confidence ≥ 0.5 for acceptance; below threshold → manual fallback.

### 6.5 Offline-First Sync Protocol (F-09)

1. **Write**: All data writes persist to local SQLite with `syncStatus = PENDING`, `retryCount = 0`.
2. **Connectivity Detection**: Network callback / connectivity listener triggers `SyncManager`.
3. **Push Phase**: `SyncManager` reads all `PENDING` records, sends via `upsertRecord()` to backend API.
   - Success → `syncStatus = SYNCED`.
   - Failure → exponential backoff: `delay = 2^retryCount * base_delay` (base_delay = 1–2s), `retryCount++`.
4. **Pull Phase**: After push, fetch latest server data by `lastSyncTimestamp`.
   - Conflict resolution: **server-wins**.
5. **Manual Trigger**: Settings → "Paksa Sinkronisasi" button.
6. **Background**: `workmanager` for periodic retry.

---

## 7. UX/UI Guidelines

### 7.1 Visual Design

| Property | Value | Source |
|---|---|---|
| Primary Color | `#1E9E74` (Teal) | `app_colors.dart:4` |
| Primary Light | `#E6F5EE` | `app_colors.dart:5` |
| Secondary | `#34495E` | `app_colors.dart:6` |
| Background | `#F9FAFA` | `app_colors.dart:7` |
| Surface | `#FFFFFF` | `app_colors.dart:8` |
| Error | `#E74C3C` | `app_colors.dart:14` |
| Warning | `#F39C12` | `app_colors.dart:16` |
| Success | `#27AE60` | `app_colors.dart:18` |
| Font | Inter (via `google_fonts`) | `app_theme.dart:3` |
| Material | Material 3 | `app_theme.dart:8` |

### 7.2 Language

- **Bahasa Indonesia only** for v1. No internationalization framework.
- All UI strings, error messages, and recommendations in Indonesian.

### 7.3 Age Scope

- **Supported**: 0–59 months (toddler/infant).
- Input validation must reject ages outside this range.

### 7.4 Medical Disclaimer

Every screen displaying risk detection results **must** show:
> **"Hasil ini bukan diagnosis medis. Konsultasikan dengan tenaga kesehatan untuk keputusan klinis."**

### 7.5 Navigation

- Bottom navigation bar with 4 items + centered FAB:
  1. **Beranda** (home/dashboard)
  2. **Data Anak** (child list)
  3. *(Center gap — FAB)*
  4. **Laporan** (reports/history)
  5. **Profil** (profile/settings)
- FAB triggers "Skrining" action (add child, start new screening).

---

## 8. Constraints & Non-Goals

### 8.1 Hard Constraints (Must Not Violate)

| # | Constraint |
|---|---|
| C-01 | Target platform: **Android API 26+ only**. iOS out of scope for v1. |
| C-02 | Interface language: **Bahasa Indonesia only**. No multi-language in v1. |
| C-03 | Child age scope: **0–59 months only**. Reject out-of-range inputs. |
| C-04 | System output is **risk score + recommendations**, not medical diagnosis. Disclaimer on every result screen. |
| C-05 | Face CV scan (F-05) is **supplementary** — if it fails or is skipped, risk score is still computed from anthropometry alone. |
| C-06 | Food log unrecognized items **must** fall back to **manual input** — no dead ends. |
| C-07 | Minimum assumed local storage: **200MB** (AI model ~80MB downloaded on first login via WiFi). |
| C-08 | **No BPJS/SatuSehat/SIMRS** integration in v1. |
| C-09 | **No feature requires internet** as a hard dependency for F-01–F-08. |
| C-10 | Risk score must **always combine** multiple models — never a single-model decision. |

### 8.2 Non-Goals

- Multi-platform support (iOS, web, desktop) in v1.
- Multi-language support beyond Indonesian.
- Third-party healthcare system integration.
- Real-time collaborative features.
- Parent-facing full application interface (notification summaries only in v1).

---

## 9. Testing & QA

### 9.1 Unit Tests

| Module | Test Cases | Status |
|---|---|---|
| Z-Score Calculator | 11 cases (normal z=0,1,-1; L=0 formula; extreme z>3 & z<-3 corrections; category validation) | ✅ Implemented |
| Sync Logic | Push success, push failure + retry, pull with server-wins conflict | Planned |
| Risk Mapping | Score-to-category mapping for all three risk levels | Planned |

### 9.2 Widget Tests

- LoginPage renders with role selector and OTP flow.
- RegisterPage form validation.
- HomePage dashboard layout (stats, alerts, child cards).

### 9.3 Integration Tests

- Full offline workflow: register child → record measurement → view z-score → assess risk → view recommendations.
- Sync workflow: offline writes → connect to network → verify sync → verify server-wins on conflict.

### 9.4 QA: Troubleshooting Scenarios (Required UI Handling)

| Condition | Required UI Handling |
|---|---|
| Face CV fails / low accuracy | Guidance message (lighting, lens, positioning) + "Lewati Scan Wajah" button |
| Data not syncing | Settings → "Paksa Sinkronisasi" button; display error code if persistent |
| Storage < 200MB before AI download | Proactive warning before model download |
| Food unrecognized by AI | Automatic fallback to manual entry form |
| Forgotten password | Password reset via email (delegated to backend endpoint) |

---

## 10. Definition of Done (v1)

A feature is considered **complete** when **all** of the following are true:

- [ ] Code follows the feature-first Clean Architecture structure (`data/`, `domain/`, `presentation/` separation).
- [ ] `flutter analyze` passes without errors.
- [ ] Unit tests exist for all domain logic (z-score ✅, sync, risk mapping).
- [ ] Features F-01 through F-08 function **100% offline**.
- [ ] Medical disclaimer ("bukan diagnosis medis") is shown on every risk result screen.
- [ ] All UI text is in **Bahasa Indonesia** with consistent **blue-teal** color scheme.
- [ ] AI model wrappers use stable interfaces (replacements don't require app code changes).
- [ ] Offline-first write flow: all writes persist locally first; sync is decoupled.
- [ ] Face CV scan has a visible "Lewati" (skip) option that is non-blocking.
- [ ] Unrecognized food items fall back to manual input.
- [ ] Background sync uses exponential backoff retry.
- [ ] All 10 features (F-01–F-10) are implemented.

---

## 11. Implementation Roadmap

Execution order per `agent.md` §6 — validation gates after each phase:

| Phase | Task | Details | Est. Effort |
|---|---|---|---|
| 1 | **Project Setup** | Initialize Flutter, folder structure, pubspec deps, blue-teal theme | ✅ Partial (theme ✅, deps ✅) |
| 2 | **Core Utilities** | WHO LMS z-score calculator + 11 unit tests | ✅ Complete |
| 3 | **Auth & Registration** | Kader registration, login with OTP stub, Riverpod state | ✅ UI + Provider done |
| 4 | **F-01: Balita Management** | CRUD child profiles, SQLite, search/filter | Planned |
| 5 | **F-02 + F-03: Measurements** | Input forms, validation, z-score integration | z-score ✅ |
| 6 | **F-07: Growth History** | fl_chart graphs with WHO overlays | Planned |
| 7 | **F-04: Risk Detection AI** | TFLite wrapper, 14-feature input, stub output | Stub planned |
| 8 | **F-08: Recommendations** | Rule-based engine from risk + profile | Planned |
| 9 | **F-05: Face CV Scan** | Camera, MobileNetV2, skip button, brightness check | Planned |
| 10 | **F-06: Nutrition Logging** | EfficientNet-B0 food capture, manual fallback | Planned |
| 11 | **F-09: Offline Sync** | SQLite write-first, push/pull, exponential backoff, workmanager | Planned |
| 12 | **F-10: Notifications** | Local reminders, follow-up triggers | Planned |
| 13 | **UI/UX Polish** | Match mockups (blue-teal, Indonesia, child-friendly) | Planned |
| 14 | **QA Pass** | All troubleshooting scenarios handled with clear UI | Planned |

### Validation Gates

After each phase:
1. Run `flutter analyze` — must pass without errors.
2. Run `flutter test` — must pass (unit + widget tests).
3. Verify offline functionality for F-01–F-08.
4. Verify medical disclaimer visibility.

---

## 12. Appendices

### Appendix A: WHO LMS Z-Score Formula Reference

```
If L(t) ≠ 0:
  z = (((y / M(t))^L(t)) - 1) / (L(t) * S(t))

If L(t) = 0:
  z = ln(y / M(t)) / S(t)

Extreme value correction (weight-based indicators only, z > 3):
  SD3pos = M(t) * (1 + L*S*3)^(1/L)
  SD2pos = M(t) * (1 + L*S*2)^(1/L)
  SD23pos = SD3pos - SD2pos
  z* = 3 + (y - SD3pos) / SD23pos

(Analogous formulas for SD3neg / SD23neg when z < -3)
```

### Appendix B: Risk Category Mapping

| Indicator | < -3 | -3 to -2 | ≥ -2 |
|---|---|---|---|
| TB/U (TB-for-age) | severely stunted | stunted | normal |
| BB/U (Weight-for-age) | severely underweight | underweight | normal |
| BB/TB (Weight-for-height) | severely wasted | wasted | normal |

### Appendix C: AI Feature Input Specification

```
Stunting Risk Model Input (14 features, exact order):
[0]  zscore_tbu
[1]  zscore_bbu
[2]  zscore_bbtb
[3]  lila
[4]  usia_bulan
[5]  jenis_kelamin
[6]  urutan_kelahiran
[7]  jarak_kelahiran
[8]  riwayat_bblr
[9]  durasi_asi_eksklusif
[10] usia_mulai_mpami
[11] pendidikan_ibu
[12] sumber_air_minum
[13] akses_sanitasi
```

### Appendix D: File Structure Reference

```
D:\StuntGuard Main\mobile-worktree\
├── prd.md                    ← This document
├── agent.md                  ← Development execution guide
├── pubspec.yaml              ← Dependencies (Riverpod, sqflite, dio, camera, etc.)
├── README.md
├── scaffold.dart             ← Folder structure generator script
├── lib/
│   ├── main.dart            ← Entry point (MyApp → LoginPage)
│   ├── core/
│   │   ├── constants/app_colors.dart  ← Blue-teal palette ✅
│   │   ├── theme/app_theme.dart       ← Material 3 theme ✅
│   │   └── utils/zscore_calculator.dart ✅ (LMS formula, 3 indicators, 11 tests)
│   └── features/
│       ├── auth/                       ✅ UI done, logic stubbed
│       │   ├── domain/entities/user_entity.dart
│       │   └── presentation/
│       │       ├── pages/login_page.dart    ✅
│       │       ├── pages/register_page.dart ✅
│       │       └── providers/auth_provider.dart ✅ (mock)
│       ├── beranda/presentation/pages/    ✅ (home_page.dart, main_screen.dart)
│       └── profil/presentation/pages/    ✅ (profile_page.dart)
├── test/
│   ├── core/utils/zscore_calculator_test.dart ✅ (11 tests)
│   └── widget_test.dart                   (default scaffold, needs updating)
└── android/, ios/, web/, linux/, macos/, windows/ ← Platform runners
```

### Appendix E: Abbreviations

| Abbrev | Meaning |
|---|---|
| TB/U | Tinggi/Panjang Badan menurut Usia |
| BB/U | Berat Badan menurut Usia |
| BB/TB | Berat Badan menurut Tinggi/Panjang Badan |
| LiLA | Lingkar Lengan Atas |
| LMS | Lambda-Mu-Sigma (WHO reference method) |
| CV | Computer Vision |
| MP-ASI | Makanan Pendamping ASI |
| F-01–F-10 | Feature IDs as defined in Section 4 |
| DoD | Definition of Done |
| QA | Quality Assurance |

---

### Appendix F: SQLite DDL Schema & Indexing Strategy (F-01 to F-10)

```sql
-- Table: users (Auth & Profile Kader)
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    nik TEXT,
    phone TEXT NOT NULL,
    posyandu_name TEXT NOT NULL,
    work_area TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'kader',
    created_at TEXT NOT NULL
);

-- Table: balita (F-01 Child Profile)
CREATE TABLE IF NOT EXISTS balita (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    nik TEXT,
    birth_date TEXT NOT NULL,
    gender TEXT NOT NULL CHECK(gender IN ('L', 'P')),
    mother_name TEXT NOT NULL,
    address TEXT NOT NULL,
    bblr_history TEXT CHECK(bblr_history IN ('ya', 'tidak')),
    asi_eksklusif_duration INTEGER NOT NULL DEFAULT 0,
    mpasi_start_age INTEGER NOT NULL DEFAULT 6,
    sync_status TEXT NOT NULL DEFAULT 'PENDING' CHECK(sync_status IN ('PENDING', 'SYNCED', 'ERROR')),
    retry_count INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);

-- Table: pengukuran (F-02 & F-03 Routine Measurements & Z-Scores)
CREATE TABLE IF NOT EXISTS pengukuran (
    id TEXT PRIMARY KEY,
    child_id TEXT NOT NULL,
    date TEXT NOT NULL,
    tinggi_badan REAL NOT NULL,
    berat_badan REAL NOT NULL,
    lila REAL,
    lingkar_kepala REAL,
    z_score_tbu REAL NOT NULL,
    z_score_bbu REAL NOT NULL,
    z_score_bbtb REAL,
    sync_status TEXT NOT NULL DEFAULT 'PENDING' CHECK(sync_status IN ('PENDING', 'SYNCED', 'ERROR')),
    retry_count INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL,
    FOREIGN KEY (child_id) REFERENCES balita(id) ON DELETE CASCADE
);

-- Table: deteksi_risiko (F-04 & F-05 AI Assessment & Face CV)
CREATE TABLE IF NOT EXISTS deteksi_risiko (
    id TEXT PRIMARY KEY,
    child_id TEXT NOT NULL,
    measurement_id TEXT NOT NULL,
    score REAL NOT NULL,
    category TEXT NOT NULL CHECK(category IN ('rendah', 'sedang', 'tinggi')),
    confidence REAL NOT NULL,
    face_modified INTEGER NOT NULL DEFAULT 0,
    recommendations_json TEXT NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (child_id) REFERENCES balita(id) ON DELETE CASCADE,
    FOREIGN KEY (measurement_id) REFERENCES pengukuran(id) ON DELETE CASCADE
);

-- Table: log_nutrisi (F-06 Daily Nutrition Logging)
CREATE TABLE IF NOT EXISTS log_nutrisi (
    id TEXT PRIMARY KEY,
    child_id TEXT NOT NULL,
    date TEXT NOT NULL,
    food_name TEXT NOT NULL,
    category TEXT NOT NULL,
    portion_size REAL NOT NULL DEFAULT 1.0,
    calories REAL NOT NULL DEFAULT 0.0,
    protein REAL NOT NULL DEFAULT 0.0,
    iron REAL NOT NULL DEFAULT 0.0,
    photo_path TEXT,
    is_manual INTEGER NOT NULL DEFAULT 0,
    sync_status TEXT NOT NULL DEFAULT 'PENDING' CHECK(sync_status IN ('PENDING', 'SYNCED', 'ERROR')),
    created_at TEXT NOT NULL,
    FOREIGN KEY (child_id) REFERENCES balita(id) ON DELETE CASCADE
);

-- Table: sync_queue (F-09 Offline Sync Queue Operations)
CREATE TABLE IF NOT EXISTS sync_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    action TEXT NOT NULL CHECK(action IN ('CREATE', 'UPDATE', 'DELETE')),
    payload TEXT NOT NULL,
    retry_count INTEGER NOT NULL DEFAULT 0,
    last_error TEXT,
    created_at TEXT NOT NULL
);

-- Indexes for performance & offline queries
CREATE INDEX IF NOT EXISTS idx_balita_sync ON balita(sync_status);
CREATE INDEX IF NOT EXISTS idx_balita_name ON balita(name);
CREATE INDEX IF NOT EXISTS idx_pengukuran_child ON pengukuran(child_id);
CREATE INDEX IF NOT EXISTS idx_pengukuran_sync ON pengukuran(sync_status);
CREATE INDEX IF NOT EXISTS idx_log_nutrisi_child_date ON log_nutrisi(child_id, date);
CREATE INDEX IF NOT EXISTS idx_sync_queue_retry ON sync_queue(retry_count);
```

---

### Appendix G: Sync Protocol & Backend API Contracts (F-09)

#### G.1 Push Endpoint: `POST /api/v1/sync/push`

- **Headers**: `Authorization: Bearer <token>`, `Content-Type: application/json`
- **Request Body**:
```json
{
  "posyandu_id": "POS-SUKAMAJU-01",
  "device_timestamp": "2026-08-13T23:15:00Z",
  "records": {
    "balita": [
      {
        "id": "uuid-child-01",
        "name": "Budi Santoso",
        "nik": "3201012345670001",
        "birthDate": "2024-05-10",
        "gender": "L",
        "motherName": "Siti Aminah",
        "address": "RT 02 RW 01 Desa Suka Maju",
        "bblrHistory": "tidak",
        "asiEksklusifDuration": 6,
        "mpasiStartAge": 6,
        "updatedAt": "2026-08-13T10:00:00Z"
      }
    ],
    "pengukuran": [
      {
        "id": "uuid-meas-01",
        "childId": "uuid-child-01",
        "date": "2026-08-13",
        "tinggiBadan": 75.5,
        "beratBadan": 9.2,
        "lila": 14.0,
        "lingkarKepala": 44.0,
        "zScoreTbu": -1.2,
        "zScoreBbu": -0.8,
        "zScoreBbtb": -0.5,
        "createdAt": "2026-08-13T10:05:00Z"
      }
    ]
  }
}
```

- **Response (200 OK)**:
```json
{
  "status": "success",
  "synced_ids": {
    "balita": ["uuid-child-01"],
    "pengukuran": ["uuid-meas-01"]
  },
  "conflicts": [],
  "server_timestamp": "2026-08-13T23:15:02Z"
}
```

#### G.2 Pull Endpoint: `GET /api/v1/sync/pull?last_sync_timestamp=2026-08-01T00:00:00Z`

- **Headers**: `Authorization: Bearer <token>`
- **Response (200 OK)**:
```json
{
  "status": "success",
  "server_timestamp": "2026-08-13T23:15:05Z",
  "updates": {
    "balita": [],
    "pengukuran": []
  }
}
```

#### G.3 Conflict Resolution Algorithm (Server-Wins)

```dart
// Pseudo-code implementation inside SyncManager
Future<void> resolveConflicts(List<ServerRecord> serverRecords) async {
  for (final record in serverRecords) {
    final localRecord = await localDb.getRecordById(record.id);
    if (localRecord == null) {
      // Record only exists on server -> insert local
      await localDb.insertRecord(record.toLocalEntity(syncStatus: 'SYNCED'));
    } else if (localRecord.syncStatus == 'PENDING') {
      // Conflict detected! Apply Server-Wins strategy
      await localDb.updateRecord(record.toLocalEntity(syncStatus: 'SYNCED'));
      await logger.logConflictResolved(record.id, strategy: 'SERVER_WINS');
    } else {
      // Local already synced -> overwrite with latest server data
      await localDb.updateRecord(record.toLocalEntity(syncStatus: 'SYNCED'));
    }
  }
}
```

---

### Appendix H: Rule-Based Recommendation Engine Matrix (F-08)

| Code | Age Group | Risk Level | Condition Criteria | Recommended Actions & Guidance (Bahasa Indonesia) |
|---|---|---|---|---|
| R-01 | 0–5 bln | Rendah | zTB/U ≥ -2, ASI Eksklusif | Pertahankan pemberian ASI Eksklusif saja (tanpa makanan/minuman lain) sampai usia 6 bulan. Pantau penimbangan berat badan bulanan di Posyandu. |
| R-02 | 0–5 bln | Sedang / Tinggi | zTB/U < -2 atau BBLR | Prioritas rujukan ke Puskesmas untuk evaluasi laktasi & kesehatan dasar. Edukasi posisi & perlekatan menyusui yang benar. Anjurkan konseling gizi ibu menyusui. |
| R-03 | 6–11 bln | Rendah | zTB/U ≥ -2 | Berikan MPASI adekuat (tekstur lumat/bubur saring), minimal 2–3 kali/hari. Utamakan konsumsi protein hewan lokal (telur, ayam, ikan kembung). ASI tetap diteruskan. |
| R-04 | 6–11 bln | Sedang | -3 ≤ zTB/U < -2 | Tingkatkan porsi protein hewani pada MPASI (misal 1 butir telur/hari + 1 sdm minyak/santan tambahan untuk padat energi). Lakukan penimbangan ulang tiap 2 minggu. |
| R-05 | 6–11 bln | Tinggi | zTB/U < -3 (Severely Stunted) | **Rujukan Cepat Puskesmas/Dokter Anak**. Pemberian PMT (Pemberian Makanan Tambahan) pemulihan berbasis protein hewani. Evaluasi penyakit penyerta (tbc/infeksi cacing). |
| R-06 | 12–23 bln | Rendah | zTB/U ≥ -2 | Berikan MPASI makanan keluarga (tekstur cincang/lembek hingga padat), 3–4 kali makan utama + 1–2 kali selingan sehat. Pantau grafik kurva pertumbuhan WHO. |
| R-07 | 12–23 bln | Sedang | -3 ≤ zTB/U < -2 | Edukasi MPASI kaya Fe & Zinc (hati ayam, daging sapi, ikan). Konseling sanitasi lingkungan & cuci tangan pakai sabun (CTPS) untuk cegah diare berulang. |
| R-08 | 12–23 bln | Tinggi | zTB/U < -3 | **Rujukan Puskesmas & Intervensi PMT Lokal/Pabrikan**. Dampingi kader kunjungan rumah bulanan (home visit) & penyuluhan porsi makan balita. |
| R-09 | 24–59 bln | Rendah | zTB/U ≥ -2 | Lanjutkan pola makan gizi seimbang (makanan keluarga). Pastikan anak mendapatkan suplemen Vitamin A kapsul biru/merah & imunisasi rutin lengkap. |
| R-10 | 24–59 bln | Sedang / Tinggi | zTB/U < -2 atau BB/TB < -2 | Screening faktor lingkungan (akses air bersih & jamban sehat). Anjurkan pemberian sediaan multivitamin/zat besi sesuai anjuran Nakes Puskesmas. |

---

### Appendix I: AI Model Specs & Feature Encodings (F-04, F-05, F-06)

#### I.1 Stunting Risk Model Feature Encodings (14 Vector Inputs)

| Index | Feature Key | Data Type | Range / Encoding Map |
|---|---|---|---|
| `[0]` | `zscore_tbu` | float | Continuous z-score value (e.g. -2.45) |
| `[1]` | `zscore_bbu` | float | Continuous z-score value (e.g. -1.10) |
| `[2]` | `zscore_bbtb` | float | Continuous z-score value (e.g. -0.50) |
| `[3]` | `lila` | float | Circumference in cm (e.g. 13.5) |
| `[4]` | `usia_bulan` | float | Integer 0 to 59 |
| `[5]` | `jenis_kelamin` | float | `0.0` = Laki-laki, `1.0` = Perempuan |
| `[6]` | `urutan_kelahiran` | float | Integer 1, 2, 3, ... |
| `[7]` | `jarak_kelahiran` | float | Months since previous child (`0.0` if firstborn) |
| `[8]` | `riwayat_bblr` | float | `0.0` = Tidak, `1.0` = Ya (BB lahir < 2500g) |
| `[9]` | `durasi_asi_eksklusif` | float | Months 0 to 6 |
| `[10]`| `usia_mulai_mpasi` | float | Months (normally 6) |
| `[11]`| `pendidikan_ibu` | float | `0.0` = SD/Sederajat, `1.0` = SMP, `2.0` = SMA, `3.0` = Perguruan Tinggi |
| `[12]`| `sumber_air_minum` | float | `0.0` = Terlindung/Perpipaan, `1.0` = Tidak Terlindung/Sumur Gali/Sungai |
| `[13]`| `akses_sanitasi` | float | `0.0` = Layak/Jamban Sendiri, `1.0` = Tidak Layak/Jamban Bersama |

#### I.2 Face CV Model Preprocessing & Brightness Check (MobileNetV2)

1. **Bounding Box Detection**: Face location detection using lightweight BlazeFace TFLite.
2. **Crop & Resize**: Crop face area with 15% margin padding; resize to `224 x 224` pixels.
3. **Color Space**: RGB normalized to floating point array: `input[i] = (pixel[i] / 127.5) - 1.0`.
4. **Luminance Check**:
   $$\text{Luminance } Y = 0.299 \times R + 0.587 \times G + 0.114 \times B$$
   - If average \(Y < 40\): Display prompt *"Cahaya terlalu gelap. Pindahkan balita ke tempat lebih terang."*
   - If average \(Y > 220\): Display prompt *"Cahaya terlalu silau. Hindari sorotan lampu langsung."*

#### I.3 Food Classification Model Categories (50 MPASI & Local Categories)

Top local food categories supported by EfficientNet-B0:
1. `bubur_saring_hati_ayam`
2. `nasi_tim_telur_sayur`
3. `sup_ikan_kembung`
4. `bubur_kacang_hijau`
5. `pisang_lumat`
6. `nasi_putih`
7. `telur_rebus`
8. `tempe_goreng`
9. `tahu_kukus`
10. `sup_kelor_daging`
... (50 categories total covering Indonesian MPASI guidelines).

**Fallback Trigger Rule**:
```dart
if (topConfidence < 0.50) {
  // Trigger manual food entry modal directly
  navigator.push(ManualFoodEntryPage(initialQuery: topClassLabel));
}
```

---

### Appendix J: Troubleshooting & Edge Cases Playbook

| Scenario | Symptom / Trigger | Technical Recovery Mechanism | UI & User Action |
|---|---|---|---|
| Low Storage Capacity | Available device storage < 200MB prior to model download | Check `disk_space` plugin before triggering TFLite load | Show dialog: "Penyimpanan HP hampir penuh (<200MB). Hapus file tidak terpakai agar AI berjalan optimal." |
| TFLite Model Loading Error | Native C++ lib error or model file corrupt | Catch `PlatformException`; fallback to Rule-Based Anthropometric Scoring | Show warning banner: "Deteksi AI tidak tersedia sementara. Menggunakan skor antropometri standar WHO." |
| Database Corruption | `DatabaseException: database disk image is malformed` | Rename corrupt DB to `.bak`; instantiate clean SQLite DB schema | Prompt user: "Terjadi kesalahan basis data lokal. Sistem akan memulihkan data dari server saat terhubung internet." |
| Prolonged Offline State | No sync for > 30 days | Count un-synced items in `sync_queue` table | Show warning badge on Settings & Dashboard: "Ada [X] data belum tersimpan ke server selama lebih dari 30 hari." |
| Camera Permission Denied | User selected "Don't allow" when opening Face CV / Food Scan | Intercept `permission_handler` state `PermissionStatus.permanentlyDenied` | Display dialog with button "Buka Pengaturan HP" directly linking to App Info settings. |

---

### Appendix K: Security, Privacy & Local Storage Protection

1. **On-Device Data Encryption**:
   - SQLite database encrypted using **SQLCipher** (`sqflite_sqlcipher`) with key stored securely in Android Keystore via `flutter_secure_storage`.
2. **Data Privacy & Anonymization**:
   - Balita NIK and exact home addresses are encrypted at rest.
   - When exporting analytical data or telemetry, NIK is hashed via SHA-256 with a salt.
3. **Session Auto-Lock Policy**:
   - Inactivity timer of **15 minutes** triggers auto-lock, requiring the cadre to re-enter their 4-digit PIN or biometrics before viewing child growth records.

