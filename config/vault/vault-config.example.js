/**
 * Пример конфигурации для работы с HashiCorp Vault
 * Согласно инструкции QazTech, шаг 15.15
 * 
 * Использование:
 *   1. Установить зависимости: npm install node-vault
 *   2. Скопировать этот файл в vault-config.js
 *   3. Настроить переменные окружения
 *   4. Использовать в приложении для получения секретов
 */

const vault = require('node-vault')({
  apiVersion: 'v1',
  endpoint: process.env.VAULT_ADDR || 'https://vault.qaztech.gov.kz',
  token: process.env.VAULT_TOKEN,
});

// Путь к секретам проекта (заменить на реальные значения)
const PROJECT_NAME = process.env.PROJECT_NAME || '<PROJECT_NAME>';
const ENVIRONMENT = process.env.ENVIRONMENT || '<ENVIRONMENT>';
const VAULT_PATH = `secret/${PROJECT_NAME}/${ENVIRONMENT}`;

/**
 * Получение конфигурации базы данных из Vault
 * @returns {Promise<Object>} Конфигурация БД
 */
async function getDatabaseConfig() {
  try {
    const secret = await vault.read(`${VAULT_PATH}/database`);
    return {
      host: secret.data.host,
      port: secret.data.port || 5432,
      database: secret.data.database,
      username: secret.data.username,
      password: secret.data.password,
    };
  } catch (error) {
    console.error('Ошибка получения конфигурации БД из Vault:', error);
    throw error;
  }
}

/**
 * Получение конфигурации внешних сервисов из Vault
 * @returns {Promise<Object>} Конфигурация сервисов
 */
async function getServicesConfig() {
  try {
    const [nexus, harbor] = await Promise.all([
      vault.read(`${VAULT_PATH}/nexus`),
      vault.read(`${VAULT_PATH}/harbor`),
    ]);
    
    return {
      nexus: {
        url: nexus.data.url,
        username: nexus.data.username,
        password: nexus.data.password,
      },
      harbor: {
        url: harbor.data.url,
        username: harbor.data.username,
        password: harbor.data.password,
      },
    };
  } catch (error) {
    console.error('Ошибка получения конфигурации сервисов из Vault:', error);
    throw error;
  }
}

/**
 * Получение API ключей из Vault
 * @returns {Promise<Object>} API ключи
 */
async function getApiKeys() {
  try {
    const secret = await vault.read(`${VAULT_PATH}/api`);
    return {
      apiKey: secret.data.api_key,
      apiSecret: secret.data.api_secret,
    };
  } catch (error) {
    console.error('Ошибка получения API ключей из Vault:', error);
    throw error;
  }
}

/**
 * Обновление токена Vault (если используется AppRole или периодическое обновление)
 */
async function renewToken() {
  try {
    await vault.tokenRenewSelf();
    console.log('Токен Vault успешно обновлен');
  } catch (error) {
    console.error('Ошибка обновления токена Vault:', error);
  }
}

// Автоматическое обновление токена каждые 6 часов
if (process.env.VAULT_AUTO_RENEW === 'true') {
  setInterval(renewToken, 6 * 60 * 60 * 1000);
}

module.exports = {
  getDatabaseConfig,
  getServicesConfig,
  getApiKeys,
  renewToken,
  vault, // Экспорт клиента Vault для прямого использования
};

