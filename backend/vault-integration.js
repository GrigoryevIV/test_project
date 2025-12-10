/**
 * Модуль интеграции с HashiCorp Vault для получения секретов
 * Согласно инструкции QazTech, шаг 15.15
 * 
 * Использование:
 *   1. Установить зависимости: npm install node-vault
 *   2. Настроить переменные окружения: VAULT_ADDR, VAULT_TOKEN, PROJECT_NAME, ENVIRONMENT
 *   3. Использовать функции для получения секретов
 */

let vaultClient = null;

/**
 * Инициализация клиента Vault
 */
function initVault() {
  // Если Vault не настроен, возвращаем null
  if (!process.env.VAULT_ADDR || !process.env.VAULT_TOKEN) {
    console.warn('Vault не настроен. Используются переменные окружения напрямую.');
    return null;
  }

  try {
    const vault = require('node-vault')({
      apiVersion: 'v1',
      endpoint: process.env.VAULT_ADDR,
      token: process.env.VAULT_TOKEN,
    });

    vaultClient = vault;
    console.log('Vault клиент инициализирован:', process.env.VAULT_ADDR);
    return vault;
  } catch (error) {
    console.error('Ошибка инициализации Vault:', error);
    return null;
  }
}

/**
 * Получение конфигурации базы данных из Vault или переменных окружения
 * @returns {Promise<Object>} Конфигурация БД
 */
async function getDatabaseConfig() {
  const PROJECT_NAME = process.env.PROJECT_NAME || 'default';
  const ENVIRONMENT = process.env.ENVIRONMENT || 'dev';
  const VAULT_PATH = `secret/${PROJECT_NAME}/${ENVIRONMENT}/database`;

  // Если Vault не настроен, используем переменные окружения
  if (!vaultClient) {
    return {
      connectionString: process.env.DATABASE_URL,
      host: process.env.DB_HOST,
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME,
      username: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
    };
  }

  try {
    const secret = await vaultClient.read(VAULT_PATH);
    const dbConfig = secret.data;

    // Формируем connection string если нужен
    const connectionString = process.env.DATABASE_URL || 
      `postgres://${dbConfig.username}:${dbConfig.password}@${dbConfig.host}:${dbConfig.port || 5432}/${dbConfig.database}`;

    return {
      connectionString,
      host: dbConfig.host,
      port: dbConfig.port || 5432,
      database: dbConfig.database,
      username: dbConfig.username,
      password: dbConfig.password,
    };
  } catch (error) {
    console.error('Ошибка получения конфигурации БД из Vault:', error);
    // Fallback на переменные окружения
    return {
      connectionString: process.env.DATABASE_URL,
      host: process.env.DB_HOST,
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME,
      username: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
    };
  }
}

/**
 * Получение секретов для внешних сервисов из Vault
 * @returns {Promise<Object>} Конфигурация сервисов
 */
async function getServicesConfig() {
  const PROJECT_NAME = process.env.PROJECT_NAME || 'default';
  const ENVIRONMENT = process.env.ENVIRONMENT || 'dev';
  const VAULT_PATH = `secret/${PROJECT_NAME}/${ENVIRONMENT}`;

  if (!vaultClient) {
    return {
      nexus: {
        url: process.env.NEXUS_URL,
        username: process.env.NEXUS_USERNAME,
        password: process.env.NEXUS_PASSWORD,
      },
      harbor: {
        url: process.env.HARBOR_URL,
        username: process.env.HARBOR_USERNAME,
        password: process.env.HARBOR_PASSWORD,
      },
    };
  }

  try {
    const [nexusSecret, harborSecret] = await Promise.all([
      vaultClient.read(`${VAULT_PATH}/nexus`).catch(() => ({ data: {} })),
      vaultClient.read(`${VAULT_PATH}/harbor`).catch(() => ({ data: {} })),
    ]);

    return {
      nexus: {
        url: nexusSecret.data.url || process.env.NEXUS_URL,
        username: nexusSecret.data.username || process.env.NEXUS_USERNAME,
        password: nexusSecret.data.password || process.env.NEXUS_PASSWORD,
      },
      harbor: {
        url: harborSecret.data.url || process.env.HARBOR_URL,
        username: harborSecret.data.username || process.env.HARBOR_USERNAME,
        password: harborSecret.data.password || process.env.HARBOR_PASSWORD,
      },
    };
  } catch (error) {
    console.error('Ошибка получения конфигурации сервисов из Vault:', error);
    return {
      nexus: {
        url: process.env.NEXUS_URL,
        username: process.env.NEXUS_USERNAME,
        password: process.env.NEXUS_PASSWORD,
      },
      harbor: {
        url: process.env.HARBOR_URL,
        username: process.env.HARBOR_USERNAME,
        password: process.env.HARBOR_PASSWORD,
      },
    };
  }
}

/**
 * Обновление токена Vault (если требуется)
 */
async function renewToken() {
  if (!vaultClient) {
    return;
  }

  try {
    await vaultClient.tokenRenewSelf();
    console.log('Токен Vault успешно обновлен');
  } catch (error) {
    console.error('Ошибка обновления токена Vault:', error);
  }
}

// Автоматическая инициализация при загрузке модуля
if (process.env.VAULT_AUTO_INIT !== 'false') {
  initVault();

  // Автоматическое обновление токена каждые 6 часов (если включено)
  if (process.env.VAULT_AUTO_RENEW === 'true' && vaultClient) {
    setInterval(renewToken, 6 * 60 * 60 * 1000);
  }
}

module.exports = {
  initVault,
  getDatabaseConfig,
  getServicesConfig,
  renewToken,
  getClient: () => vaultClient,
};

