#!/bin/bash
#
# Скрипт настройки подключения SonarQube для анализа кода
# Согласно инструкции QazTech, шаг 15.10
#
# Использование:
#   ./06-setup-sonarqube.sh <PROJECT_NAME>
#   Пример: ./06-setup-sonarqube.sh myproject
#

set -e

# Проверка аргументов
if [ $# -lt 1 ]; then
    echo "Ошибка: недостаточно аргументов"
    echo "Использование: $0 <PROJECT_NAME>"
    exit 1
fi

PROJECT_NAME=$1

# URL SonarQube на платформе QazTech
SONARQUBE_URL="https://sonarqube.qaztech.gov.kz"

echo "=========================================="
echo "Настройка подключения SonarQube"
echo "Проект: $PROJECT_NAME"
echo "URL: $SONARQUBE_URL"
echo "=========================================="

echo ""
echo "Шаг 1: Создание проекта в SonarQube..."
echo ""
cat << EOF

# 1. Войти в SonarQube:
#    $SONARQUBE_URL
#    Используйте учетные данные, полученные от менеджера АО НИТ

# 2. Проект обычно создается автоматически при создании проекта на платформе
#    Если проект не создан, создайте его вручную:
#    - Projects -> Create Project
#    - Project key: $PROJECT_NAME-backend
#    - Display name: $PROJECT_NAME Backend

# 3. Создать отдельный проект для frontend:
#    - Project key: $PROJECT_NAME-frontend
#    - Display name: $PROJECT_NAME Frontend

EOF

echo ""
echo "Шаг 2: Получение токена доступа..."
echo ""
cat << EOF

# 1. В SonarQube перейти: My Account -> Security
# 2. Создать новый токен:
#    - Name: gitlab-ci-token
#    - Type: User Token
#    - Expires: (установить срок действия или оставить пустым)
# 3. Скопировать созданный токен (он показывается только один раз!)

# 4. Добавить токен в GitLab переменные:
#    Settings -> CI/CD -> Variables
#    - SONARQUBE_TOKEN = <скопированный_токен> (masked, protected)

EOF

echo ""
echo "Шаг 3: Проверка конфигурации в .gitlab-ci.yml..."
echo ""
echo "Конфигурация SonarQube уже настроена в:"
echo "  - .gitlab-ci.yml"
echo "  - gitlab-ci/sonarqube.yml"
echo ""
echo "Пайплайн автоматически выполнит анализ кода при:"
echo "  - Push в ветку main или develop"
echo "  - Создании merge request"

echo ""
echo "Шаг 4: Настройка Quality Gates (опционально)..."
echo ""
cat << EOF

# Quality Gates позволяют блокировать развертывание при низком качестве кода
# 1. В SonarQube: Quality Gates -> Create
# 2. Настроить правила:
#    - Coverage: минимум 80%
#    - Duplicated Lines: максимум 3%
#    - Maintainability Rating: максимум B
#    - Reliability Rating: максимум A
#    - Security Rating: максимум A
# 3. Применить Quality Gate к проекту

# В .gitlab-ci.yml уже настроено:
#   -Dsonar.qualitygate.wait=true
# Это означает, что пайплайн будет ждать результатов Quality Gate

EOF

echo ""
echo "Шаг 5: Просмотр результатов анализа..."
echo ""
cat << EOF

# После выполнения пайплайна:
# 1. Перейти в SonarQube: $SONARQUBE_URL
# 2. Выбрать проект: $PROJECT_NAME-backend или $PROJECT_NAME-frontend
# 3. Просмотреть:
#    - Issues: найденные проблемы
#    - Measures: метрики качества кода
#    - Code: просмотр кода с выделением проблем

# 4. Исправить найденные проблемы и запустить пайплайн снова

EOF

echo ""
echo "=========================================="
echo "Настройка SonarQube завершена"
echo "=========================================="
echo ""
echo "Следующий шаг: подключение SAST (07-setup-sast.sh)"

