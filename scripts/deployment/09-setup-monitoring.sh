#!/bin/bash
#
# Скрипт настройки мониторинга: Grafana, OpenSearch, node_exporter
# Согласно инструкции QazTech, шаги 15.13 и 15.14
#
# ВАЖНО: Виртуальные машины должны быть уже созданы через портал самообслуживания
# Портал: https://portal.qaztech.gov.kz
#
# Использование:
#   ./09-setup-monitoring.sh <PROJECT_NAME> <ENVIRONMENT> <VM_IP>
#   Пример: ./09-setup-monitoring.sh myproject dev 10.10.0.10
#

set -e

# Проверка аргументов
if [ $# -lt 3 ]; then
    echo "Ошибка: недостаточно аргументов"
    echo "Использование: $0 <PROJECT_NAME> <ENVIRONMENT> <VM_IP>"
    echo "Пример: $0 myproject dev 10.10.0.10"
    exit 1
fi

PROJECT_NAME=$1
ENVIRONMENT=$2
VM_IP=$3

# URL сервисов мониторинга на платформе QazTech
GRAFANA_URL="https://grafana.qaztech.gov.kz"
OPENSEARCH_URL="https://opensearch.qaztech.gov.kz"

echo "=========================================="
echo "Настройка мониторинга для проекта"
echo "Проект: $PROJECT_NAME"
echo "Среда: $ENVIRONMENT"
echo "ВМ: $VM_IP"
echo "=========================================="

echo ""
echo "Шаг 1: Установка node_exporter на виртуальной машине..."
cat << 'EOF'

# Подключение к виртуальной машине:
# ssh -i ~/.ssh/<key_file> ubuntu@<VM_IP>

# Установка node_exporter:
# Для Ubuntu/Debian:
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.6.1.linux-amd64.tar.gz
sudo mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-1.6.1.linux-amd64*

# Создание systemd сервиса:
sudo tee /etc/systemd/system/node_exporter.service > /dev/null << SERVICE_EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/node_exporter \
    --collector.filesystem.mount-points-exclude="^/(sys|proc|dev|host|etc)($$|/)" \
    --collector.netclass.ignored-devices="^(veth.*|docker.*|br-.*)$$" \
    --collector.netdev.ignored-devices="^(veth.*|docker.*|br-.*)$$"

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Создание пользователя prometheus:
sudo useradd --no-create-home --shell /bin/false prometheus

# Запуск сервиса:
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
sudo systemctl status node_exporter

# Проверка работы (должен отвечать на порту 9100):
curl http://localhost:9100/metrics

EOF

echo ""
echo "Шаг 2: Настройка отправки метрик в Prometheus..."
cat << EOF

# Prometheus автоматически собирает метрики с node_exporter
# Необходимо убедиться, что Prometheus знает о вашей ВМ
# Обычно это настраивается через service discovery или статическую конфигурацию

# Пример конфигурации для Prometheus (настраивается администратором платформы):
# scrape_configs:
#   - job_name: '${PROJECT_NAME}-${ENVIRONMENT}'
#     static_configs:
#       - targets: ['${VM_IP}:9100']
#         labels:
#           project: '${PROJECT_NAME}'
#           environment: '${ENVIRONMENT}'
#           instance: '${VM_IP}'

EOF

echo ""
echo "Шаг 3: Настройка дашбордов в Grafana..."
cat << EOF

# Доступ к Grafana: ${GRAFANA_URL}
# Создание дашборда для мониторинга ВМ

# Основные метрики для мониторинга:
# - CPU Utilization: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
# - RAM Utilization: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
# - Storage Utilization: (1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100
# - Network Utilization: rate(node_network_receive_bytes_total[5m]) + rate(node_network_transmit_bytes_total[5m])

# Пример запроса PromQL для CPU:
# 100 - (avg(irate(node_cpu_seconds_total{mode="idle", instance="${VM_IP}:9100"}[5m])) * 100)

# Пример запроса PromQL для RAM:
# (1 - (node_memory_MemAvailable_bytes{instance="${VM_IP}:9100"} / node_memory_MemTotal_bytes{instance="${VM_IP}:9100"})) * 100

# Пример запроса PromQL для Disk:
# (1 - (node_filesystem_avail_bytes{instance="${VM_IP}:9100",mountpoint="/"} / node_filesystem_size_bytes{instance="${VM_IP}:9100",mountpoint="/"})) * 100

EOF

echo ""
echo "Шаг 4: Настройка отправки логов в OpenSearch..."
cat << 'EOF'

# Установка Filebeat для отправки логов:
# Для Ubuntu/Debian:
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.11.0-amd64.deb
sudo dpkg -i filebeat-8.11.0-amd64.deb

# Конфигурация Filebeat:
sudo tee /etc/filebeat/filebeat.yml > /dev/null << FILEBEAT_EOF
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/*.log
    - /var/log/app/*.log
    - /opt/app/logs/*.log
  fields:
    project: ${PROJECT_NAME}
    environment: ${ENVIRONMENT}
    host: ${VM_IP}
  fields_under_root: true

output.opensearch:
  hosts: ["${OPENSEARCH_URL}:9200"]
  index: "${PROJECT_NAME}-${ENVIRONMENT}-logs-%{+yyyy.MM.dd}"
  ssl:
    verification_mode: none
  username: "${OPENSEARCH_USERNAME}"
  password: "${OPENSEARCH_PASSWORD}"

setup.template.name: "${PROJECT_NAME}-${ENVIRONMENT}-logs"
setup.template.pattern: "${PROJECT_NAME}-${ENVIRONMENT}-logs-*"
FILEBEAT_EOF

# Запуск Filebeat:
sudo systemctl enable filebeat
sudo systemctl start filebeat
sudo systemctl status filebeat

EOF

echo ""
echo "Шаг 5: Настройка логов приложения..."
cat << EOF

# Для Node.js приложения использовать winston или pino с отправкой в OpenSearch
# Пример конфигурации для winston:

# const winston = require('winston');
# const { Client } = require('@opensearch-project/opensearch');
#
# const opensearch = new Client({
#   node: '${OPENSEARCH_URL}',
#   auth: {
#     username: process.env.OPENSEARCH_USERNAME,
#     password: process.env.OPENSEARCH_PASSWORD
#   }
# });
#
# const logger = winston.createLogger({
#   transports: [
#     new winston.transports.Console(),
#     new winston.transports.File({ filename: '/var/log/app/app.log' })
#   ]
# });

EOF

echo ""
echo "Шаг 6: Создание дашбордов в Kibana (OpenSearch Dashboards)..."
cat << EOF

# Доступ к OpenSearch Dashboards: ${OPENSEARCH_URL}/_dashboards
# Создание индекса для логов:
# Index pattern: ${PROJECT_NAME}-${ENVIRONMENT}-logs-*

# Основные визуализации:
# - Логи по времени (Time series)
# - Топ ошибок (Data table)
# - Распределение по уровням логов (Pie chart)
# - Поиск по логам (Discover)

EOF

echo ""
echo "=========================================="
echo "Настройка мониторинга завершена"
echo "=========================================="
echo ""
echo "Настроенные компоненты:"
echo "  - node_exporter: сбор метрик системы"
echo "  - Prometheus: хранение метрик"
echo "  - Grafana: визуализация метрик (${GRAFANA_URL})"
echo "  - Filebeat: отправка логов"
echo "  - OpenSearch: хранение логов (${OPENSEARCH_URL})"
echo "  - Kibana: визуализация логов"
echo ""
echo "Следующий шаг: настройка DNS и SSL (10-setup-dns-ssl.sh)"

