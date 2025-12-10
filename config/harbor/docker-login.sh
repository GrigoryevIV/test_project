#!/bin/bash
#
# Скрипт для входа в Harbor Docker Registry
# Согласно инструкции QazTech, шаг 15.7
#
# Использование:
#   ./docker-login.sh
#   Или установить переменные окружения HARBOR_USERNAME и HARBOR_PASSWORD
#

set -e

# URL Harbor на платформе QazTech
HARBOR_URL="https://harbor.qaztech.gov.kz"

# Получение учетных данных из переменных окружения или Vault
HARBOR_USERNAME=${HARBOR_USERNAME:-${VAULT_HARBOR_USERNAME}}
HARBOR_PASSWORD=${HARBOR_PASSWORD:-${VAULT_HARBOR_PASSWORD}}

if [ -z "$HARBOR_USERNAME" ] || [ -z "$HARBOR_PASSWORD" ]; then
    echo "Ошибка: не указаны учетные данные Harbor"
    echo "Установите переменные окружения:"
    echo "  export HARBOR_USERNAME=<ваш_логин>"
    echo "  export HARBOR_PASSWORD=<ваш_пароль>"
    echo ""
    echo "Или получите из Vault:"
    echo "  export VAULT_HARBOR_USERNAME=\$(vault kv get -field=username secret/<PROJECT>/<ENV>/harbor)"
    echo "  export VAULT_HARBOR_PASSWORD=\$(vault kv get -field=password secret/<PROJECT>/<ENV>/harbor)"
    exit 1
fi

echo "Вход в Harbor: $HARBOR_URL"
echo "$HARBOR_PASSWORD" | docker login "$HARBOR_URL" \
    --username "$HARBOR_USERNAME" \
    --password-stdin

if [ $? -eq 0 ]; then
    echo "✓ Успешный вход в Harbor"
else
    echo "✗ Ошибка входа в Harbor"
    exit 1
fi

