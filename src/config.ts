// not sure a better way to deal with env
// so I keep it simple here

interface IConfig {
  env: string;
  mongoUrl: string;
}

const defaultConfigs = {
  env: "development",
  // MONGO_URL might be inserted by docker-compose
  mongoUrl: process.env.MONGO_URL || "mongodb://localhost:27017/test"
};

const stagingConfig = {
  env: "staging",
  // MONGO_URL might be inserted by docker-compose
  mongoUrl: process.env.MONGO_URL
};

const productionConfigs = {
  env: "production",
  mongoUrl: process.env.MONGO_URL
};

export default (): IConfig => {
  const env = process.env.NODE_ENV || "development";

  switch (env) {
    case "staging":
      return {...defaultConfigs, ...stagingConfig};
    case "production":
      return {...defaultConfigs, ...productionConfigs};
    default:
      return defaultConfigs;
  }
};
