#!/bin/bash

# ===========================================
# WORK21 - Скрипт развёртывания
# ===========================================
# Запуск: chmod +x setup.sh && ./setup.sh

set -e

echo "🚀 WORK21 - Настройка окружения"
echo "================================"

# Клонирование репозиториев
echo ""
echo "📦 Клонирование репозиториев..."

if [ ! -d "backend" ]; then
    git clone https://github.com/ChargeOnTop/work21-backend.git backend
    echo "✅ Backend склонирован"
else
    cd backend && git pull && cd ..
    echo "✅ Backend обновлён"
fi

if [ ! -d "agent" ]; then
    git clone https://github.com/ChargeOnTop/work21-agent.git agent
    echo "✅ Agent склонирован"
else
    cd agent && git pull && cd ..
    echo "✅ Agent обновлён"
fi

if [ ! -d "admin" ]; then
    git clone https://github.com/ChargeOnTop/work21-admin.git admin
    echo "✅ Admin склонирован"
else
    cd admin && git pull && cd ..
    echo "✅ Admin обновлён"
fi

# Проверка .env файла
echo ""
if [ ! -f ".env" ]; then
    echo "⚠️  Создайте .env файл из примера:"
    echo "   cp .env.example .env"
    echo "   nano .env"
    exit 1
else
    echo "✅ .env файл найден"
fi

# Запуск
echo ""
echo "🔧 Готово к запуску!"
echo ""
echo "Команды:"
echo "  docker compose up -d        # Запустить все сервисы"
echo "  docker compose logs -f      # Смотреть логи"
echo "  docker compose down         # Остановить"
echo ""
echo "После первого запуска создайте админа:"
echo "  docker exec -it work21-backend python scripts/create_admin.py"
echo ""

