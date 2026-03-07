const dotenv = require('dotenv');
const path = require('path');
const Joi = require('joi');

dotenv.config({ path: path.join(__dirname, '../../.env') });

const envVarsSchema = Joi.object()
  .keys({
    NODE_ENV: Joi.string().valid('production', 'development', 'test', 'local').required(),
    PORT: Joi.number().default(3000),
    MONGODB_URL: Joi.string().required().description('Mongo DB url'),
    DB_NAME: Joi.string().description('database name'),
    DB_PORT: Joi.string().description('database port'),
    DB_SERVER: Joi.string(),
    DB_USER: Joi.string(),
    DB_PASS: Joi.string(),
    SSL_PRIV_KEY: Joi.string(),
    SSL_FULLCHAIN_KEY: Joi.string(),
    JWT_SECRET: Joi.string().required().description('JWT secret key'),
    JWT_ACCESS_EXPIRATION_MINUTES: Joi.number().default(30).description('minutes after which access tokens expire'),
    JWT_REFRESH_EXPIRATION_DAYS: Joi.number().default(30).description('days after which refresh tokens expire'),
    COINMARKET_CAP_API_KEY: Joi.string().required().description('Coinmarketcap api key required'),
    BASE_URL: Joi.string().default('http://localhost:3000').description('Base URL for the application'),
  })
  .unknown();

const { value: envVars, error } = envVarsSchema.prefs({ errors: { label: 'key' } }).validate(process.env);

if (error) {
  throw new Error(`Config validation error: ${error.message}`);
}

module.exports = {
  env: envVars.NODE_ENV,
  port: envVars.PORT,
  COINMARKET_CAP_API_KEY: envVars.COINMARKET_CAP_API_KEY,
  url: envVars.BASE_URL,
  ssl: {
    privKey: envVars.SSL_PRIV_KEY,
    fullChainKey: envVars.SSL_FULLCHAIN_KEY
  },
  mongoose: {
    DB_NAME: envVars.DB_NAME,
    DB_PORT: envVars.DB_PORT,
    DB_SERVER: envVars.DB_SERVER,
    DB_USER: envVars.DB_USER,
    DB_PASS: envVars.DB_PASS,
    url: envVars.MONGODB_URL + (envVars.NODE_ENV === 'test' ? '' : ''),
    options: {
      useCreateIndex: true,
      useNewUrlParser: true,
      useUnifiedTopology: true,
    },
  },
  jwt: {
    secret: envVars.JWT_SECRET,
    accessExpirationMinutes: envVars.JWT_ACCESS_EXPIRATION_MINUTES,
    refreshExpirationDays: envVars.JWT_REFRESH_EXPIRATION_DAYS,
  },
};
