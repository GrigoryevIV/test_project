# Развертывание проекта на платформе QazTech

Данный проект содержит полный набор скриптов, конфигураций и документации для развертывания fullstack-приложения на технологической платформе QazTech.

## Структура проекта

```
coolify-fullstack-example/
├── backend/                 # Backend приложение (Node.js + Express)
│   ├── index.js            # Основной файл приложения
│   ├── vault-integration.js # Интеграция с HashiCorp Vault
│   ├── .env.example        # Пример переменных окружения
│   └── package.json        # Зависимости (включая node-vault)
├── frontend/               # Frontend приложение (React + Vite)
│   ├── src/               # Исходный код
│   ├── .env.example       # Пример переменных окружения
│   └── Dockerfile         # Docker образ для production
├── scripts/               # Скрипты развертывания
│   └── deployment/        # Скрипты для каждого этапа развертывания приложения
│       ├── 01-upload-code-to-gitlab.sh  # Загрузка кода в GitLab
│       ├── 02-setup-nexus.sh           # Подключение к Nexus
│       ├── 03-setup-harbor.sh          # Настройка Harbor
│       ├── 04-setup-software.sh        # Установка ПО
│       ├── 05-setup-cicd.sh            # Настройка CI/CD
│       ├── 06-setup-sonarqube.sh       # Подключение SonarQube
│       ├── 07-setup-sast.sh            # Подключение SAST
│       ├── 08-setup-defectdojo.sh     # Подключение DefectDojo
│       ├── 09-setup-monitoring.sh      # Настройка мониторинга
│       ├── 10-setup-dns-ssl.sh        # Настройка DNS и SSL
│       └── 11-setup-vault.sh          # Интеграция с Vault
├── config/                # Конфигурации для инструментов платформы
│   ├── nexus/            # Конфигурации Nexus (NPM, Maven, YUM)
│   ├── harbor/           # Конфигурации Harbor
│   ├── vault/            # Шаблоны для работы с Vault
│   └── monitoring/       # Конфигурации мониторинга (Grafana, OpenSearch)
├── gitlab-ci/            # GitLab CI/CD конфигурации
│   ├── build.yml         # Этапы сборки
│   ├── test.yml          # Этапы тестирования
│   ├── security.yml      # Проверка безопасности
│   ├── sonarqube.yml     # Анализ кода
│   └── deploy.yml        # Развертывание по средам
├── .gitlab-ci.yml        # Основной файл CI/CD
├── STEP_BY_STEP_GUIDE.md # ⭐ Пошаговое руководство с примерами кода
├── DEPLOYMENT.md         # Краткая инструкция по развертыванию
├── QAZTECH_SETUP.md      # Детальное описание настройки компонентов
└── ENVIRONMENT_SETUP.md  # Настройка сред разработки
```

## Быстрый старт

**ВАЖНО:** Инфраструктура (виртуальные машины, сети) создается через портал самообслуживания: https://portal.qaztech.gov.kz

### 1. Изучите документацию

Начните с чтения основных документов:
- **[STEP_BY_STEP_GUIDE.md](STEP_BY_STEP_GUIDE.md)** - ⭐ Пошаговое руководство с примерами кода и ссылками на файлы
- [DEPLOYMENT.md](DEPLOYMENT.md) - Полная инструкция по развертыванию приложения
- [QAZTECH_SETUP.md](QAZTECH_SETUP.md) - Настройка компонентов платформы
- [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) - Настройка сред

### 2. Загрузите код в GitLab

```bash
./scripts/deployment/01-upload-code-to-gitlab.sh myproject
```

### 3. Настройте инструменты платформы

```bash
# Nexus
./scripts/deployment/02-setup-nexus.sh myproject

# Harbor
./scripts/deployment/03-setup-harbor.sh myproject

# Установка ПО
./scripts/deployment/04-setup-software.sh myproject dev
```

### 4. Настройте CI/CD

```bash
# CI/CD
./scripts/deployment/05-setup-cicd.sh myproject

# SonarQube
./scripts/deployment/06-setup-sonarqube.sh myproject

# SAST
./scripts/deployment/07-setup-sast.sh myproject

# DefectDojo
./scripts/deployment/08-setup-defectdojo.sh myproject
```

### 5. Настройте мониторинг

```bash
./scripts/deployment/09-setup-monitoring.sh myproject dev <VM_IP>
```

### 6. Настройте DNS и SSL

```bash
./scripts/deployment/10-setup-dns-ssl.sh myproject dev <FRONTEND_IP> <BACKEND_IP> myproject.qaztech.gov.kz
```

### 7. Настройте Vault

```bash
./scripts/deployment/11-setup-vault.sh myproject dev
```

## Интеграция с платформой QazTech

### Инструменты платформы

- **Портал самообслуживания**: https://portal.qaztech.gov.kz - Управление проектами и ресурсами
- **GitLab**: https://gitlab.qaztech.gov.kz - Управление кодом и CI/CD
- **Harbor**: https://harbor.qaztech.gov.kz - Docker Registry
- **Nexus**: https://nexus.qaztech.gov.kz - Репозиторий артефактов
- **SonarQube**: https://sonarqube.qaztech.gov.kz - Анализ качества кода
- **Vault**: https://vault.qaztech.gov.kz - Управление секретами
- **Grafana**: https://grafana.qaztech.gov.kz - Мониторинг и визуализация
- **OpenSearch**: https://opensearch.qaztech.gov.kz - Поиск и анализ логов
- **Redmine**: https://redmine.qaztech.gov.kz - Управление проектами
- **DefectDojo**: `https://defectdojo.qaztech.gov.kz` - Управление уязвимостями

### Среда разработки

Проект поддерживает 5 сред:
- **DEV** - Разработка
- **TEST** - Тестирование
- **STRESSTEST** - Нагрузочное тестирование
- **STAGE** - Предрелизная среда
- **PROD** - Production

Подробнее см. [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md)

## CI/CD Pipeline

GitLab CI/CD автоматизирует:
- ✅ Сборку приложения (build)
- ✅ Тестирование (test)
- ✅ Проверку безопасности (SAST, Dependency Scanning)
- ✅ Анализ кода (SonarQube)
- ✅ Развертывание по средам (deploy)

См. `.gitlab-ci.yml` и файлы в `gitlab-ci/` для деталей.

## Безопасность

### Управление секретами

Все секреты хранятся в HashiCorp Vault:
- Пароли баз данных
- Учетные данные сервисов
- API ключи
- Токены доступа

Приложение автоматически получает секреты из Vault при запуске (см. `backend/vault-integration.js`).

### Проверка безопасности

Автоматическая проверка безопасности выполняется на каждом этапе CI/CD:
- SAST (Static Application Security Testing)
- Dependency Scanning
- Интеграция с DefectDojo

## Мониторинг

### Метрики

Мониторинг метрик через Grafana:
- CPU Utilization
- RAM Utilization
- Storage Utilization
- Network Utilization

### Логи

Логи собираются и отправляются в OpenSearch:
- Системные логи
- Логи приложения
- Логи Nginx

## Поддержка

- **Документация**: `https://docs.qaztech.gov.kz`
- **Портал**: `https://portal.qaztech.gov.kz`
- **Email**: support@qaztech.gov.kz
- **Время работы**: Пн-Пт, 9:00-18:00 (GMT+6)

## Лицензия

См. файл [LICENSE](LICENSE)

## Авторы

Проект создан для развертывания на платформе QazTech согласно официальной инструкции миграции.

