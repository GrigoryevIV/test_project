# Пошаговое руководство по развертыванию приложения на QazTech

Данное руководство содержит детальные инструкции по каждому шагу развертывания приложения на платформе QazTech с примерами кода и ссылками на соответствующие файлы проекта.

## Содержание

1. [Подготовительный этап](#подготовительный-этап)
2. [Создание организации и проекта](#создание-организации-и-проекта)
3. [Организация доступа](#организация-доступа)
4. [Развертывание инфраструктуры](#развертывание-инфраструктуры)
5. [Развертывание приложения](#развертывание-приложения)
   - [Шаг 15.5: Загрузка исходного кода](#шаг-155-загрузка-исходного-кода)
   - [Шаг 15.6: Подключение Nexus](#шаг-156-подключение-nexus)
   - [Шаг 15.7: Подключение Harbor](#шаг-157-подключение-harbor)
   - [Шаг 15.8: Установка и настройка ПО](#шаг-158-установка-и-настройка-по)
   - [Шаг 15.9: Настройка CI/CD](#шаг-159-настройка-cicd)
   - [Шаг 15.10: Подключение SonarQube](#шаг-1510-подключение-sonarqube)
   - [Шаг 15.11: Подключение SAST](#шаг-1511-подключение-sast)
   - [Шаг 15.12: Подключение DefectDojo](#шаг-1512-подключение-defectdojo)
   - [Шаг 15.13: Настройка мониторинга Grafana](#шаг-1513-настройка-мониторинга-grafana)
   - [Шаг 15.14: Настройка отправки логов в OpenSearch](#шаг-1514-настройка-отправки-логов-в-opensearch)
   - [Шаг 15.15: Подключение HashiCorp Vault](#шаг-1515-подключение-hashicorp-vault)
   - [Шаг 15.16: Вывод проекта в DEV](#шаг-1516-вывод-проекта-в-dev)

---

## Подготовительный этап

### Шаг 1: Подготовка документации

**Описание:** Подготовка технической документации для создания проекта на платформе.

**Действия:**
- Подготовить техническое задание (ТЗ) или СТПП
- Создать схему архитектуры серверов
- Подготовить список проектной команды
- Заполнить форму заявки

**Результат:** Пакет документов готов для отправки в МЦРИАП РК.

---

## Создание организации и проекта

### Шаг 2-4: Создание проекта на платформе

**Описание:** Создание проекта через портал самообслуживания.

**Портал:** https://portal.qaztech.gov.kz

**Действия:**
1. Менеджер АО НИТ создает организацию (если отсутствует)
2. Менеджер создает проект через портал
3. Автоматически создаются:
   - 5 сред: dev, test, stresstest, stage, prod
   - Внешние сети для каждой среды
   - Инструменты платформы (GitLab, Harbor, Nexus, SonarQube, DefectDojo, OpenSearch)

**Результат:** Проект создан, доступны все инструменты платформы.

---

## Организация доступа

### Шаг 5-9: Получение доступа к инструментам

**Описание:** Организация VPN-доступа и получение учетных данных.

**Инструменты платформы:**
- Портал самообслуживания: https://portal.qaztech.gov.kz
- GitLab: https://gitlab.qaztech.gov.kz
- Harbor: https://harbor.qaztech.gov.kz
- Nexus: https://nexus.qaztech.gov.kz
- SonarQube: https://sonarqube.qaztech.gov.kz
- Grafana: https://grafana.qaztech.gov.kz
- Redmine: https://redmine.qaztech.gov.kz

**Результат:** Получены VPN-сертификаты и учетные данные для всех инструментов.

---

## Развертывание инфраструктуры

### Шаг 10-14: Создание инфраструктуры

**ВАЖНО:** Инфраструктура создается через портал самообслуживания, а не через скрипты!

**Портал:** https://portal.qaztech.gov.kz

**Действия:**
1. Создание виртуальных машин через портал
2. Настройка сетей и групп безопасности
3. Создание роутеров и Floating IP
4. Настройка SSH-доступа

**Результат:** Инфраструктура готова для развертывания приложения.

---

## Развертывание приложения

### Шаг 15.5: Загрузка исходного кода

**Описание:** Загрузка исходного кода приложения в GitLab репозиторий.

**Скрипт:** [`scripts/deployment/01-upload-code-to-gitlab.sh`](scripts/deployment/01-upload-code-to-gitlab.sh)

**Пример выполнения:**
```bash
./scripts/deployment/01-upload-code-to-gitlab.sh myproject
```

**Что делает скрипт:**
- Проверяет наличие Git репозитория
- Предоставляет команды для добавления удаленного репозитория GitLab
- Помогает загрузить код в репозиторий

**Пример кода из скрипта:**
<details>
<summary>Показать пример команд Git</summary>

```bash
# Добавить удаленный репозиторий
git remote add origin https://gitlab.qaztech.gov.kz/myproject/myproject.git

# Добавить все файлы
git add .

# Создать коммит
git commit -m "Initial commit: развертывание на QazTech"

# Отправить код
git push -u origin main
```
</details>

**Результат:** Исходный код загружен в GitLab.

---

### Шаг 15.6: Подключение Nexus

**Описание:** Настройка подключения к репозиторию пакетов и библиотек Nexus.

**Скрипт:** [`scripts/deployment/02-setup-nexus.sh`](scripts/deployment/02-setup-nexus.sh)

**Конфигурационные файлы:**
- [`config/nexus/.npmrc`](config/nexus/.npmrc) - Конфигурация NPM
- [`config/nexus/maven-settings.xml`](config/nexus/maven-settings.xml) - Конфигурация Maven
- [`config/nexus/yum-repo.conf`](config/nexus/yum-repo.conf) - Конфигурация YUM

**Пример выполнения:**
```bash
./scripts/deployment/02-setup-nexus.sh myproject
```

**Что делает скрипт:**
- Настраивает NPM для работы с Nexus
- Настраивает Maven (для Java проектов)
- Настраивает YUM репозиторий
- Настраивает Gradle (для Kotlin/Java проектов)

**Пример кода настройки NPM:**
<details>
<summary>Показать пример настройки NPM</summary>

```bash
# Скопировать конфигурацию
cp config/nexus/.npmrc backend/.npmrc

# Заменить имя проекта
sed -i 's/<PROJECT_NAME>/myproject/g' backend/.npmrc

# Установить переменные окружения
export NEXUS_USERNAME="<ваш_логин>"
export NEXUS_PASSWORD="<ваш_пароль>"
export NEXUS_AUTH_TOKEN=$(echo -n "$NEXUS_USERNAME:$NEXUS_PASSWORD" | base64)
```
</details>

**Пример конфигурации NPM:**
<details>
<summary>Показать содержимое .npmrc</summary>

См. файл: [`config/nexus/.npmrc`](config/nexus/.npmrc)

```npmrc
registry=https://nexus.qaztech.gov.kz/repository/myproject-repo/
always-auth=true
_auth=${NEXUS_AUTH_TOKEN}
```
</details>

**Результат:** Nexus настроен, зависимости устанавливаются из Nexus репозитория.

---

### Шаг 15.7: Подключение Harbor

**Описание:** Настройка интеграции с Harbor для автоматической доставки Docker-образов.

**Скрипт:** [`scripts/deployment/03-setup-harbor.sh`](scripts/deployment/03-setup-harbor.sh)

**Конфигурационные файлы:**
- [`config/harbor/docker-login.sh`](config/harbor/docker-login.sh) - Скрипт входа в Harbor
- [`.gitlab-ci.yml`](.gitlab-ci.yml) - Конфигурация CI/CD
- [`gitlab-ci/build.yml`](gitlab-ci/build.yml) - Этапы сборки

**Пример выполнения:**
```bash
./scripts/deployment/03-setup-harbor.sh myproject
```

**Что делает скрипт:**
- Настраивает Docker для работы с Harbor
- Помогает настроить GitLab CI/CD для автоматической публикации образов
- Предоставляет команды для тегирования и публикации образов

**Пример кода входа в Harbor:**
<details>
<summary>Показать пример входа в Harbor</summary>

```bash
# Вход в Harbor
docker login https://harbor.qaztech.gov.kz \
  --username <ваш_логин> \
  --password <ваш_пароль>
```
</details>

**Пример конфигурации GitLab CI/CD:**
<details>
<summary>Показать пример job для сборки и публикации</summary>

См. файл: [`gitlab-ci/build.yml`](gitlab-ci/build.yml)

```yaml
build:backend:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - echo "$HARBOR_PASSWORD" | docker login $HARBOR_URL --username "$HARBOR_USERNAME" --password-stdin
  script:
    - docker build -t $HARBOR_URL/$CI_PROJECT_NAME/backend:$CI_COMMIT_SHORT_SHA .
    - docker push $HARBOR_URL/$CI_PROJECT_NAME/backend:$CI_COMMIT_SHORT_SHA
```
</details>

**Результат:** Harbor настроен, Docker-образы публикуются автоматически через CI/CD.

---

### Шаг 15.8: Установка и настройка ПО

**Описание:** Установка необходимого ПО через Nexus репозиторий и настройка согласно требованиям проекта.

**Скрипт:** [`scripts/deployment/04-setup-software.sh`](scripts/deployment/04-setup-software.sh)

**Пример выполнения:**
```bash
./scripts/deployment/04-setup-software.sh myproject dev
```

**Что делает скрипт:**
- Устанавливает системные пакеты через Nexus
- Устанавливает зависимости проекта
- Настраивает переменные окружения
- Помогает настроить systemd сервисы

**Пример кода установки системных пакетов:**
<details>
<summary>Показать пример установки пакетов</summary>

```bash
# Обновление списка пакетов
sudo yum clean all
sudo yum makecache

# Установка базовых пакетов
sudo yum install -y \
    git \
    curl \
    wget \
    docker \
    docker-compose

# Запуск Docker
sudo systemctl enable docker
sudo systemctl start docker
```
</details>

**Пример настройки переменных окружения:**
<details>
<summary>Показать пример .env файла</summary>

См. файл: [`backend/.env.example`](backend/.env.example)

```env
NODE_ENV=production
PORT=3000
DATABASE_URL=postgres://user:pass@host:5432/db
VAULT_ADDR=https://vault.qaztech.gov.kz
```
</details>

**Результат:** Необходимое ПО установлено и настроено.

---

### Шаг 15.9: Настройка CI/CD

**Описание:** Создание `.gitlab-ci.yml` с этапами build, test, security, deploy.

**Скрипт:** [`scripts/deployment/05-setup-cicd.sh`](scripts/deployment/05-setup-cicd.sh)

**Конфигурационные файлы:**
- [`.gitlab-ci.yml`](.gitlab-ci.yml) - Основной файл CI/CD
- [`gitlab-ci/build.yml`](gitlab-ci/build.yml) - Этапы сборки
- [`gitlab-ci/test.yml`](gitlab-ci/test.yml) - Этапы тестирования
- [`gitlab-ci/security.yml`](gitlab-ci/security.yml) - Проверка безопасности
- [`gitlab-ci/deploy.yml`](gitlab-ci/deploy.yml) - Развертывание

**Пример выполнения:**
```bash
./scripts/deployment/05-setup-cicd.sh myproject
```

**Что делает скрипт:**
- Проверяет наличие `.gitlab-ci.yml`
- Помогает настроить переменные CI/CD в GitLab
- Предоставляет инструкции по настройке GitLab Runner

**Пример структуры CI/CD:**
<details>
<summary>Показать структуру пайплайна</summary>

См. файл: [`.gitlab-ci.yml`](.gitlab-ci.yml)

```yaml
stages:
  - build
  - test
  - security
  - sonarqube
  - deploy

variables:
  HARBOR_URL: "https://harbor.qaztech.gov.kz"
  NEXUS_URL: "https://nexus.qaztech.gov.kz"
  SONARQUBE_URL: "https://sonarqube.qaztech.gov.kz"

include:
  - local: 'gitlab-ci/build.yml'
  - local: 'gitlab-ci/test.yml'
  - local: 'gitlab-ci/security.yml'
  - local: 'gitlab-ci/sonarqube.yml'
  - local: 'gitlab-ci/deploy.yml'
```
</details>

**Пример job для тестирования:**
<details>
<summary>Показать пример job тестирования</summary>

См. файл: [`gitlab-ci/test.yml`](gitlab-ci/test.yml)

```yaml
test:backend:
  stage: test
  image: node:18-alpine
  script:
    - cd backend
    - npm ci
    - npm test
  artifacts:
    reports:
      junit: backend/junit.xml
```
</details>

**Результат:** CI/CD настроен, пайплайн автоматически собирает, тестирует и развертывает приложение.

---

### Шаг 15.10: Подключение SonarQube

**Описание:** Добавление job в `.gitlab-ci.yml` для автоматического анализа кода.

**Скрипт:** [`scripts/deployment/06-setup-sonarqube.sh`](scripts/deployment/06-setup-sonarqube.sh)

**Конфигурационные файлы:**
- [`gitlab-ci/sonarqube.yml`](gitlab-ci/sonarqube.yml) - Конфигурация SonarQube

**Пример выполнения:**
```bash
./scripts/deployment/06-setup-sonarqube.sh myproject
```

**Что делает скрипт:**
- Помогает создать проект в SonarQube
- Помогает получить токен доступа
- Проверяет конфигурацию в `.gitlab-ci.yml`

**Пример конфигурации SonarQube:**
<details>
<summary>Показать пример job SonarQube</summary>

См. файл: [`gitlab-ci/sonarqube.yml`](gitlab-ci/sonarqube.yml)

```yaml
sonarqube:backend:
  stage: sonarqube
  image: sonarsource/sonar-scanner-cli:latest
  script:
    - sonar-scanner \
        -Dsonar.projectKey=${CI_PROJECT_NAME}-backend \
        -Dsonar.host.url=${SONARQUBE_URL} \
        -Dsonar.login=${SONARQUBE_TOKEN} \
        -Dsonar.qualitygate.wait=true
```
</details>

**Результат:** SonarQube подключен, анализ кода выполняется автоматически.

---

### Шаг 15.11: Подключение SAST

**Описание:** Настройка CI/CD Security для автоматического сканирования уязвимостей в коде.

**Скрипт:** [`scripts/deployment/07-setup-sast.sh`](scripts/deployment/07-setup-sast.sh)

**Конфигурационные файлы:**
- [`gitlab-ci/security.yml`](gitlab-ci/security.yml) - Конфигурация безопасности

**Пример выполнения:**
```bash
./scripts/deployment/07-setup-sast.sh myproject
```

**Что делает скрипт:**
- Объясняет как включить SAST в GitLab
- Помогает настроить правила безопасности
- Объясняет как просматривать результаты

**Пример конфигурации SAST:**
<details>
<summary>Показать пример job SAST</summary>

См. файл: [`gitlab-ci/security.yml`](gitlab-ci/security.yml)

```yaml
sast:
  stage: security
  image:
    name: "registry.gitlab.com/security-products/sast:latest"
  script:
    - /analyzer run
  artifacts:
    reports:
      sast: gl-sast-report.json
```
</details>

**Результат:** SAST настроен, уязвимости сканируются автоматически.

---

### Шаг 15.12: Подключение DefectDojo

**Описание:** Добавление job для автоматической загрузки отчетов о уязвимостях в DefectDojo.

**Скрипт:** [`scripts/deployment/08-setup-defectdojo.sh`](scripts/deployment/08-setup-defectdojo.sh)

**Конфигурационные файлы:**
- [`gitlab-ci/security.yml`](gitlab-ci/security.yml) - Job для загрузки в DefectDojo

**Пример выполнения:**
```bash
./scripts/deployment/08-setup-defectdojo.sh myproject
```

**Что делает скрипт:**
- Помогает создать проект в DefectDojo
- Помогает получить API токен
- Проверяет конфигурацию в `.gitlab-ci.yml`

**Пример конфигурации DefectDojo:**
<details>
<summary>Показать пример job DefectDojo</summary>

См. файл: [`gitlab-ci/security.yml`](gitlab-ci/security.yml)

```yaml
defectdojo:
  stage: security
  script:
    - |
      curl -X POST \
        -H "Authorization: Token $DEFECTDOJO_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d @defectdojo-report.json \
        "$DEFECTDOJO_URL/api/v2/import-scan/"
```
</details>

**Результат:** DefectDojo подключен, отчеты о уязвимостях загружаются автоматически.

---

### Шаг 15.13: Настройка мониторинга Grafana

**Описание:** Установка node_exporter на виртуальных машинах и настройка дашбордов в Grafana.

**Скрипт:** [`scripts/deployment/09-setup-monitoring.sh`](scripts/deployment/09-setup-monitoring.sh)

**Конфигурационные файлы:**
- [`config/monitoring/grafana-dashboard.json`](config/monitoring/grafana-dashboard.json) - Дашборд Grafana

**Пример выполнения:**
```bash
./scripts/deployment/09-setup-monitoring.sh myproject dev <VM_IP>
```

**Что делает скрипт:**
- Устанавливает node_exporter на виртуальной машине
- Настраивает отправку метрик в Prometheus
- Помогает настроить дашборды в Grafana

**Пример установки node_exporter:**
<details>
<summary>Показать пример установки node_exporter</summary>

```bash
# Установка node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.6.1.linux-amd64.tar.gz
sudo mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/

# Создание systemd сервиса
sudo tee /etc/systemd/system/node_exporter.service > /dev/null << EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Запуск сервиса
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
```
</details>

**Пример дашборда Grafana:**
<details>
<summary>Показать пример дашборда</summary>

См. файл: [`config/monitoring/grafana-dashboard.json`](config/monitoring/grafana-dashboard.json)

Дашборд включает метрики:
- CPU Utilization
- RAM Utilization
- Storage Utilization
- Network Utilization
</details>

**Результат:** Мониторинг настроен, метрики отображаются в Grafana.

---

### Шаг 15.14: Настройка отправки логов в OpenSearch

**Описание:** Настройка сбора и отправки логов приложений в OpenSearch.

**Скрипт:** [`scripts/deployment/09-setup-monitoring.sh`](scripts/deployment/09-setup-monitoring.sh) (часть скрипта)

**Конфигурационные файлы:**
- [`config/monitoring/filebeat.yml.example`](config/monitoring/filebeat.yml.example) - Конфигурация Filebeat

**Пример выполнения:**
```bash
# Часть скрипта 09-setup-monitoring.sh
```

**Что делает скрипт:**
- Устанавливает Filebeat на виртуальной машине
- Настраивает сбор логов приложения
- Настраивает отправку логов в OpenSearch

**Пример конфигурации Filebeat:**
<details>
<summary>Показать пример конфигурации Filebeat</summary>

См. файл: [`config/monitoring/filebeat.yml.example`](config/monitoring/filebeat.yml.example)

```yaml
filebeat.inputs:
  - type: log
    paths:
      - /var/log/app/*.log
    fields:
      project: myproject
      environment: dev

output.opensearch:
  hosts: ["https://opensearch.qaztech.gov.kz:9200"]
  index: "myproject-dev-logs-%{+yyyy.MM.dd}"
```
</details>

**Результат:** Логи отправляются в OpenSearch, доступны для анализа.

---

### Шаг 15.15: Подключение HashiCorp Vault

**Описание:** Настройка интеграции с Vault для безопасного хранения секретов.

**Скрипт:** [`scripts/deployment/11-setup-vault.sh`](scripts/deployment/11-setup-vault.sh)

**Конфигурационные файлы:**
- [`config/vault/vault-config.example.js`](config/vault/vault-config.example.js) - Пример конфигурации Vault
- [`backend/vault-integration.js`](backend/vault-integration.js) - Модуль интеграции с Vault

**Пример выполнения:**
```bash
./scripts/deployment/11-setup-vault.sh myproject dev
```

**Что делает скрипт:**
- Помогает установить Vault CLI
- Помогает создать секреты в Vault
- Объясняет интеграцию с приложением

**Пример создания секретов в Vault:**
<details>
<summary>Показать пример создания секретов</summary>

```bash
# Секреты базы данных
vault kv put secret/myproject/dev/database \
  host=db.example.com \
  port=5432 \
  database=mydb \
  username=myuser \
  password=mypassword

# Секреты Nexus
vault kv put secret/myproject/dev/nexus \
  url=https://nexus.qaztech.gov.kz \
  username=nexus_user \
  password=nexus_password
```
</details>

**Пример интеграции с приложением:**
<details>
<summary>Показать пример использования Vault в приложении</summary>

См. файл: [`backend/vault-integration.js`](backend/vault-integration.js)

```javascript
const vaultIntegration = require('./vault-integration');

// Получение конфигурации БД из Vault
async function initDatabase() {
  const dbConfig = await vaultIntegration.getDatabaseConfig();
  const connectionString = dbConfig.connectionString;
  // Использование connectionString для подключения к БД
}
```
</details>

**Пример конфигурации Vault:**
<details>
<summary>Показать пример конфигурации</summary>

См. файл: [`config/vault/vault-config.example.js`](config/vault/vault-config.example.js)
</details>

**Результат:** Vault настроен, секреты хранятся безопасно, приложение получает их динамически.

---

### Шаг 15.16: Вывод проекта в DEV

**Описание:** Прописание DNS-записей для доменных имен и подключение SSL-сертификатов.

**Скрипт:** [`scripts/deployment/10-setup-dns-ssl.sh`](scripts/deployment/10-setup-dns-ssl.sh)

**Пример выполнения:**
```bash
./scripts/deployment/10-setup-dns-ssl.sh myproject dev <FRONTEND_IP> <BACKEND_IP> myproject.qaztech.gov.kz
```

**Что делает скрипт:**
- Помогает настроить DNS записи
- Помогает получить SSL сертификаты (Let's Encrypt)
- Настраивает Nginx с HTTPS

**Пример настройки DNS:**
<details>
<summary>Показать пример DNS записей</summary>

```
# A-запись для frontend
dev.myproject.qaztech.gov.kz -> <FRONTEND_IP>

# A-запись для backend API
api-dev.myproject.qaztech.gov.kz -> <BACKEND_IP>
```
</details>

**Пример получения SSL сертификата:**
<details>
<summary>Показать пример получения SSL</summary>

```bash
# Установка certbot
sudo apt-get install certbot python3-certbot-nginx

# Получение сертификата
sudo certbot certonly --standalone \
  -d dev.myproject.qaztech.gov.kz \
  --email admin@myproject.qaztech.gov.kz \
  --agree-tos \
  --non-interactive
```
</details>

**Пример конфигурации Nginx:**
<details>
<summary>Показать пример конфигурации Nginx</summary>

```nginx
server {
    listen 443 ssl http2;
    server_name dev.myproject.qaztech.gov.kz;
    
    ssl_certificate /etc/letsencrypt/live/dev.myproject.qaztech.gov.kz/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/dev.myproject.qaztech.gov.kz/privkey.pem;
    
    location / {
        root /usr/share/nginx/html;
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://<BACKEND_IP>:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```
</details>

**Результат:** Приложение доступно по HTTPS с валидным SSL сертификатом.

---

## Развертывание в другие среды

### TEST, STRESSTEST, STAGE, PROD

**Описание:** Развертывание в другие среды выполняется аналогично DEV среде.

**Действия:**
1. Повторить шаги 15.5-15.16 для каждой среды
2. Использовать соответствующие переменные окружения
3. Настроить DNS для каждой среды

**Пример развертывания через CI/CD:**
<details>
<summary>Показать пример развертывания</summary>

См. файл: [`gitlab-ci/deploy.yml`](gitlab-ci/deploy.yml)

```yaml
deploy:prod:
  stage: deploy
  script:
    - ssh ubuntu@$PROD_SERVER_IP << 'DEPLOY_SCRIPT'
        docker pull $HARBOR_URL/$CI_PROJECT_NAME/backend:latest
        docker stop backend || true
        docker run -d --name backend \
          -e DATABASE_URL="$PROD_DATABASE_URL" \
          $HARBOR_URL/$CI_PROJECT_NAME/backend:latest
      DEPLOY_SCRIPT
  only:
    - main
  when: manual
```
</details>

---

## Полезные ссылки

### Документация проекта
- [DEPLOYMENT.md](DEPLOYMENT.md) - Краткая инструкция по развертыванию
- [QAZTECH_SETUP.md](QAZTECH_SETUP.md) - Детальное описание настройки компонентов
- [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) - Настройка сред разработки

### Внешние ресурсы
- [Портал самообслуживания](https://portal.qaztech.gov.kz) - Управление проектами и ресурсами
- [Документация QazTech](https://docs.qaztech.gov.kz) - Официальная документация платформы

---

## Поддержка

- Email: support@qaztech.gov.kz
- Портал: https://portal.qaztech.gov.kz
- Время работы: Пн-Пт, 9:00-18:00 (GMT+6)

