#!/bin/bash
#
# Скрипт загрузки исходного кода в GitLab репозиторий
# Согласно инструкции QazTech, шаг 15.5
#
# Использование:
#   ./01-upload-code-to-gitlab.sh <PROJECT_NAME>
#   Пример: ./01-upload-code-to-gitlab.sh myproject
#

set -e

# Проверка аргументов
if [ $# -lt 1 ]; then
    echo "Ошибка: недостаточно аргументов"
    echo "Использование: $0 <PROJECT_NAME>"
    exit 1
fi

PROJECT_NAME=$1

# URL GitLab на платформе QazTech
GITLAB_URL="https://gitlab.qaztech.gov.kz"

echo "=========================================="
echo "Загрузка исходного кода в GitLab"
echo "Проект: $PROJECT_NAME"
echo "=========================================="

echo ""
echo "Шаг 1: Проверка Git репозитория..."
if [ ! -d ".git" ]; then
    echo "Инициализация Git репозитория..."
    git init
    git config user.name "QazTech Deploy"
    git config user.email "deploy@qaztech.gov.kz"
fi

echo ""
echo "Шаг 2: Добавление удаленного репозитория GitLab..."
echo ""
echo "URL репозитория GitLab:"
echo "  $GITLAB_URL/$PROJECT_NAME/$PROJECT_NAME.git"
echo ""
echo "Выполните следующие команды:"
echo ""
cat << EOF

# 1. Добавить удаленный репозиторий (если еще не добавлен):
git remote add origin $GITLAB_URL/$PROJECT_NAME/$PROJECT_NAME.git

# Или обновить существующий:
git remote set-url origin $GITLAB_URL/$PROJECT_NAME/$PROJECT_NAME.git

# 2. Добавить все файлы в индекс:
git add .

# 3. Создать коммит:
git commit -m "Initial commit: развертывание на QazTech"

# 4. Отправить код в GitLab:
git push -u origin main

# Или если используется ветка master:
git push -u origin master

EOF

echo ""
echo "Шаг 3: Создание структуры репозиториев..."
echo ""
echo "В GitLab должны быть созданы следующие репозитории:"
echo "  - $PROJECT_NAME/$PROJECT_NAME (основной репозиторий)"
echo "  - $PROJECT_NAME/$PROJECT_NAME-backend (опционально, для backend)"
echo "  - $PROJECT_NAME/$PROJECT_NAME-frontend (опционально, для frontend)"
echo ""
echo "Создание репозиториев выполняется через портал самообслуживания:"
echo "  https://portal.qaztech.gov.kz"
echo ""

echo "=========================================="
echo "Загрузка кода завершена"
echo "=========================================="
echo ""
echo "Следующий шаг: подключение Nexus (02-setup-nexus.sh)"

