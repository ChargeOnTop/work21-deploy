#!/bin/bash
# ===========================================
# WORK21 - Скрипт деплоя на VPS
# ===========================================
# Запуск: chmod +x deploy.sh && ./deploy.sh

set -e

echo "🚀 WORK21 Deployment"
echo "===================="

# ===========================================
# 1. Проверка Docker
# ===========================================
if ! command -v docker &> /dev/null; then
    echo "📦 Устанавливаю Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    echo "✅ Docker установлен. Перезайдите в терминал и запустите скрипт снова."
    exit 0
fi

echo "✅ Docker: $(docker --version)"

# ===========================================
# 2. Проверка .env
# ===========================================
if [ ! -f .env ]; then
    echo "❌ Файл .env не найден!"
    echo "   Выполните: cp .env.example .env && nano .env"
    exit 1
fi

echo "✅ .env найден"

# ===========================================
# 3. Клонирование репозиториев
# ===========================================
echo ""
echo "📥 Клонирую репозитории..."

if [ ! -d "backend" ]; then
    git clone https://github.com/oinuritto/work21-backend.git backend
    echo "✅ Backend клонирован"
else
    (cd backend && git pull)
    echo "✅ Backend обновлён"
fi

if [ ! -d "agent" ]; then
    git clone https://github.com/Daimnedope/work21-agents.git agent
    echo "✅ Agent клонирован"
else
    (cd agent && git pull)
    echo "✅ Agent обновлён"
fi

if [ ! -d "admin" ]; then
    git clone https://github.com/Daimnedope/work21-admins.git admin
    echo "✅ Admin клонирован"
else
    (cd admin && git pull)
    echo "✅ Admin обновлён"
fi

# ===========================================
# 4. Создание директорий
# ===========================================
mkdir -p certbot/www certbot/conf

# ===========================================
# 5. Сборка и запуск
# ===========================================
echo ""
echo "🔨 Собираю Docker образы..."
docker compose build

echo ""
echo "🚀 Запускаю сервисы..."
docker compose up -d

# ===========================================
# 6. Ожидание запуска
# ===========================================
echo ""
echo "⏳ Жду запуска сервисов (30 сек)..."
sleep 30

# ===========================================
# 7. Проверка
# ===========================================
echo ""
echo "📊 Статус сервисов:"
docker compose ps

echo ""
echo "🔍 Проверка health:"
curl -s http://localhost/health || echo "Backend ещё запускается..."

echo ""
echo "============================================"
echo "✅ Деплой завершён!"
echo ""
echo "🌐 Endpoints:"
echo "   Backend API:  https://api.work-21.com/api/v1/"
echo "   Agent API:    https://api.work-21.com/agent/api/v1/"
echo "   Admin Panel:  https://admin.work-21.com/"
echo "   Swagger:      https://api.work-21.com/docs"
echo "   Health:       https://api.work-21.com/health"
echo ""
echo "👤 Создать админа (первый запуск):"
echo "   docker exec -it work21-backend python scripts/create_admin.py"
echo ""
echo "📝 Команды:"
echo "   Логи:        docker compose logs -f"
echo "   Рестарт:     docker compose restart"
echo "   Стоп:        docker compose down"
echo "============================================"


