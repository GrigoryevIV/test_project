#!/bin/bash
#
# Скрипт настройки SAST (Static Application Security Testing)
# Согласно инструкции QazTech, шаг 15.11
#
# Использование:
#   ./07-setup-sast.sh <PROJECT_NAME>
#   Пример: ./07-setup-sast.sh myproject
#

set -e

# Проверка аргументов
if [ $# -lt 1 ]; then
    echo "Ошибка: недостаточно аргументов"
    echo "Использование: $0 <PROJECT_NAME>"
    exit 1
fi

PROJECT_NAME=$1

echo "=========================================="
echo "Настройка SAST (Static Application Security Testing)"
echo "Проект: $PROJECT_NAME"
echo "=========================================="

echo ""
echo "Шаг 1: Включение SAST в GitLab..."
echo ""
cat << EOF

# SAST встроен в GitLab и не требует дополнительной настройки
# Конфигурация уже добавлена в gitlab-ci/security.yml

# Для включения SAST:
# 1. Перейти в GitLab: Settings -> CI/CD -> General pipelines
# 2. Убедиться, что SAST включен (включен по умолчанию)
# 3. Настроить правила (опционально): Settings -> CI/CD -> Secret Detection

EOF

echo ""
echo "Шаг 2: Проверка конфигурации SAST..."
echo ""
echo "Конфигурация SAST находится в:"
echo "  - .gitlab-ci.yml (включает security stage)"
echo "  - gitlab-ci/security.yml (детальная конфигурация)"
echo ""
echo "SAST автоматически выполняется при:"
echo "  - Push в ветку main или develop"
echo "  - Создании merge request"

echo ""
echo "Шаг 3: Просмотр результатов SAST..."
echo ""
cat << EOF

# После выполнения пайплайна:
# 1. Перейти в GitLab: Security -> Vulnerability Report
# 2. Просмотреть найденные уязвимости:
#    - Severity: Critical, High, Medium, Low, Info
#    - Status: Detected, Dismissed, Resolved
#    - Scanner: SAST, Dependency Scanning

# 3. Для каждой уязвимости доступно:
#    - Описание проблемы
#    - Расположение в коде
#    - Рекомендации по исправлению
#    - CVE информация (если применимо)

# 4. Исправить уязвимости и запустить пайплайн снова

EOF

echo ""
echo "Шаг 4: Настройка правил безопасности (опционально)..."
echo ""
cat << EOF

# Можно настроить правила для автоматической блокировки при критических уязвимостях:
# 1. Перейти: Settings -> CI/CD -> Secret Detection
# 2. Настроить правила:
#    - Блокировать merge request при обнаружении секретов
#    - Блокировать merge request при критических уязвимостях
#    - Игнорировать определенные паттерны (false positives)

EOF

echo ""
echo "=========================================="
echo "Настройка SAST завершена"
echo "=========================================="
echo ""
echo "Следующий шаг: подключение DefectDojo (08-setup-defectdojo.sh)"

