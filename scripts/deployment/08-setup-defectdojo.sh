#!/bin/bash
#
# Скрипт настройки подключения DefectDojo для управления уязвимостями
# Согласно инструкции QazTech, шаг 15.12
#
# Использование:
#   ./08-setup-defectdojo.sh <PROJECT_NAME>
#   Пример: ./08-setup-defectdojo.sh myproject
#

set -e

# Проверка аргументов
if [ $# -lt 1 ]; then
    echo "Ошибка: недостаточно аргументов"
    echo "Использование: $0 <PROJECT_NAME>"
    exit 1
fi

PROJECT_NAME=$1

# URL DefectDojo на платформе QazTech (нужно уточнить)
DEFECTDOJO_URL="https://defectdojo.qaztech.gov.kz"

echo "=========================================="
echo "Настройка подключения DefectDojo"
echo "Проект: $PROJECT_NAME"
echo "URL: $DEFECTDOJO_URL"
echo "=========================================="

echo ""
echo "Шаг 1: Создание проекта в DefectDojo..."
echo ""
cat << EOF

# 1. Войти в DefectDojo:
#    $DEFECTDOJO_URL
#    Используйте учетные данные, полученные от менеджера АО НИТ

# 2. Проект обычно создается автоматически при создании проекта на платформе
#    Если проект не создан, создайте его вручную:
#    - Products -> Add Product
#    - Name: $PROJECT_NAME
#    - Description: Описание проекта
#    - Product Type: Application

# 3. Создать Engagement (взаимодействие) для каждой среды:
#    - Engagements -> Add Engagement
#    - Name: $PROJECT_NAME-dev
#    - Target Start: (дата начала)
#    - Target End: (дата окончания)

EOF

echo ""
echo "Шаг 2: Получение API токена..."
echo ""
cat << EOF

# 1. В DefectDojo перейти: User -> API Key
# 2. Создать новый API ключ:
#    - Name: gitlab-ci-integration
#    - Expires: (установить срок действия или оставить пустым)
# 3. Скопировать созданный API ключ

# 4. Добавить токен в GitLab переменные:
#    Settings -> CI/CD -> Variables
#    - DEFECTDOJO_URL = $DEFECTDOJO_URL
#    - DEFECTDOJO_API_TOKEN = <скопированный_токен> (masked, protected)

EOF

echo ""
echo "Шаг 3: Проверка конфигурации в .gitlab-ci.yml..."
echo ""
echo "Конфигурация DefectDojo уже настроена в:"
echo "  - gitlab-ci/security.yml (job: defectdojo)"
echo ""
echo "Отчеты о безопасности автоматически загружаются в DefectDojo при:"
echo "  - Завершении этапа security в пайплайне"
echo "  - Job выполняется вручную (when: manual)"

echo ""
echo "Шаг 4: Просмотр уязвимостей в DefectDojo..."
echo ""
cat << EOF

# После выполнения пайплайна:
# 1. Перейти в DefectDojo: $DEFECTDOJO_URL
# 2. Выбрать продукт: $PROJECT_NAME
# 3. Перейти в Engagement для нужной среды
# 4. Просмотреть Findings (найденные уязвимости):
#    - Severity: Critical, High, Medium, Low, Info
#    - Status: New, Active, Verified, Mitigated, False Positive
#    - Scanner: GitLab SAST, Dependency Scanning

# 5. Для каждой уязвимости:
#    - Назначить ответственного
#    - Установить приоритет
#    - Добавить комментарии
#    - Отметить как исправленную

EOF

echo ""
echo "Шаг 5: Интеграция с другими инструментами..."
echo ""
cat << EOF

# DefectDojo может интегрироваться с:
# - Jira: для создания задач на исправление уязвимостей
# - Slack: для уведомлений о критических уязвимостях
# - Email: для отправки отчетов

# Настройка интеграций:
# 1. Перейти: Configuration -> Tool Configuration
# 2. Добавить необходимые интеграции
# 3. Настроить правила уведомлений

EOF

echo ""
echo "=========================================="
echo "Настройка DefectDojo завершена"
echo "=========================================="
echo ""
echo "Следующий шаг: настройка мониторинга Grafana (09-setup-monitoring.sh)"

