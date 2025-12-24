# CLAUDE.md - Work21 Deploy

## Обзор проекта

**Work21 Deploy** — конфигурация для деплоя всего стека Work21 на VPS с использованием Docker Compose.

## Архитектура

```
┌─────────────────────────────────────────────────────────┐
│                      VPS Server                          │
│  ┌─────────────────────────────────────────────────────┐│
│  │                    Nginx (:80/:443)                 ││
│  │         Reverse Proxy + SSL Termination             ││
│  └───────────────┬───────────────┬─────────────────────┘│
│                  │               │                       │
│         /api/*   │      /agent/* │                       │
│                  ▼               ▼                       │
│  ┌───────────────────┐  ┌───────────────────┐           │
│  │   Backend (:8000) │  │   Agent (:8080)   │           │
│  │      FastAPI      │  │     FastAPI       │           │
│  └─────────┬─────────┘  │    (GigaChat)     │           │
│            │            └───────────────────┘           │
│            ▼                                             │
│  ┌───────────────────┐                                  │
│  │  PostgreSQL (:5432)│                                  │
│  └───────────────────┘                                  │
└─────────────────────────────────────────────────────────┘
```

## Структура проекта

```
work21-deploy/
├── docker-compose.yml      # Оркестрация всех сервисов
├── nginx/
│   └── nginx.conf          # Конфигурация Nginx
├── .env                    # Переменные окружения (не в Git!)
├── .env.example            # Пример переменных
├── deploy.sh               # Скрипт деплоя
├── backend/                # Клон work21-backend (gitignore)
└── agent/                  # Клон work21-agent (gitignore)
```

## Сервисы Docker Compose

| Сервис | Образ | Порты | Описание |
|--------|-------|-------|----------|
| `db` | postgres:15-alpine | 5432 | База данных |
| `backend` | build ./backend | 8000 | FastAPI backend |
| `agent` | build ./agent | 8080 | AI агент |
| `nginx` | nginx:alpine | 80, 443 | Reverse proxy |

## Быстрый старт на VPS

```bash
# 1. Клонировать репозиторий
git clone https://github.com/ChargeOnTop/work21-deploy.git
cd work21-deploy

# 2. Клонировать сервисы
git clone https://github.com/oinuritto/work21-backend.git backend
git clone https://github.com/Daimnedope/work21-agents.git agent
git clone https://github.com/Daimnedope/work21-admins.git admin

# 3. Настроить переменные
cp .env.example .env
nano .env  # Заполнить значения

# 4. Запустить
docker compose up -d --build
```

## Переменные окружения (.env)

```env
# PostgreSQL
POSTGRES_USER=work21
POSTGRES_PASSWORD=сгенерировать_надёжный_пароль
POSTGRES_DB=work21

# Backend
SECRET_KEY=сгенерировать_openssl_rand_hex_32
DATABASE_URL=postgresql://work21:пароль@db:5432/work21

# AI Agent
GIGACHAT_CREDENTIALS=ваш_base64_ключ
GIGACHAT_MODEL=GigaChat-Pro

# Domain (для SSL)
DOMAIN=work-21.com
```

## Команды управления

```bash
# Статус сервисов
docker compose ps

# Логи всех сервисов
docker compose logs -f

# Логи конкретного сервиса
docker compose logs -f backend
docker compose logs -f agent
docker compose logs -f nginx

# Перезапуск сервиса
docker compose restart backend

# Полный перезапуск
docker compose down
docker compose up -d

# Пересборка после изменений кода
docker compose up -d --build backend
docker compose up -d --build agent

# Обновление из Git
cd backend && git pull && cd ..
cd agent && git pull && cd ..
docker compose up -d --build
```

## Nginx роутинг

| Путь | Направление | Описание |
|------|-------------|----------|
| `/api/*` | backend:8000 | Backend API |
| `/agent/*` | agent:8080 | AI Agent API |
| `/docs` | backend:8000 | Swagger UI |
| `/health` | backend:8000 | Health check |

## SSL (HTTPS)

Для Cloudflare (рекомендуется):
1. Добавить A-запись: `api.work-21.com` → IP сервера
2. Включить Proxy (оранжевое облако)
3. SSL/TLS → Full

## Мониторинг

```bash
# Проверка здоровья
curl http://localhost/health
curl http://localhost/agent/api/v1/llm/health

# Использование ресурсов
docker stats
```

## Бэкап базы данных

```bash
# Создать бэкап
docker compose exec db pg_dump -U work21 work21 > backup.sql

# Восстановить
cat backup.sql | docker compose exec -T db psql -U work21 work21
```

## Связанные репозитории

- **Backend:** https://github.com/oinuritto/work21-backend
- **AI Agent:** https://github.com/Daimnedope/work21-agents
- **Admin Panel:** https://github.com/Daimnedope/work21-admins
- **Frontend:** https://github.com/ChargeOnTop/work21-fr

## Production URLs

| Сервис | URL |
|--------|-----|
| Backend API | https://api.work-21.com/api/v1/ |
| AI Agent | https://api.work-21.com/agent/api/v1/ |
| Swagger | https://api.work-21.com/docs |
| Frontend | https://ift-1.brojs.ru/work21-fr |


