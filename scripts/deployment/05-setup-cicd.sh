#!/bin/bash
#
# Скрипт настройки CI/CD в GitLab
# Согласно инструкции QazTech, шаг 15.9
#
# Использование:
#   ./05-setup-cicd.sh <PROJECT_NAME>
#   Пример: ./05-setup-cicd.sh myproject
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
HARBOR_URL="https://harbor.qaztech.gov.kz"
SONARQUBE_URL="https://sonarqube.qaztech.gov.kz"

echo "=========================================="
echo "Настройка CI/CD в GitLab"
echo "Проект: $PROJECT_NAME"
echo "GitLab: $GITLAB_URL"
echo "=========================================="

echo ""
echo "Шаг 1: Проверка наличия .gitlab-ci.yml..."
if [ ! -f ".gitlab-ci.yml" ]; then
    echo "Ошибка: файл .gitlab-ci.yml не найден!"
    echo "Убедитесь, что файл находится в корне проекта"
    exit 1
fi

echo "✓ Файл .gitlab-ci.yml найден"

echo ""
echo "Шаг 2: Настройка переменных в GitLab..."
echo ""
echo "Перейдите в GitLab: $GITLAB_URL/$PROJECT_NAME/$PROJECT_NAME"
echo "Затем: Settings -> CI/CD -> Variables"
echo ""
echo "Добавьте следующие переменные:"
echo ""
cat << EOF

**Harbor (для сборки и публикации Docker образов):**
  - HARBOR_URL = $HARBOR_URL
  - HARBOR_PROJECT = $PROJECT_NAME
  - HARBOR_USERNAME = <ваш_логин_harbor> (masked)
  - HARBOR_PASSWORD = <ваш_пароль_harbor> (masked, protected)

**Nexus (для установки зависимостей):**
  - NEXUS_URL = https://nexus.qaztech.gov.kz
  - NEXUS_USERNAME = <ваш_логин_nexus> (masked)
  - NEXUS_PASSWORD = <ваш_пароль_nexus> (masked, protected)

**SonarQube (для анализа кода):**
  - SONARQUBE_URL = $SONARQUBE_URL
  - SONARQUBE_TOKEN = <ваш_токен_sonarqube> (masked, protected)

**SSH для развертывания:**
  - SSH_PRIVATE_KEY = <приватный_ssh_ключ> (masked, protected, file)

**IP адреса серверов (для каждой среды):**
  - DEV_SERVER_IP = <IP_адрес_DEV_сервера>
  - TEST_SERVER_IP = <IP_адрес_TEST_сервера>
  - STAGE_SERVER_IP = <IP_адрес_STAGE_сервера>
  - PROD_SERVER_IP = <IP_адрес_PROD_сервера>

**URL баз данных (для каждой среды):**
  - DEV_DATABASE_URL = postgres://user:pass@host:5432/db (masked, protected)
  - TEST_DATABASE_URL = postgres://user:pass@host:5432/db (masked, protected)
  - STAGE_DATABASE_URL = postgres://user:pass@host:5432/db (masked, protected)
  - PROD_DATABASE_URL = postgres://user:pass@host:5432/db (masked, protected)

**API URLs (для frontend):**
  - DEV_API_URL = https://api-dev.$PROJECT_NAME.qaztech.gov.kz
  - TEST_API_URL = https://api-test.$PROJECT_NAME.qaztech.gov.kz
  - STAGE_API_URL = https://api-stage.$PROJECT_NAME.qaztech.gov.kz
  - PROD_API_URL = https://api.$PROJECT_NAME.qaztech.gov.kz

EOF

echo ""
echo "Шаг 3: Настройка GitLab Runner..."
echo ""
cat << EOF

# GitLab Runner должен быть установлен на виртуальной машине или использовать shared runners
# Проверка доступных runners:
# В GitLab: Settings -> CI/CD -> Runners

# Если нужно установить GitLab Runner на ВМ:
# 1. Подключиться к виртуальной машине по SSH
# 2. Установить GitLab Runner:
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash
sudo yum install gitlab-runner

# 3. Зарегистрировать runner:
sudo gitlab-runner register \\
  --url $GITLAB_URL \\
  --registration-token <ваш_токен_регистрации> \\
  --executor docker \\
  --docker-image docker:latest \\
  --docker-privileged \\
  --description "$PROJECT_NAME-runner"

# 4. Запустить runner:
sudo gitlab-runner start

EOF

echo ""
echo "Шаг 4: Проверка конфигурации CI/CD..."
echo ""
echo "Пайплайн включает следующие этапы:"
echo "  - build: сборка приложения (Docker образы)"
echo "  - test: запуск тестов"
echo "  - security: проверка безопасности (SAST, Dependency Scanning)"
echo "  - sonarqube: анализ качества кода"
echo "  - deploy: развертывание по средам"
echo ""
echo "Для запуска пайплайна:"
echo "  1. Сделайте commit и push в GitLab"
echo "  2. Пайплайн запустится автоматически"
echo "  3. Или запустите вручную: CI/CD -> Pipelines -> Run pipeline"

echo ""
echo "=========================================="
echo "Настройка CI/CD завершена"
echo "=========================================="
echo ""
echo "Следующий шаг: подключение SonarQube (06-setup-sonarqube.sh)"

