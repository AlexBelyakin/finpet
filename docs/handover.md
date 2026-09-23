# Сборка, разрешения, тесты, лицензии

Закрывает ТЗ 5.1–5.4 и 5.9–5.12. Карточка RuStore и свой keystore — отдельно, не здесь.

## 5.1–5.4 Окружение и сборка APK

Нужны Android Studio, Android SDK, эмулятор API 26+, Flutter (`flutter doctor` без ошибок по Android).

Открывать корень `finpet`, не только `android/`.

```powershell
flutter pub get
flutter test
flutter run -d <id>
```

Сборка APK на диск (в git не кладётся, `*.apk` в ignore):

```powershell
flutter build apk --debug
```

Файл: `build/app/outputs/flutter-apk/app-debug.apk`. Debug-сборка 23.09.2026 была около 530 МБ из‑за 15+15 GLB.

```powershell
flutter build apk --release
```

Сейчас `release` в `android/app/build.gradle.kts` ещё берёт **debug-подпись**. Такой APK ставится на эмулятор и телефон для проверки. В магазин его не грузить.

Когда появится свой `.jks` (не в git): прописать `signingConfigs.release` и сменить `applicationId` с `com.example.finpet`. Пока пакет учебный.

Версия в `pubspec.yaml`: `1.0.0+1` (`versionName` / `versionCode`).

Архитектура и структура данных — README, раздел «Архитектура». Профиль: JSON `finni_profile_v1` в `SharedPreferences`. Секретов в репозитории нет: нет `.env`, нет keystore, `key.properties` в `android/.gitignore`.

## 5.9 Разрешения и удаление данных

Разрешение в манифесте одно: `android.permission.INTERNET`. Нужно локальному HTTP, с которого WebView читает GLB. Камеры, геолокации, контактов, микрофона нет.

Профиль только на устройстве. Почту и телефон приложение не просит.

Удалить прогресс:

1. Дом → меню → «Новый питомец» (сброс монет, заданий, копилки, локации).
2. «Взрослым» → пример `8 + 5 = 13` → «Сбросить тестовый профиль».
3. Очистка данных приложения в настройках Android.

После сброса снова приветствие и создание персонажа.

## 5.10 Тест-кейсы и отчёт с устройства

Автотесты на `Alex` (команда `flutter test`):

| Файл | Сколько | Как гоняется |
|---|---|---|
| `test/economy_test.dart` | 10 | Чистый Dart, без UI: план, покупка, минус, неделя, шкалы, мини-игра |
| `test/catalog_test.dart` | 2 | Размер магазина и сетка заданий |
| `test/place_test.dart` | 6 | Часы, локации, контроллер смены места |
| `test/pet_clips_test.dart` | 10 | Idle, цвета, подсказки, похвала |
| `test/game_controller_clip_test.dart` | 1 | Очередь клипа до возврата на дом |
| `test/widget_test.dart` | 2 | `pumpWidget(FinniApp)`: приветствие; планшет 2560×1600 |

Подробная привязка пункта ТЗ к кейсу — в [tz-matrix.md](tz-matrix.md).

Ручной прогон на `Alex`: эмулятор Android, создание персонажа (тело, цвет, имя), дом, задания, магазин после правок UI. Живой WebView в автотестах не поднимается.

На ветке `Ilya` (не влита в `Alex`):

- `qa/test_cases.md` — 50 ручных кейсов (запуск, локация, дом, план, задания, покупки, копилка, прогресс, мини-игры, служебное).
- Устройство: эмулятор Pixel 6a, API 37.
- Почти все Pass. Открытые Fail: нет явного текста «максимум» в одном сценарии после 80 монет мини-игр; клип стадии при закрытии недели.
- `qa/reports/final_report.md` фиксирует `flutter test` зелёным на тогдашних 28 кейсах.

Отдельного прогона на физическом телефоне в `Alex` нет. Планшет проверен виджетом (кнопка «Играть!») и ручными правками вёрстки.

## 5.11 Ограничения прототипа

- Пакет `com.example.finpet`, релиз без своего keystore.
- Debug APK тяжёлый (~530 МБ), GLB не сжаты под магазин.
- Неделя закрывается демо-кнопкой, не календарём.
- Нет режима «меньше движения».
- Стык разового GLB и idle может дёрнуться: клипы в разных файлах.
- 3D на web — stub.
- iOS-папка есть, сдача — Android.
- QA-папка Ильи живёт на `origin/Ilya`.

## 5.12 Лицензии ассетов

| Ассет | Лицензия | Где |
|---|---|---|
| Golos UI | SIL OFL 1.1, ParaType, Reserved Font Name «Golos UI» | `assets/fonts/OFL-Golos-UI.txt` |
| PT Root UI | SIL OFL 1.1, ParaType | `assets/fonts/OFL-PT-Root-UI.txt` |
| Material Icons | Apache 2.0 (пакет Flutter) | зависимости SDK |
| Cupertino Icons | пакет `cupertino_icons` | pub |
| model-viewer | пакет `model_viewer_plus` | `packages/model_viewer_plus` |
| Треки `track_1.mp3`, `track_2.mp3` | фоновая музыка проекта, только в этом приложении | `assets/audio/` |
| JPEG комнат и заставки | арты проекта | `assets/images/` |
| GLB Финни и Нори | модели для этого прототипа (Meshy + риг Mixamo), не для отдельной продажи | `assets/models/finni/`, `nori/` |

Шрифты OFL можно встраивать в приложение. Нельзя продавать сами файлы шрифтов и нельзя выпускать производный шрифт под зарезервированным именем.
