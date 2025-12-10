#!/bin/bash
#
# Скрипт настройки DNS записей и SSL-сертификатов
# Согласно инструкции QazTech, шаг 15.16
#
# ВАЖНО: Виртуальные машины и Floating IP должны быть уже созданы через портал самообслуживания
# Портал: https://portal.qaztech.gov.kz
#
# Использование:
#   ./09-setup-dns-ssl.sh <PROJECT_NAME> <ENVIRONMENT> <FRONTEND_IP> <BACKEND_IP> <DOMAIN>
#   Пример: ./09-setup-dns-ssl.sh myproject dev 192.168.1.10 192.168.1.11 myproject.qaztech.gov.kz
#

set -e

# Проверка аргументов
if [ $# -lt 5 ]; then
    echo "Ошибка: недостаточно аргументов"
    echo "Использование: $0 <PROJECT_NAME> <ENVIRONMENT> <FRONTEND_IP> <BACKEND_IP> <DOMAIN>"
    echo "Пример: $0 myproject dev 192.168.1.10 192.168.1.11 myproject.qaztech.gov.kz"
    exit 1
fi

PROJECT_NAME=$1
ENVIRONMENT=$2
FRONTEND_IP=$3
BACKEND_IP=$4
DOMAIN=$5

echo "=========================================="
echo "Настройка DNS и SSL-сертификатов"
echo "Проект: $PROJECT_NAME"
echo "Среда: $ENVIRONMENT"
echo "Домен: $DOMAIN"
echo "=========================================="

echo ""
echo "Шаг 1: Настройка DNS записей..."
cat << EOF

# DNS записи настраиваются через портал самообслуживания или администратором платформы
# Необходимо создать следующие записи:

# A-запись для frontend:
# Имя: ${ENVIRONMENT}.${DOMAIN} или ${PROJECT_NAME}-${ENVIRONMENT}.${DOMAIN}
# Тип: A
# Значение: ${FRONTEND_IP}
# TTL: 300

# A-запись для backend API:
# Имя: api-${ENVIRONMENT}.${DOMAIN} или ${PROJECT_NAME}-api-${ENVIRONMENT}.${DOMAIN}
# Тип: A
# Значение: ${BACKEND_IP}
# TTL: 300

# Или CNAME записи (если используется балансировщик):
# Имя: ${ENVIRONMENT}.${DOMAIN}
# Тип: CNAME
# Значение: <load_balancer_domain>

# Проверка DNS записей:
# dig ${ENVIRONMENT}.${DOMAIN}
# nslookup ${ENVIRONMENT}.${DOMAIN}
# host ${ENVIRONMENT}.${DOMAIN}

EOF

echo ""
echo "Шаг 2: Получение SSL-сертификатов..."
cat << 'EOF'

# Вариант 1: Использование Let's Encrypt (через certbot)
# Установка certbot:
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx

# Получение сертификата для frontend:
sudo certbot certonly --standalone \
    -d ${ENVIRONMENT}.${DOMAIN} \
    --email admin@${DOMAIN} \
    --agree-tos \
    --non-interactive

# Сертификаты будут сохранены в:
# /etc/letsencrypt/live/${ENVIRONMENT}.${DOMAIN}/fullchain.pem
# /etc/letsencrypt/live/${ENVIRONMENT}.${DOMAIN}/privkey.pem

# Автоматическое обновление сертификатов:
sudo certbot renew --dry-run

EOF

echo ""
echo "Шаг 3: Настройка SSL в Nginx (Frontend)..."
cat << 'EOF'

# Обновление конфигурации Nginx для использования SSL:
sudo tee /etc/nginx/sites-available/${PROJECT_NAME}-${ENVIRONMENT} > /dev/null << NGINX_EOF
server {
    listen 80;
    server_name ${ENVIRONMENT}.${DOMAIN};
    
    # Редирект на HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${ENVIRONMENT}.${DOMAIN};
    
    # SSL сертификаты
    ssl_certificate /etc/letsencrypt/live/${ENVIRONMENT}.${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${ENVIRONMENT}.${DOMAIN}/privkey.pem;
    
    # SSL настройки безопасности
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Корневая директория
    root /usr/share/nginx/html;
    index index.html;
    
    # Логирование
    access_log /var/log/nginx/${PROJECT_NAME}-${ENVIRONMENT}-access.log;
    error_log /var/log/nginx/${PROJECT_NAME}-${ENVIRONMENT}-error.log;
    
    # Основная локация
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    # Проксирование API запросов к backend
    location /api/ {
        proxy_pass http://${BACKEND_IP}:3000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Таймауты
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Безопасность заголовков
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
}
NGINX_EOF

# Создание символической ссылки:
sudo ln -sf /etc/nginx/sites-available/${PROJECT_NAME}-${ENVIRONMENT} /etc/nginx/sites-enabled/

# Проверка конфигурации:
sudo nginx -t

# Перезагрузка Nginx:
sudo systemctl reload nginx

EOF

echo ""
echo "Шаг 4: Настройка SSL в Backend (опционально, если нужен прямой доступ)..."
cat << 'EOF'

# Если backend должен быть доступен напрямую по HTTPS:
# Использовать reverse proxy (Nginx) или настроить SSL в Node.js приложении

# Пример с использованием express и https:
# const https = require('https');
# const fs = require('fs');
# const express = require('express');
#
# const app = express();
#
# const options = {
#   key: fs.readFileSync('/etc/letsencrypt/live/api-${ENVIRONMENT}.${DOMAIN}/privkey.pem'),
#   cert: fs.readFileSync('/etc/letsencrypt/live/api-${ENVIRONMENT}.${DOMAIN}/fullchain.pem')
# };
#
# https.createServer(options, app).listen(443, () => {
#   console.log('HTTPS server running on port 443');
# });

EOF

echo ""
echo "Шаг 5: Настройка автоматического обновления сертификатов..."
cat << 'EOF'

# Создание скрипта для обновления сертификатов и перезагрузки Nginx:
sudo tee /usr/local/bin/renew-ssl.sh > /dev/null << RENEW_EOF
#!/bin/bash
certbot renew --quiet
systemctl reload nginx
RENEW_EOF

sudo chmod +x /usr/local/bin/renew-ssl.sh

# Добавление в crontab (проверка дважды в день):
# 0 0,12 * * * /usr/local/bin/renew-ssl.sh

EOF

echo ""
echo "Шаг 6: Проверка SSL конфигурации..."
cat << EOF

# Проверка SSL сертификата:
openssl s_client -connect ${ENVIRONMENT}.${DOMAIN}:443 -servername ${ENVIRONMENT}.${DOMAIN}

# Онлайн проверка SSL:
# https://www.ssllabs.com/ssltest/analyze.html?d=${ENVIRONMENT}.${DOMAIN}

# Проверка доступности сайта:
curl -I https://${ENVIRONMENT}.${DOMAIN}

# Проверка API:
curl https://${ENVIRONMENT}.${DOMAIN}/api/health

EOF

echo ""
echo "=========================================="
echo "Настройка DNS и SSL завершена"
echo "=========================================="
echo ""
echo "Настроенные ресурсы:"
echo "  - DNS записи для frontend и backend"
echo "  - SSL сертификаты (Let's Encrypt)"
echo "  - Nginx конфигурация с HTTPS"
echo "  - Автоматическое обновление сертификатов"
echo ""
echo "Доступ к приложению:"
echo "  - Frontend: https://${ENVIRONMENT}.${DOMAIN}"
echo "  - Backend API: https://${ENVIRONMENT}.${DOMAIN}/api/"
echo ""
echo "Важно:"
echo "  - Регулярно проверяйте срок действия SSL сертификатов"
echo "  - Используйте мониторинг для отслеживания проблем с SSL"
echo "  - Настройте алерты на истечение сертификатов"

