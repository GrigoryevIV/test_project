# Детальное описание настройки компонентов QazTech

Данный документ содержит подробные инструкции по настройке каждого компонента платформы QazTech для проекта.

**Для пошагового руководства по развертыванию см. [STEP_BY_STEP_GUIDE.md](STEP_BY_STEP_GUIDE.md)**

## Содержание

1. [GitLab](#gitlab)
2. [Harbor](#harbor)
3. [Nexus](#nexus)
4. [SonarQube](#sonarqube)
5. [HashiCorp Vault](#hashicorp-vault)
6. [Grafana](#grafana)
7. [OpenSearch](#opensearch)
8. [DefectDojo](#defectdojo)

## GitLab

**URL:** https://gitlab.qaztech.gov.kz

### Настройка проекта

1. Войти в GitLab: https://gitlab.qaztech.gov.kz
2. Создать группу проекта (если не создана автоматически)
3. Создать репозитории для frontend и backend компонентов

### Настройка CI/CD переменных

Перейти в Settings -> CI/CD -> Variables и добавить:

**Harbor:**
- `HARBOR_URL` = `https://harbor.qaztech.gov.kz`
- `HARBOR_USERNAME` = `<ваш_логин>` (masked)
- `HARBOR_PASSWORD` = `<ваш_пароль>` (masked, protected)

**Nexus:**
- `NEXUS_URL` = `https://nexus.qaztech.gov.kz`
- `NEXUS_USERNAME` = `<ваш_логин>` (masked)
- `NEXUS_PASSWORD` = `<ваш_пароль>` (masked, protected)

**SonarQube:**
- `SONARQUBE_URL` = `https://sonarqube.qaztech.gov.kz`
- `SONARQUBE_TOKEN` = `<ваш_токен>` (masked, protected)

**SSH для развертывания:**
- `SSH_PRIVATE_KEY` = `<приватный_ssh_ключ>` (masked, protected)

**IP адреса серверов:**
- `DEV_SERVER_IP` = `<IP_адрес_DEV_сервера>`
- `TEST_SERVER_IP` = `<IP_адрес_TEST_сервера>`
- `STAGE_SERVER_IP` = `<IP_адрес_STAGE_сервера>`
- `PROD_SERVER_IP` = `<IP_адрес_PROD_сервера>`

**URL баз данных:**
- `DEV_DATABASE_URL` = `postgres://user:pass@host:5432/db`
- `TEST_DATABASE_URL` = `postgres://user:pass@host:5432/db`
- `STAGE_DATABASE_URL` = `postgres://user:pass@host:5432/db`
- `PROD_DATABASE_URL` = `postgres://user:pass@host:5432/db`

### Настройка GitLab Runner

GitLab Runner должен быть установлен на виртуальной машине или использовать shared runners платформы.

## Harbor

**URL:** https://harbor.qaztech.gov.kz

### Вход в Harbor

```bash
docker login https://harbor.qaztech.gov.kz \
  --username <ваш_логин> \
  --password <ваш_пароль>
```

### Создание проектов

Проекты в Harbor создаются автоматически при создании проекта на платформе. Имя проекта соответствует имени проекта на платформе.

### Тегирование образов

```bash
# Backend
docker tag backend:latest harbor.qaztech.gov.kz/myproject/backend:latest
docker tag backend:latest harbor.qaztech.gov.kz/myproject/backend:v1.0.0
docker push harbor.qaztech.gov.kz/myproject/backend:latest

# Frontend
docker tag frontend:latest harbor.qaztech.gov.kz/myproject/frontend:latest
docker push harbor.qaztech.gov.kz/myproject/frontend:latest
```

## Nexus

**URL:** https://nexus.qaztech.gov.kz

### Настройка NPM

Скопировать файл `config/nexus/.npmrc` в корень проекта и заменить `<PROJECT_NAME>` на имя проекта:

```bash
cp config/nexus/.npmrc .npmrc
sed -i 's/<PROJECT_NAME>/myproject/g' .npmrc
```

Установить переменные окружения:
```bash
export NEXUS_USERNAME=<ваш_логин>
export NEXUS_PASSWORD=<ваш_пароль>
export NEXUS_AUTH_TOKEN=$(echo -n "$NEXUS_USERNAME:$NEXUS_PASSWORD" | base64)
```

### Настройка Maven

Скопировать файл `config/nexus/maven-settings.xml` в `~/.m2/settings.xml` и заменить `<PROJECT_NAME>`.

### Настройка YUM

Скопировать файл `config/nexus/yum-repo.conf` в `/etc/yum.repos.d/myproject-nexus.repo` и обновить репозитории:

```bash
sudo yum clean all
sudo yum makecache
```

## SonarQube

**URL:** https://sonarqube.qaztech.gov.kz

### Создание проекта

1. Войти в SonarQube: https://sonarqube.qaztech.gov.kz
2. Создать проект (обычно создается автоматически)
3. Получить токен: My Account -> Security -> Generate Token

### Настройка анализа

Анализ кода выполняется автоматически через GitLab CI/CD. Необходимо только указать токен в переменных GitLab.

### Просмотр результатов

Результаты анализа доступны в SonarQube после выполнения пайплайна. Можно настроить Quality Gates для блокировки развертывания при низком качестве кода.

## HashiCorp Vault

**URL:** https://vault.qaztech.gov.kz

### Установка Vault CLI

```bash
# Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault
```

### Вход в Vault

```bash
export VAULT_ADDR=https://vault.qaztech.gov.kz
vault auth <ваш_токен>
```

### Создание секретов

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

# Секреты Harbor
vault kv put secret/myproject/dev/harbor \
  url=https://harbor.qaztech.gov.kz \
  username=harbor_user \
  password=harbor_password
```

### Использование в приложении

Приложение автоматически получает секреты из Vault при наличии переменных окружения `VAULT_ADDR` и `VAULT_TOKEN`. См. `backend/vault-integration.js` для деталей.

## Grafana

**URL:** https://grafana.qaztech.gov.kz

### Доступ

Войти в Grafana: https://grafana.qaztech.gov.kz

### Импорт дашборда

1. Перейти в Dashboards -> Import
2. Загрузить файл `config/monitoring/grafana-dashboard.json`
3. Настроить переменные:
   - `project` = имя проекта
   - `environment` = среда (dev, test, stage, prod)
   - `instance` = IP адрес или имя виртуальной машины

### Настройка алертов

1. Создать каналы уведомлений (Email, Slack и т.д.)
2. Настроить правила алертинга для критических метрик:
   - CPU > 80%
   - RAM > 90%
   - Disk > 85%
   - Недоступность сервиса

## OpenSearch

**URL:** https://opensearch.qaztech.gov.kz

### Доступ

Войти в OpenSearch Dashboards: https://opensearch.qaztech.gov.kz/_dashboards

### Настройка Filebeat

1. Установить Filebeat на виртуальных машинах (см. `config/monitoring/filebeat.yml.example`)
2. Настроить конфигурацию с указанием проекта и среды
3. Запустить Filebeat:

```bash
sudo systemctl enable filebeat
sudo systemctl start filebeat
```

### Создание индексов

Индексы создаются автоматически при отправке логов. Pattern: `<PROJECT_NAME>-<ENVIRONMENT>-logs-*`

### Создание визуализаций

1. Создать Index Pattern: `<PROJECT_NAME>-<ENVIRONMENT>-logs-*`
2. Создать визуализации:
   - Логи по времени (Time series)
   - Топ ошибок (Data table)
   - Распределение по уровням логов (Pie chart)
3. Создать дашборд с визуализациями

## DefectDojo

### Доступ

Войти в DefectDojo: `https://defectdojo.qaztech.gov.kz`

### Настройка проекта

Проект создается автоматически при создании проекта на платформе.

### Интеграция с GitLab CI/CD

Отчеты о безопасности автоматически загружаются в DefectDojo через GitLab CI/CD (см. `gitlab-ci/security.yml`).

### Просмотр уязвимостей

1. Перейти в Findings
2. Фильтровать по проекту и среде
3. Анализировать найденные уязвимости
4. Создавать задачи на исправление

## Дополнительные настройки

### Ротация секретов

Рекомендуется регулярно обновлять секреты в Vault:
- Пароли БД: каждые 90 дней
- API ключи: каждые 180 дней
- Токены доступа: каждые 30 дней

### Резервное копирование

Настроить автоматическое резервное копирование:
- База данных: ежедневно
- Конфигурации: еженедельно
- Логи: по требованию

### Мониторинг доступности

Настроить внешний мониторинг доступности сервисов (UptimeRobot, Pingdom и т.д.) для критических сред (STAGE, PROD).

