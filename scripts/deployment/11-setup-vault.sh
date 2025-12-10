#!/bin/bash
#
# Скрипт настройки интеграции с HashiCorp Vault для управления секретами
# Согласно инструкции QazTech, шаг 15.15
#
# Использование:
#   ./07-setup-vault.sh <PROJECT_NAME> <ENVIRONMENT>
#   Пример: ./07-setup-vault.sh myproject dev
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

# URL Vault на платформе QazTech
VAULT_ADDR="https://vault.qaztech.gov.kz"

# ВАЖНО: Виртуальные машины должны быть уже созданы через портал самообслуживания
# Портал: https://portal.qaztech.gov.kz
VAULT_PATH="secret/${PROJECT_NAME}/${ENVIRONMENT}"

echo "=========================================="
echo "Настройка интеграции с HashiCorp Vault"
echo "Проект: $PROJECT_NAME"
echo "Среда: $ENVIRONMENT"
echo "=========================================="

echo ""
echo "Шаг 1: Установка Vault CLI (если не установлен)..."
cat << EOF

# Для Ubuntu/Debian:
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com \$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault

# Для CentOS/RHEL:
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install vault

EOF

echo ""
echo "Шаг 2: Настройка переменных окружения для Vault..."
cat << EOF

# Добавить в ~/.bashrc или /etc/environment:
export VAULT_ADDR="${VAULT_ADDR}"
export VAULT_TOKEN="<ваш_vault_token>"
# Или использовать файл с токеном:
export VAULT_TOKEN_FILE="~/.vault-token"

EOF

echo ""
echo "Шаг 3: Вход в Vault..."
cat << EOF

# Вход через токен:
vault auth -address=${VAULT_ADDR} <ваш_токен>

# Или через LDAP (если настроено):
vault auth -method=ldap username=<ваш_логин>

# Проверка входа:
vault token lookup

EOF

echo ""
echo "Шаг 4: Создание секретов для приложения..."
cat << EOF

# Создание секретов для базы данных:
vault kv put ${VAULT_PATH}/database \\
    host="<db_host>" \\
    port="5432" \\
    database="<db_name>" \\
    username="<db_user>" \\
    password="<db_password>"

# Создание секретов для внешних сервисов:
vault kv put ${VAULT_PATH}/nexus \\
    url="https://nexus.qaztech.gov.kz" \\
    username="<nexus_user>" \\
    password="<nexus_password>"

vault kv put ${VAULT_PATH}/harbor \\
    url="https://harbor.qaztech.gov.kz" \\
    username="<harbor_user>" \\
    password="<harbor_password>"

# Создание секретов для API ключей:
vault kv put ${VAULT_PATH}/api \\
    api_key="<api_key>" \\
    api_secret="<api_secret>"

# Просмотр секретов:
vault kv get ${VAULT_PATH}/database

EOF

echo ""
echo "Шаг 5: Настройка политик доступа (для разных ролей)..."
cat << EOF

# Создание политики для чтения секретов приложения:
vault policy write ${PROJECT_NAME}-${ENVIRONMENT}-read - << POLICY_EOF
# Политика для чтения секретов проекта ${PROJECT_NAME} в среде ${ENVIRONMENT}
path "${VAULT_PATH}/*" {
  capabilities = ["read", "list"]
}
POLICY_EOF

# Привязка политики к роли:
vault write auth/ldap/users/<username> policies=${PROJECT_NAME}-${ENVIRONMENT}-read

EOF

echo ""
echo "Шаг 6: Интеграция с приложением (пример для Node.js)..."
cat << 'EOF'

# В приложении использовать библиотеку node-vault или vault-client
# Пример кода для получения секретов:

# Установка зависимостей:
# npm install node-vault

# Пример использования в backend/index.js:
# const vault = require('node-vault')({
#   apiVersion: 'v1',
#   endpoint: process.env.VAULT_ADDR,
#   token: process.env.VAULT_TOKEN
# });
#
# async function getDatabaseConfig() {
#   const secret = await vault.read(`secret/${PROJECT_NAME}/${ENVIRONMENT}/database`);
#   return {
#     host: secret.data.host,
#     port: secret.data.port,
#     database: secret.data.database,
#     username: secret.data.username,
#     password: secret.data.password
#   };
# }

EOF

echo ""
echo "Шаг 7: Настройка автоматического обновления токенов..."
cat << EOF

# Создание скрипта для обновления токена (если используется AppRole):
cat > /usr/local/bin/vault-renew-token.sh << SCRIPT_EOF
#!/bin/bash
# Обновление Vault токена
export VAULT_ADDR="${VAULT_ADDR}"
vault token renew
SCRIPT_EOF

chmod +x /usr/local/bin/vault-renew-token.sh

# Добавление в crontab для автоматического обновления (каждые 6 часов):
# 0 */6 * * * /usr/local/bin/vault-renew-token.sh

EOF

echo ""
echo "=========================================="
echo "Настройка Vault завершена"
echo "=========================================="
echo ""
echo "Важно:"
echo "  - НИКОГДА не храните секреты в коде или конфигурационных файлах"
echo "  - Используйте Vault для всех паролей, ключей и токенов"
echo "  - Регулярно ротируйте секреты"
echo "  - Используйте минимальные права доступа (принцип наименьших привилегий)"
echo "  - Логируйте все обращения к Vault для аудита"
echo ""
echo "Развертывание приложения завершено!"

