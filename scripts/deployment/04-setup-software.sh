#!/bin/bash
#
# Скрипт установки и настройки необходимого ПО
# Согласно инструкции QazTech, шаг 15.8
#
# Использование:
#   ./04-setup-software.sh <PROJECT_NAME> <ENVIRONMENT>
#   Пример: ./04-setup-software.sh myproject dev
#

set -e

# Проверка аргументов
if [ $# -lt 2 ]; then
    echo "Ошибка: недостаточно аргументов"
    echo "Использование: $0 <PROJECT_NAME> <ENVIRONMENT>"
    exit 1
fi

PROJECT_NAME=$1
ENVIRONMENT=$2

echo "=========================================="
echo "Установка и настройка ПО"
echo "Проект: $PROJECT_NAME"
echo "Среда: $ENVIRONMENT"
echo "=========================================="

echo ""
echo "Шаг 1: Установка системных пакетов через Nexus..."
echo ""
cat << EOF

# 1. Обновление списка пакетов:
sudo yum clean all
sudo yum makecache

# 2. Установка базовых пакетов:
sudo yum install -y \\
    git \\
    curl \\
    wget \\
    vim \\
    htop \\
    net-tools \\
    docker \\
    docker-compose

# 3. Запуск Docker:
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker \$USER

# 4. Установка Node.js (если нужна конкретная версия):
# Через Nexus или напрямую:
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# 5. Установка PostgreSQL клиента (для подключения к БД):
sudo yum install -y postgresql

EOF

echo ""
echo "Шаг 2: Установка зависимостей проекта..."
echo ""
cat << EOF

# 1. Backend зависимости:
cd backend
npm install --production

# 2. Frontend зависимости:
cd ../frontend
npm install

# 3. Сборка frontend:
npm run build

EOF

echo ""
echo "Шаг 3: Настройка переменных окружения..."
echo ""
cat << EOF

# 1. Создать .env файлы из примеров:
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env

# 2. Заполнить реальными значениями:
# Backend .env:
# DATABASE_URL=postgres://user:pass@host:5432/db
# NODE_ENV=$ENVIRONMENT
# PORT=3000

# Frontend .env:
# VITE_API_URL=https://api-$ENVIRONMENT.$PROJECT_NAME.qaztech.gov.kz

EOF

echo ""
echo "Шаг 4: Настройка systemd сервисов (опционально)..."
echo ""
cat << EOF

# Создать systemd сервис для backend:
sudo tee /etc/systemd/system/$PROJECT_NAME-backend.service > /dev/null << SERVICE_EOF
[Unit]
Description=$PROJECT_NAME Backend Service
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/$PROJECT_NAME/backend
EnvironmentFile=/opt/$PROJECT_NAME/backend/.env
ExecStart=/usr/bin/docker run --rm \\
    --name $PROJECT_NAME-backend \\
    -p 3000:3000 \\
    -e DATABASE_URL=\\\$DATABASE_URL \\
    -e NODE_ENV=\\\$NODE_ENV \\
    $HARBOR_URL/$PROJECT_NAME/backend:latest
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Включить и запустить сервис:
sudo systemctl daemon-reload
sudo systemctl enable $PROJECT_NAME-backend
sudo systemctl start $PROJECT_NAME-backend

EOF

echo ""
echo "=========================================="
echo "Установка ПО завершена"
echo "=========================================="
echo ""
echo "Следующий шаг: настройка CI/CD (05-setup-cicd.sh)"

