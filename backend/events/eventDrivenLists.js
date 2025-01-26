const EventEmitter = require('events');

class UserEmitter extends EventEmitter {}

const userEmitter = new UserEmitter();

module.exports = userEmitter;