# 🚀 WORK21 Deploy

Единый деплой-конфиг для запуска всего стека WORK21 на VPS.

## Архитектура

```
┌──────────────────────────────────────────────────────────────────┐
│                         VPS Server (217.60.0.86)                  │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐   │
│  │                   Nginx (:80, :443)                        │   │
│  │              Reverse Proxy + SSL + CORS                    │   │
│  └─────┬─────────────────┬────────────────────┬──────────────┘   │
│        │                 │                    │                   │
│   api.work-21.com   api.work-21.com     admin.work-21.com        │
│      /api/*           /agent/*               /*                   │
│        │                 │                    │                   │
│  ┌─────▼──────┐   ┌──────▼───────┐   ┌───────▼─────────┐        │
│  │  Backend   │   │   AI Agent   │   │   Admin Panel   │        │
│  │  FastAPI   │   │   FastAPI    │   │   React+Refine  │        │
│  │   :8000    │   │    :8080     │   │      :80        │        │
│  │ PostgreSQL │   │   GigaChat   │   │                 │        │
│  └────────────┘   └──────────────┘   └─────────────────┘        │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘

Frontend: work-21.com (BroJS Platform)
```

## Быстрый старт

### 1. На VPS (Ubuntu 22.04)

```bash
# Клонируем деплой-конфиг
git clone https://github.com/ChargeOnTop/work21-deploy.git
cd work21-deploy

# Настраиваем переменные
cp .env.example .env
nano .env
```

### 2. Заполните .env

```bash
POSTGRES_PASSWORD=ВашСильныйПароль123!
SECRET_KEY=сгенерируйте_openssl_rand_hex_32
GIGACHAT_API_KEY=ваш_ключ_от_sber
VITE_API_URL=https://api.work-21.com/api/v1
```

### 3. Запуск

```bash
chmod +x deploy.sh
./deploy.sh
```

### 4. Создание администратора (первый запуск)

```bash
docker exec -it work21-backend python scripts/create_admin.py
```

Будет создан админ: `admin@work21.ru` / `SecureAdminPass123!`

### 5. Проверка

```bash
# Health check
curl https://api.work-21.com/health

# Backend API
curl https://api.work-21.com/api/v1/

# Agent API
curl https://api.work-21.com/agent/api/v1/llm/health

# Admin Panel
open https://admin.work-21.com
```

## Структура проекта

```
work21-deploy/
├── docker-compose.yml    # Главный конфиг
├── nginx/
│   └── nginx.conf        # Конфигурация Nginx
├── .env.example          # Пример переменных
├── deploy.sh             # Скрипт деплоя
├── update.sh             # Скрипт обновления
├── backend/              # (клонируется автоматически)
├── agent/                # (клонируется автоматически)
└── admin/                # (клонируется автоматически)
```

## Команды

```bash
# Запуск
docker compose up -d

# Остановка
docker compose down

# Логи всех сервисов
docker compose logs -f

# Логи конкретного сервиса
docker compose logs -f backend
docker compose logs -f agent
docker compose logs -f admin
docker compose logs -f nginx

# Перезапуск
docker compose restart

# Обновление кода
./update.sh

# Статус
docker compose ps
```

## DNS настройки (Cloudflare)

| Type | Name | Content | Proxy |
|------|------|---------|-------|
| A | api | 217.60.0.86 | ☁️ Proxied |
| A | admin | 217.60.0.86 | ☁️ Proxied |
| A | @ | (BroJS) | - |

## Настройка BroJS

После деплоя обновите конфигурацию в [BroJS Admin](https://admin.brojs.ru):

| Ключ | Значение |
|------|----------|
| `work21-fr.api` | `https://api.work-21.com/api` |
| `work21-fr.api.estimator` | `https://api.work-21.com/agent` |

## SSL сертификаты (HTTPS)

SSL автоматически обрабатывается Cloudflare при включенном Proxy.

Для прямого SSL (без Cloudflare):

### 1. Получите сертификат

```bash
# Остановите nginx
docker compose stop nginx

# Получите сертификат
docker run --rm -p 80:80 \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  certbot/certbot certonly --standalone \
  -d api.work-21.com -d admin.work-21.com \
  --email your@email.com \
  --agree-tos --no-eff-email
```

### 2. Перезапустите

```bash
docker compose up -d
```

## Troubleshooting

### 502 Bad Gateway
```bash
# Проверьте что backend запущен
docker compose ps
docker compose logs backend
```

### CORS ошибки
```bash
# Перезапустите nginx
docker compose restart nginx
```

### База данных
```bash
docker compose logs db
docker compose exec db psql -U work21 -d work21
```

### Админка не грузится
```bash
docker compose logs admin
docker compose up -d --build admin
```

## Репозитории

- **Frontend:** https://github.com/ChargeOnTop/work21-fr
- **Backend:** https://github.com/ChargeOnTop/work21-backend
- **Agent:** https://github.com/ChargeOnTop/work21-agent
- **Admin:** https://github.com/ChargeOnTop/work21-admin
- **Deploy:** https://github.com/ChargeOnTop/work21-deploy
