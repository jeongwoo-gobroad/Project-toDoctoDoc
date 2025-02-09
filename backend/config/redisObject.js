const redis = require('redis');

class Redis {
    constructor() {
        this.redisClient = redis.createClient({
            url: `redis://${process.env.RS_USERNAME}:${process.env.RS_PASSWORD}@${process.env.RS_HOST}:${process.env.RS_PORT}/0`
        });
        this.redisClient.on('connect', () => {
            console.log("Redis Object Connected");
        });
        this.redisClient.on('error', (error) => {
            console.error(error, "Redis Object Creation Error");
        });
        this.redisClient.connect().then().catch((error) => {
            console.error(error, "Redis Object Connection Error");
        });
    }

    closeConnnection() {
        this.redisClient.disconnect().then().catch((error) => {
            console.error(error, "Redis Object Disconnection Error");
        });
    }
}

module.exports = Redis;