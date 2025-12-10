#!/bin/bash
#
# Скрипт настройки интеграции с Harbor (Docker Registry)
# Согласно инструкции QazTech, шаг 15.7
#
# Использование:
#   ./03-setup-harbor.sh <PROJECT_NAME>
#   Пример: ./03-setup-harbor.sh myproject
#

set -e

# Проверка аргументов
if [ $# -lt 1 ]; then
    echo "Ошибка: недостаточно аргументов"
    echo "Использование: $0 <PROJECT_NAME>"
    exit 1
fi

PROJECT_NAME=$1

# URL Harbor реестра на платформе QazTech
HARBOR_URL="https://harbor.qaztech.gov.kz"
HARBOR_PROJECT="${PROJECT_NAME}"

echo "=========================================="
echo "Настройка интеграции с Harbor"
echo "Проект: $PROJECT_NAME"
echo "URL: $HARBOR_URL"
echo "=========================================="

echo ""
echo "Шаг 1: Настройка Docker для работы с Harbor..."
echo ""
cat << EOF

# 1. Вход в Harbor через Docker:
docker login $HARBOR_URL \\
    --username <ваш_логин_harbor> \\
    --password <ваш_пароль_harbor>

# 2. Или через переменные окружения:
export HARBOR_USERNAME="<ваш_логин_harbor>"
export HARBOR_PASSWORD="<ваш_пароль_harbor>"
echo "\$HARBOR_PASSWORD" | docker login $HARBOR_URL --username "\$HARBOR_USERNAME" --password-stdin

# 3. Проверка входа:
docker info | grep -i registry

EOF

echo ""
echo "Шаг 2: Настройка GitLab CI/CD для автоматической доставки образов..."
echo ""
echo "В GitLab (Settings -> CI/CD -> Variables) необходимо добавить:"
echo "  - HARBOR_URL = $HARBOR_URL"
echo "  - HARBOR_PROJECT = $HARBOR_PROJECT"
echo "  - HARBOR_USERNAME = <логин> (masked)"
echo "  - HARBOR_PASSWORD = <пароль> (masked, protected)"
echo ""
echo "Конфигурация уже настроена в .gitlab-ci.yml и gitlab-ci/build.yml"
echo ""

echo ""
echo "Шаг 3: Тегирование и публикация Docker-образов вручную (для тестирования)..."
echo ""
cat << EOF

# Backend образ:
cd backend
docker build -t $HARBOR_URL/$HARBOR_PROJECT/backend:latest .
docker tag $HARBOR_URL/$HARBOR_PROJECT/backend:latest $HARBOR_URL/$HARBOR_PROJECT/backend:\$(git describe --tags 2>/dev/null || echo "dev")
docker push $HARBOR_URL/$HARBOR_PROJECT/backend:latest

# Frontend образ:
cd ../frontend
docker build -t $HARBOR_URL/$HARBOR_PROJECT/frontend:latest .
docker tag $HARBOR_URL/$HARBOR_PROJECT/frontend:latest $HARBOR_URL/$HARBOR_PROJECT/frontend:\$(git describe --tags 2>/dev/null || echo "dev")
docker push $HARBOR_URL/$HARBOR_PROJECT/frontend:latest

EOF

echo ""
echo "Шаг 4: Настройка на серверах для pull образов..."
echo ""
cat << EOF

# На каждой виртуальной машине выполнить:
# 1. Вход в Harbor:
docker login $HARBOR_URL \\
    --username <сервисный_логин> \\
    --password <сервисный_пароль>

# 2. Pull образа:
docker pull $HARBOR_URL/$HARBOR_PROJECT/backend:latest
docker pull $HARBOR_URL/$HARBOR_PROJECT/frontend:latest

# 3. Запуск контейнеров (пример):
# docker run -d --name backend --restart unless-stopped \\
#   -e DATABASE_URL="\$DATABASE_URL" \\
#   -p 3000:3000 \\
#   $HARBOR_URL/$HARBOR_PROJECT/backend:latest

EOF

echo ""
echo "=========================================="
echo "Настройка Harbor завершена"
echo "=========================================="
echo ""
echo "Важно:"
echo "  - Используйте сервисные учетные записи для CI/CD"
echo "  - Храните учетные данные в HashiCorp Vault"
echo "  - Используйте теги версий для управления образами"
echo ""
echo "Следующий шаг: установка и настройка ПО (04-setup-software.sh)"

