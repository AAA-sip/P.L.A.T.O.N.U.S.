# AGENTS.md

Flutter-клиент «Platonus Helper» — свой студенческий клиент для
`https://platonus.iitu.edu.kz` (система Платонус, университет пользователя).

## Проект

- Flutter, `sdk: ^3.13.1`, Material 3, светлая/тёмная тема.
- Собрано с нуля. Цель — простой студенческий клиент: логин, профиль,
  расписание, оценки (журнал), задачи. Без мусора супераппа Aitu.

## Структура

- `lib/config.dart` — чтение `.env` (`flutter_dotenv`), заголовки запросов.
- `lib/services/platonus_client.dart` — Dio-клиент всех API (мобильный REST + веб-академия).
- `lib/services/auth_repository.dart` — `ChangeNotifier` (Provider): состояние
  авторизации, профиль, расписание, задачи, журнал.
- `lib/services/logging_interceptor.dart` — логирует запросы, маскирует
  `password`/`token`.
- `lib/models/` — DTO. `lib/screens/` — экраны.
- `lib/app.dart` — go_router + Provider.

## Документация

- `docs/api-contract.md` — рабочий API-контракт (кратко).
- `docs/API_DOCUMENTATION.md` — мобильный REST из декомпиля кз.rmnk.platonushelper.
- `docs/research/` — реверс-инжиниринг APK (README + 11 файлов, из `Platonus_Research`).
- `docs/research/11_веб_академия_api.md` — веб-академия (задачи, журнал, план).

## Команды

- `flutter analyze` — статический анализ (обязательно после изменений).
- `flutter test` — тесты.
- `flutter run` — запуск (после изменений делай hot reload / hot restart).

## Правила

- Секреты ТОЛЬКО в `.env` (gitignored); ИИН/пароль/токен не логировать.
- Не подключать сторонние сервисы; прямой API работает напрямую.
- Новая фича: model → метод в `PlatonusClient` → метод в `AuthRepository` →
  экран → вкладка в `HomeScreen` (bottom nav) + маршрут в `app.dart`.
- Без лишних комментариев в коде.

## Данные (для live-проверок)

- `token` — заголовок для авторизованных запросов (uuid из логина).
- Пример id студента (учёбный): `44764`; год/семестр журнала: `2026/1`.
- Университет: ИИТУ (iitu.edu.kz).