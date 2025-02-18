const redis = require('redis');

class Redis {
    constructor() {
        this.redisClient = redis.createClient({
            url: `redis://${process.env.RS_USERNAME}:${process.env.RS_PASSWORD}@${process.env.RS_HOST}:${process.env.RS_PORT}/0`
        });
    }

    async connect() {
        try {
            await this.redisClient.connect();
            console.log("Redis object connected");
        } catch (error) {
            console.error(error, "Redis object connection error");
            return;
        }
    }

    async closeConnnection() {
        try {
            await this.redisClient.quit();
            console.log("Redis object disconnected");
        } catch (error) {
            console.error(error, "Redis object disconnection error");
            return;
        }
    }

    async setSetForNDays(key, item, days) {
        try {
            await this.redisClient.sAdd(key.toString(), JSON.stringify(item));
            await this.redisClient.expire(key.toString(), process.env.ONE_DAY_TO_SECONDS * parseInt(days));

            return;
        } catch (error) {
            console.error(error);
            return null;
        }
    }

    async setSetForever(key, item) {
        try {
            await this.redisClient.sAdd(key.toString(), JSON.stringify(item));
            
            return;
        } catch (error) {
            console.error(error);
            return null;
        }
    }

    async removeItemFromSet(key, item) {
        try {
            await this.redisClient.sRem(key.toString(), JSON.stringify(item));
            
            return;
        } catch (error) {
            console.error(error);
            return null;
        }
    }

    async doesSetContains(key, item) {
        try {
            const rtn = await this.redisClient.sIsMember(key.toString(), JSON.stringify(item))
            
            return rtn;
        } catch (error) {
            console.error(error);
            return null;
        }
    }

    async swapHashFieldValueWithTTL(key, field, seconds) {
        try {
            const prevVal = await this.redisClient.hGet(key.toString(), field.toString());
            await this.redisClient.hDel(key.toString(), field.toString());
            await this.redisClient.hSet(key.toString(), prevVal, field.toString());
            await this.redisClient.hExpire(key.toString(), prevVal, parseInt(seconds));

            return;
        } catch (error) {
            console.error(error, "errorAtSwapHashFieldValue");

            return null;
        }
    }

    async getHashValue(key, field) {
        try {
            const value = await this.redisClient.hGet(key.toString(), field.toString());
    
            return JSON.parse(value);
        } catch (error) {
            console.error(error);
            return null;
        }
    }

    async setHashValue(key, field, value) {
        try {
            await this.redisClient.hSet(key.toString(), field.toString(), JSON.stringify(value));
            
            return;
        } catch (error) {
            console.error(error);
            return null;
        }
    }

    async delHashValue(key, field) {
        try {
            await this.redisClient.hDel(key.toString(), field.toString());
            
            return;
        } catch (error) {
            console.error(error);
            return null;
        }
    }

    async setHashValueWithTTL(key, field, value, days) {
        try {
            await this.redisClient.hSet(key.toString(), field.toString(), JSON.stringify(value));
            await this.redisClient.hExpire(key.toString(), field.toString(), process.env.ONE_DAY_TO_SECONDS * parseInt(days));
            await this.redisClient.expire(key.toString(), process.env.ONE_DAY_TO_SECONDS * parseInt(days));
            
            return;
        } catch (error) {
            console.error(error, "errorAtSetHashValueWithTTL");
    
            return null;
        }
    }

    async doesHashContains(key, field) {
        try {
            const rtn = await this.redisClient.hExists(key.toString(), field.toString());
            
            return rtn;
        } catch (error) {
            console.error(error, "errorAtDoesHashContains");
            return null;
        }
    }

    async incrementHashValue(key, field) {
        try {
            await this.redisClient.hIncrBy(key.toString(), field.toString(), 1);
        } catch (error) {
            console.error(error, "errorAtIncrementHashValue");
            return null;
        }
    }

    async decrementHashValue(key, field) {
        try {
            return (await this.redisClient.hIncrBy(key.toString(), field.toString(), -1));
        } catch (error) {
            console.error(error, "errorAtDecrementHashValue");
            return null;
        }
    }

    async getHashAll(key) {
        try {
            const value = await this.redisClient.hGetAll(key.toString());
    
            const map = new Map(Object.entries(value));
    
            for (const [key, val] of map) {
                map.set(key, JSON.parse(val));
            }
            
            return map;
        } catch (error) {
            console.error(error);
            return null;
        }
    }

    async getCache(key) {
        try {
            const cachedData = await this.redisClient.get(key.toString());
    
            return JSON.parse(cachedData);
        } catch (error) {
            console.error(error);
            return null;
        }
    }

    async setCache(key, data) {
        try {
            // THIS DOES NOT WORK AT ALL!
            // redis.redisClient.set(key, JSON.stringify(data), "EX", process.env.ONE_WEEK_TO_SECONDS);
            await this.redisClient.setEx(key.toString(), process.env.ONE_WEEK_TO_SECONDS, JSON.stringify(data));
            
        } catch (error) {
            console.error(error);
            return null;
        }
    }

    async setCacheForever(key, data) {
        try {
            await this.redisClient.set(key.toString(), JSON.stringify(data));
            
            return;
        } catch (error) {
            console.error(error, "errorAtSetCacheForever");
    
            return null;
        }
    }

    async setCacheForThreeDaysAsync(key, data) {
        try {
            // await redis.redisClient.set(key, JSON.stringify(data), "EX", process.env.THREE_DAYS_TO_SECONDS);
            await this.redisClient.setEx(key.toString(), process.env.THREE_DAYS_TO_SECONDS, JSON.stringify(data));
            
            return;
        } catch (error) {
            console.error(error);
            return null;
        }
    }

    async setCacheForNDaysAsync(key, data, days) {
        try {
            await this.redisClient.setEx(key.toString(), process.env.ONE_DAY_TO_SECONDS * parseInt(days), JSON.stringify(data));
            
            return;
        } catch (error) {
            console.error(error, "errorAtSetCacheForNDaysAsync");
    
            return null;
        }
    }

    async delCache(key) {
        try {
            await this.redisClient.del(key.toString());
            
            return;
        } catch (error) {
            console.error(error, "errorAtDelCache");

            return null;
        }
    }

    async pushMessageToMessageQueue(channel, message) {
        try {
            await this.redisClient.lPush(channel.toString(), JSON.stringify(message));
    
        } catch (error) {
            console.error(error, "errorAtPushMessageToMessageQueue");
    
            return;
        }
    }

    async popMessageFromMessageQueue(channel) {
        try {
            const rtn = await this.redisClient.rPop(channel.toString());

            return rtn;
        } catch (error) {
            console.error(error, "errorAtPopMessageFromMessageQueue");

            return;
        }
    }

    async publishMessageToChatId(chatId, message) {
        try {
            await this.redisClient.publish(("CHATROOM_CHANNEL:" + chatId).toString(), JSON.stringify(message));
        } catch (error) {
            console.error(error, "errorAtPublishMessageToChatId");
    
            return;
        }
    }

    async doesKeyExist(key) {
        try {
            return await this.redisClient.exists(key.toString());
        } catch (error) {
            console.error(error, "errorAtDoesKeyExist");

            return;
        }
    }

    async atomicallyIncrement(key) {
        try {
            return await this.redisClient.incr(key.toString());
        } catch (error) {
            console.error(error, "errorAtAtomicallyIncrement");

            return;
        }
    }
}

module.exports = Redis;