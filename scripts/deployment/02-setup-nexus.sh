#!/bin/bash
#
# Скрипт настройки подключения к Nexus репозиторию
# Согласно инструкции QazTech, шаг 15.6
#
# Использование:
#   ./02-setup-nexus.sh <PROJECT_NAME>
#   Пример: ./02-setup-nexus.sh myproject
#

set -e

# Проверка аргументов
if [ $# -lt 1 ]; then
    echo "Ошибка: недостаточно аргументов"
    echo "Использование: $0 <PROJECT_NAME>"
    exit 1
fi

PROJECT_NAME=$1

# URL Nexus репозитория на платформе QazTech
NEXUS_URL="https://nexus.qaztech.gov.kz"
NEXUS_REPO="${PROJECT_NAME}-repo"

echo "=========================================="
echo "Настройка подключения к Nexus репозиторию"
echo "Проект: $PROJECT_NAME"
echo "URL: $NEXUS_URL"
echo "=========================================="

echo ""
echo "Шаг 1: Настройка NPM для работы с Nexus..."
echo ""
cat << EOF

# 1. Скопировать конфигурацию NPM:
cp config/nexus/.npmrc backend/.npmrc
cp config/nexus/.npmrc frontend/.npmrc

# 2. Заменить <PROJECT_NAME> на реальное имя проекта:
sed -i 's/<PROJECT_NAME>/$PROJECT_NAME/g' backend/.npmrc
sed -i 's/<PROJECT_NAME>/$PROJECT_NAME/g' frontend/.npmrc

# 3. Установить переменные окружения для аутентификации:
export NEXUS_USERNAME="<ваш_логин_nexus>"
export NEXUS_PASSWORD="<ваш_пароль_nexus>"
export NEXUS_AUTH_TOKEN=\$(echo -n "\$NEXUS_USERNAME:\$NEXUS_PASSWORD" | base64)

# 4. Добавить токен в .npmrc (опционально):
# echo "_auth=\$NEXUS_AUTH_TOKEN" >> backend/.npmrc

# 5. Проверить подключение:
cd backend && npm install --dry-run

EOF

echo ""
echo "Шаг 2: Настройка Maven (для Java проектов)..."
echo ""
cat << EOF

# 1. Скопировать конфигурацию Maven:
mkdir -p ~/.m2
cp config/nexus/maven-settings.xml ~/.m2/settings.xml

# 2. Заменить <PROJECT_NAME> в settings.xml:
sed -i 's/<PROJECT_NAME>/$PROJECT_NAME/g' ~/.m2/settings.xml

# 3. Установить переменные окружения:
export NEXUS_USERNAME="<ваш_логин_nexus>"
export NEXUS_PASSWORD="<ваш_пароль_nexus>"

# 4. В pom.xml проекта добавить репозиторий:
# <repositories>
#     <repository>
#         <id>nexus-$PROJECT_NAME</id>
#         <url>$NEXUS_URL/repository/$NEXUS_REPO/</url>
#     </repository>
# </repositories>

EOF

echo ""
echo "Шаг 3: Настройка YUM репозитория (для системных пакетов)..."
echo ""
cat << EOF

# 1. Скопировать конфигурацию YUM:
sudo cp config/nexus/yum-repo.conf /etc/yum.repos.d/$PROJECT_NAME-nexus.repo

# 2. Заменить <PROJECT_NAME> в файле репозитория:
sudo sed -i 's/<PROJECT_NAME>/$PROJECT_NAME/g' /etc/yum.repos.d/$PROJECT_NAME-nexus.repo

# 3. Обновить список пакетов:
sudo yum clean all
sudo yum makecache

# 4. Установить пакет для проверки:
# sudo yum install <package-name> --enablerepo=$PROJECT_NAME-nexus

EOF

echo ""
echo "Шаг 4: Настройка Gradle (для Kotlin/Java проектов)..."
echo ""
cat << EOF

# 1. Создать или обновить ~/.gradle/init.gradle:
mkdir -p ~/.gradle
cat > ~/.gradle/init.gradle << GRADLE_EOF
allprojects {
    repositories {
        maven {
            url "$NEXUS_URL/repository/$NEXUS_REPO/"
            credentials {
                username = System.getenv("NEXUS_USERNAME")
                password = System.getenv("NEXUS_PASSWORD")
            }
        }
    }
}
GRADLE_EOF

# 2. В build.gradle проекта добавить:
# repositories {
#     maven {
#         url "$NEXUS_URL/repository/$NEXUS_REPO/"
#     }
# }

EOF

echo ""
echo "=========================================="
echo "Настройка Nexus завершена"
echo "=========================================="
echo ""
echo "Важно:"
echo "  - Учетные данные Nexus получаются от менеджера АО НИТ"
echo "  - Храните учетные данные в HashiCorp Vault (см. 07-setup-vault.sh)"
echo "  - Используйте переменные окружения для безопасного хранения паролей"
echo ""
echo "Следующий шаг: настройка Harbor (03-setup-harbor.sh)"

