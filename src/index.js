const mongoose = require("mongoose");
const app = require("./app");
const config = require("./config/config");
const logger = require("./config/logger");
const https = require('https');
const fs = require('fs');

let server;

mongoose
  .connect(config.mongoose.url, config.mongoose.options)
  .then(() => {
    logger.info('Connected to MongoDB : ' + config.mongoose.url);
    
    if (config.env === "local") {
      const sslOptions = {
        key: fs.readFileSync(config.ssl.privKey),
        cert: fs.readFileSync(config.ssl.fullChainKey),
      };

      server = https.createServer(sslOptions, app).listen(config.port, () => {
        logger.info(`Listening to port ${config.port} (HTTPS local)`);
        logger.info(`Server URL: https://localhost:${config.port}/api/v1`);
      });

    } else {
      // ✅ Production + Render + Cloud = HTTP only
      server = app.listen(config.port, () => {
        console.log(`🚀 Server started successfully on port ${config.port} (HTTP)`);
        logger.info(`Listening to port ${config.port} (HTTP)`);
        logger.info(`Server URL: ${config.url}/api/v1`);
      });
    }
  })
  .catch((err) => {
    logger.error('❌ Failed to connect to MongoDB:', err.message);
    process.exit(1);
  });

const exitHandler = () => {
  if (server) {
    server.close(() => {
      logger.info("Server closed");
      process.exit(1);
    });
  } else {
    process.exit(1);
  }
};

const unexpectedErrorHandler = (error) => {
  logger.error(error);
  exitHandler();
};

process.on("uncaughtException", unexpectedErrorHandler);
process.on("unhandledRejection", unexpectedErrorHandler);

process.on("SIGTERM", () => {
  logger.info("SIGTERM received");
  if (server) {
    server.close();
  }
});
