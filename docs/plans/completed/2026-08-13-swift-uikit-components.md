# План разработки `swift-uikit-components`

Добавить в категорию Apple development самостоятельный Codex-скилл для
проектирования, реализации, ревью и диагностики UIKit-компонентов. Скилл должен
давать современный, source-first маршрут по UIKit, не дублировать глубокие
специализированные скиллы и не выдавать непроверенные runtime-утверждения.

- Mode: compact
- Status: completed
- Saved plan: `docs/plans/completed/2026-08-13-swift-uikit-components.md`

## Task intake

- Goal: создать `skills/apple-development/swift-uikit-components`, добавить его
  в каталог репозитория и опубликовать ready-for-review PR.
- Context: отдельная worktree
  `/Users/kirchberg/.codex/worktrees/swift-uikit-components` создана от свежего
  `origin/main` на ветке `codex/swift-uikit-components`; пользователь приложил
  исследование UIKit и набор источников.
- Constraints: сохранить чужие изменения в исходной checkout; следовать
  progressive disclosure; frontmatter содержит только `name` и `description`;
  использовать актуальные первичные Apple-источники для version-sensitive
  рекомендаций; PR не должен быть Draft.
- Done when: структура скилла, metadata, references и checker согласованы;
  `quick_validate.py`, локальный checker, install smoke и независимый
  forward-test проходят; README обновлён; ветка закоммичена, отправлена и имеет
  открытый ready PR в `main`.

## Scope

In scope:

- [x] Создать source-backed workflow для UIKit views, controls, configuration,
  layout/adaptivity, view-controller composition, presentation, SwiftUI
  interoperability, accessibility и проверки.
- [x] Добавить `agents/openai.yaml`, тематические references,
  `scripts/check_skill.sh` и README-каталог.
- [x] Проверить и опубликовать изменения отдельным PR.

Out of scope:

- Изменение Swift-кода приложения или создание runnable UIKit-примера.
- Глубокое дублирование специализированных performance, animation,
  concurrency, RTL, accessibility и product-design скиллов.
- Изменение незакоммиченного `swift-uikit-collections-performance` в исходной
  checkout.

## Assumptions

- Deployment target и UI requirements всегда берутся из целевого проекта, а
  не фиксируются этим скиллом.
- Устаревшие API допустимы только для существующего кода или совместимости;
  новый код начинает с поддерживаемых системных UIKit API.

## Execution rules

- Выполнять действия по одному и фиксировать фактический результат.
- Отмечать `[x]` только после реализации и успешной проверки.
- Исправлять релевантные сбои и повторять затронутые проверки.
- Классифицировать недоступные или нерелевантные проверки честно.
- План не расширяет разрешения за пределы запроса пользователя.

## Actions

### 1. Зафиксировать архитектуру и источник истины

- Expected: определены границы скилла, маршрутизация references и актуальные
  Apple-источники без зависимости от неподтверждённых API.
- [x] Сопоставить исследование пользователя с официальными источниками и
  соседними скиллами.
- [x] Выбрать минимальный набор reference-файлов и проверяемые guardrails.
- Check: inspect existing skills; verify selected Apple pages; review planned
  trigger and routing language.
- Evidence: исследование сопоставлено с текущими соседними скиллами; 42
  канонических Apple URL проверены с HTTP 200; WWDC26 помечен как prerelease и
  availability-gated; исключены числовые рейтинги и универсальная миграция
  `UITableView` в `UICollectionView`.

### 2. Создать и наполнить скилл

- Expected: `swift-uikit-components` имеет валидный `SKILL.md`, metadata,
  selective references и executable checker без placeholder-текста.
- [x] Инициализировать папку официальным `init_skill.py`.
- [x] Написать workflow, references, metadata и checker через `apply_patch`.
- Check: `quick_validate.py` и `scripts/check_skill.sh`.
- Evidence: `quick_validate.py` сообщил `Skill is valid!`; bespoke checker
  сообщил `swift-uikit-components check passed`; все 13 Apple skill checker'ов
  прошли после независимого review-исправления freshness-проверки источников.

### 3. Интегрировать и проверить использование

- Expected: README отражает новый скилл, named install работает, а свежий агент
  может применить скилл к реалистичной UIKit-задаче.
- [x] Обновить overview, layout, install example и детальный раздел README.
- [x] Выполнить install smoke и независимые forward-test/review проходы.
- Check: README link inspection, isolated install check, subagent outputs.
- Evidence: named install в изолированную директорию завершился с
  `check swift-uikit-components: ok`; два свежих forward-test прохода корректно
  применили component/reuse workflow и отделили измерение hitch'ей; независимый
  final review нашёл один medium validator gap, который исправлен и перепроверен.

### 4. Опубликовать ready PR

- Expected: чистая ветка содержит только заявленный scope и открытый не-Draft
  PR в `main`.
- [x] Проверить diff, закоммитить точные файлы и push с tracking.
- [x] Открыть PR с описанием изменений и фактических проверок.
- Check: `git status -sb`, `git diff --check`, `gh pr view --json isDraft,state`.
- Evidence: commit `de05724` отправлен в
  `origin/codex/swift-uikit-components`; PR #16 открыт в `main`, `state=OPEN`,
  `isDraft=false`.

## Validation and quality gate

- [x] Структурная и семантическая валидация скилла проходит.
- [x] Named install в изолированную временную директорию проходит post-install
  checker.
- [x] Независимый forward-test правильно маршрутизирует UIKit-задачу и не
  подменяет доказательства заявлениями о runtime-качестве.
- [x] В diff нет чужих изменений, placeholder-текста и битых внутренних ссылок.
- [x] Done when доказан без релевантной регрессии.

Если gate не проходит, оставить затронутый пункт незавершённым, применить
минимальное исправление и повторить проверку.

## Subagent strategy

- Mode: read-only exploration и parallel verification.
- Ownership: explorers исследуют conventions/scope; свежий агент выполняет
  forward-test по готовому артефакту; основной агент владеет файлами,
  интеграцией, git и PR.

## Risks and recovery

- Version-sensitive API: сверять availability с Apple docs/SDK и требовать
  fallback; при сомнении не фиксировать версию как факт.
- Пересечение со специализированными скиллами: оставить UIKit component
  ownership здесь, а глубокую performance/concurrency/animation работу явно
  маршрутизировать.
- README-конфликт с параллельной веткой: PR основан строго на `origin/main`;
  при будущем rebase разрешать только фактический конфликт каталога.

## Final Definition of Done

- [x] Все in-scope действия и проверки завершены.
- [x] Релевантные регрессии исправлены и перепроверены.
- [x] Неразрешённые проверки и риски явно отражены; нерешённых проверок нет.
- [x] План перенесён в `docs/plans/completed/` со статусом `completed`.
- [x] Ready PR открыт в `main`.
