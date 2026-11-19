# static-jinja-plus-port

[![Docker Pulls](https://img.shields.io/docker/pulls/kislyakow/static-jinja-plus?logo=docker&label=pulls)](https://hub.docker.com/r/kislyakow/static-jinja-plus)
[![Ubuntu image](https://img.shields.io/docker/image-size/kislyakow/static-jinja-plus/latest?logo=docker&label=ubuntu%20image)](https://hub.docker.com/r/kislyakow/static-jinja-plus/tags)
[![StaticJinjaPlus](https://img.shields.io/badge/StaticJinjaPlus-0.1.1-orange)](https://github.com/MrDave/StaticJinjaPlus/tags)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/skislyakow/static-jinja-plus-port?logo=github)](https://github.com/skislyakow/static-jinja-plus-port/commits/main)

Docker-порт [StaticJinjaPlus](https://github.com/MrDave/StaticJinjaPlus) — набора инструментов для генерации статических HTML-сайтов из Jinja2-шаблонов. Готовые образы публикуются на [Docker Hub](https://hub.docker.com/r/kislyakow/static-jinja-plus).

Этот репозиторий содержит только инструменты для сборки Docker-образов:

- `Dockerfile` — образ на базе `ubuntu:26.04`
- `Dockerfile.slim` — образ на базе `python:3.14-slim`

Исходники StaticJinjaPlus в порт **не включены** — они скачиваются при сборке прямо из репозитория автора ПО. Это позволяет собирать образы новых версий по мере их выхода, не обновляя форк.

## Требования

- Docker (не ниже 20.10 — нужен BuildKit)
- (опционально) учётная запись на [Docker Hub](https://hub.docker.com) для публикации образов

## Сборка образов

### Ubuntu (`Dockerfile`)

По умолчанию собирается последняя стабильная версия `0.1.1`:

```bash
docker build -t kislyakow/static-jinja-plus:latest .
```

### Python-slim (`Dockerfile.slim`)

```bash
docker build -f Dockerfile.slim -t kislyakow/static-jinja-plus:slim .
```

## Выбор версии StaticJinjaPlus

Источник кода задаётся аргументом сборки `SJP_REF` (полный ref в репозитории автора: `refs/tags/...` для версии или `refs/heads/...` для ветки), а целостность архива проверяется хешем `SJP_SHA256` (значение `none` отключает проверку).

Собирать можно любую версию, существующую как тег в https://github.com/MrDave/StaticJinjaPlus:

```bash
docker build \
  --build-arg SJP_REF=refs/tags/0.1.0 \
  --build-arg SJP_SHA256=3555bcfd670e134e8360ad934cb5bad1bbe2a7dad24ba7cafa0a3bb8b23c6444 \
  -t kislyakow/static-jinja-plus:0.1.0 .
```

Аналогично для slim-варианта:

```bash
docker build -f Dockerfile.slim \
  --build-arg SJP_REF=refs/tags/0.1.0 \
  --build-arg SJP_SHA256=3555bcfd670e134e8360ad934cb5bad1bbe2a7dad24ba7cafa0a3bb8b23c6444 \
  -t kislyakow/static-jinja-plus:0.1.0-slim .
```

### Параметры сборки

| Аргумент | Назначение | Значение по умолчанию |
|---|---|---|
| `SJP_REF` | Полный ref в репозитории автора | `refs/tags/0.1.1` |
| `SJP_SHA256` | SHA-256 архива этого ref (нижний регистр); `none` — без проверки | хеш архива `0.1.1` |

### Как посчитать SHA256 для новой версии

```bash
curl -L -o sjp.tar.gz https://codeload.github.com/MrDave/StaticJinjaPlus/tar.gz/refs/tags/<НОВАЯ-ВЕРСИЯ>
sha256sum sjp.tar.gz
```

> Проверка хеша теряет смысл, если `SJP_SHA256` не соответствует выбранному `SJP_REF`: сборка упадёт. Хеш менять не нужно только когда собираете тот ref, для которого он уже актуален.

### Сборка из ветки (продвинутый вариант)

Чтобы собрать незарелиженную версию из основной ветки `main` (например, для проверки свежего фикса бага):

```bash
docker build --build-arg SJP_REF=refs/heads/main --build-arg SJP_SHA256=none -t kislyakow/static-jinja-plus:develop .
```

Здесь `SJP_SHA256=none` отключает проверку — у ветки нет стабильного хеша.

## Запуск образа

Шаблоны не вшиты в образ: генератор ищет их в каталоге `./templates` внутри контейнера. Передайте свою папку с шаблонами через volume:

```bash
docker run --rm \
  -v /путь/к/моим/шаблонам:/opt/StaticJinjaPlus/templates \
  kislyakow/static-jinja-plus:latest
```

В консоли появятся строки `Rendering index.html...` и т.п., готовые страницы окажутся в `/opt/StaticJinjaPlus/build`.

Чтобы забрать результат рендера на хост:

```bash
docker run --rm \
  -v /путь/к/моим/шаблонам:/opt/StaticJinjaPlus/templates \
  -v /путь/к/выводу:/opt/StaticJinjaPlus/build \
  kislyakow/static-jinja-plus:latest
```

Справка по CLI:

```bash
docker run --rm kislyakow/static-jinja-plus:latest --help
docker run --rm kislyakow/static-jinja-plus:slim python main.py --help
```

## Публикация на Docker Hub

```bash
docker login
docker push kislyakow/static-jinja-plus:latest
docker push kislyakow/static-jinja-plus:slim
# и так для остальных собранных тегов
```

## Ubuntu или python-slim?

| Базовый образ | Итоговый образ (compressed) | Когда выбирать |
|---|---|---|
| `ubuntu:26.04` | ~68 MB | Если в образ нужен дополнительный софт из apt |
| `python:3.14-slim` | ~48 MB | Для минимального размера: только Python + зависимости |

Slim-образ заметно меньше и обычно достаточен для запуска генератора. Ubuntu-вариант удобнее, когда вы хотите доустанавливать пакеты в контейнер.

## Как устроен Dockerfile

1. Образ строится на зафиксированной версии базового образа (`ubuntu:26.04` / `python:3.14-slim`).
2. Архив исходников скачивается через `ADD` — без `git clone`, по указанному ref (`refs/tags/...` или `refs/heads/...`). Целостность проверяется `sha256sum -c`; `SJP_SHA256=none` пропускает проверку (нужно для веток).
3. Распаковывается в `/opt/StaticJinjaPlus` (`tar --strip-components=1`).
4. Для ubuntu зависимости ставятся в виртуальное окружение `/opt/venv` (системный pip заблокирован политикой PEP 668); для python-slim — напрямую системным pip.
5. Кэш apt и распакованный архив удаляются, чтобы не раздувать образ.

## Лицензия

Проект распространяется по [MIT-лицензии](LICENSE). Исходный код StaticJinjaPlus — © 2024 David Schnoll, [также под MIT](https://github.com/MrDave/StaticJinjaPlus/blob/main/LICENSE). Файлы порта (Dockerfile-ы и документация) — © 2026 skislyakow.