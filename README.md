# 🚀 WORK21 Deploy

Единый деплой-конфиг для запуска всего стека WORK21 на VPS.

## Архитектура

```
┌─────────────────────────────────────────────────────────┐
│                      VPS Server                          │
│                                                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │                 Nginx (:80, :443)                │    │
│  │         Reverse Proxy + SSL + CORS              │    │
│  └──────────┬───────────────────┬──────────────────┘    │
│             │                   │                        │
│       /api/*              /agent/*                       │
│             │                   │                        │
│  ┌──────────▼────────┐ ┌───────▼──────────────┐         │
│  │   Backend API     │ │    AI Agent          │         │
│  │   FastAPI :8000   │ │    FastAPI :8080     │         │
│  │   + PostgreSQL    │ │    + GigaChat        │         │
│  └───────────────────┘ └──────────────────────┘         │
│                                                          │
└─────────────────────────────────────────────────────────┘
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
```

### 3. Запуск

```bash
chmod +x deploy.sh
./deploy.sh
```

### 4. Проверка

```bash
# Health check
curl http://YOUR_VPS_IP/health

# Backend API
curl http://YOUR_VPS_IP/api/v1/

# Agent API
curl http://YOUR_VPS_IP/agent/api/v1/llm/health
```

## Структура проекта

```
work21-deploy/
├── docker-compose.yml    # Главный конфиг
├── nginx/
│   └── nginx.conf        # Конфигурация Nginx
├── .env.example          # Пример переменных
├── deploy.sh             # Скрипт деплоя
├── backend/              # (клонируется автоматически)
└── agent/                # (клонируется автоматически)
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
docker compose logs -f nginx

# Перезапуск
docker compose restart

# Обновление кода
cd backend && git pull && cd ..
cd agent && git pull && cd ..
docker compose up -d --build

# Статус
docker compose ps
```

## Настройка BroJS

После деплоя обновите конфигурацию в [BroJS Admin](https://admin.brojs.ru):

| Ключ | Значение |
|------|----------|
| `work21-fr.api` | `http://YOUR_VPS_IP/api` |
| `work21-fr.api.estimator` | `http://YOUR_VPS_IP/agent` |

## SSL сертификаты (HTTPS)

### 1. Настройте домен

Добавьте A-запись: `your-domain.com` → `YOUR_VPS_IP`

### 2. Получите сертификат

```bash
# Остановите nginx
docker compose stop nginx

# Получите сертификат
docker run --rm -p 80:80 \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  certbot/certbot certonly --standalone \
  -d your-domain.com \
  --email your@email.com \
  --agree-tos --no-eff-email
```

### 3. Обновите nginx.conf

Раскомментируйте HTTPS блок и замените `your-domain.com` на ваш домен.

### 4. Перезапустите

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

## Репозитории

- **Frontend:** https://github.com/ChargeOnTop/work21-fr
- **Backend:** https://github.com/ChargeOnTop/work21-backend
- **Agent:** https://github.com/ChargeOnTop/work21-agent
- **Deploy:** https://github.com/ChargeOnTop/work21-deploy

