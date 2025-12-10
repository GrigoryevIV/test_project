# Инструкция по развертыванию приложения на платформе QazTech

Краткая инструкция по развертыванию fullstack-приложения на технологической платформе QazTech.

**Для детальных инструкций с примерами кода см. [STEP_BY_STEP_GUIDE.md](STEP_BY_STEP_GUIDE.md)**

## Предварительные требования

1. **Проект создан на платформе** через портал самообслуживания: https://portal.qaztech.gov.kz
2. **Виртуальные машины созданы** для каждой среды (DEV, TEST, STAGE, PROD) через портал
3. **Получены учетные данные** для доступа к инструментам платформы

## Быстрый старт

### 1. Загрузка кода в GitLab

```bash
./scripts/deployment/01-upload-code-to-gitlab.sh myproject
```

**Детали:** См. [STEP_BY_STEP_GUIDE.md - Шаг 15.5](STEP_BY_STEP_GUIDE.md#шаг-155-загрузка-исходного-кода)

### 2. Настройка инструментов платформы

```bash
# Nexus
./scripts/deployment/02-setup-nexus.sh myproject

# Harbor
./scripts/deployment/03-setup-harbor.sh myproject

# Установка ПО
./scripts/deployment/04-setup-software.sh myproject dev
```

**Детали:** См. [STEP_BY_STEP_GUIDE.md - Шаги 15.6-15.8](STEP_BY_STEP_GUIDE.md#развертывание-приложения)

### 3. Настройка CI/CD

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

**Детали:** См. [STEP_BY_STEP_GUIDE.md - Шаги 15.9-15.12](STEP_BY_STEP_GUIDE.md#развертывание-приложения)

### 4. Настройка мониторинга

```bash
./scripts/deployment/09-setup-monitoring.sh myproject dev <VM_IP>
```

**Детали:** См. [STEP_BY_STEP_GUIDE.md - Шаги 15.13-15.14](STEP_BY_STEP_GUIDE.md#развертывание-приложения)

### 5. Настройка DNS и SSL

```bash
./scripts/deployment/10-setup-dns-ssl.sh myproject dev <FRONTEND_IP> <BACKEND_IP> myproject.qaztech.gov.kz
```

**Детали:** См. [STEP_BY_STEP_GUIDE.md - Шаг 15.16](STEP_BY_STEP_GUIDE.md#шаг-1516-вывод-проекта-в-dev)

### 6. Настройка Vault

```bash
./scripts/deployment/11-setup-vault.sh myproject dev
```

**Детали:** См. [STEP_BY_STEP_GUIDE.md - Шаг 15.15](STEP_BY_STEP_GUIDE.md#шаг-1515-подключение-hashicorp-vault)

## Развертывание через CI/CD

После настройки CI/CD, развертывание происходит автоматически:

1. **DEV среда:** автоматически при push в ветку `develop`
2. **TEST среда:** вручную через GitLab UI после успешных тестов
3. **STAGE среда:** вручную через GitLab UI перед релизом
4. **PROD среда:** вручную через GitLab UI после одобрения

**Детали:** См. [gitlab-ci/deploy.yml](gitlab-ci/deploy.yml)

## Проверка развертывания

```bash
# Проверка Backend API
curl https://api-dev.myproject.qaztech.gov.kz/health

# Проверка Frontend
curl https://dev.myproject.qaztech.gov.kz

# Проверка базы данных
curl https://api-dev.myproject.qaztech.gov.kz/users
```

## Дополнительные ресурсы

- **[STEP_BY_STEP_GUIDE.md](STEP_BY_STEP_GUIDE.md)** - Детальное пошаговое руководство с примерами кода
- [QAZTECH_SETUP.md](QAZTECH_SETUP.md) - Детальное описание настройки компонентов QazTech
- [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) - Настройка сред разработки
- Портал самообслуживания: https://portal.qaztech.gov.kz
- Официальная документация: https://docs.qaztech.gov.kz

## Поддержка

- Email: support@qaztech.gov.kz
- Портал: https://portal.qaztech.gov.kz
- Служба поддержки работает с понедельника по пятницу с 9:00 до 18:00 (GMT+6)
