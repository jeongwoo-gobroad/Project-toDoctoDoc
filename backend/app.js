require("dotenv").config({path: "./_secrets/dotenv/.env"});
const express = require("express");
const session = require("express-session");
const expressLayouts = require("express-ejs-layouts");
const cookieParser = require("cookie-parser");
const methodOverride = require("method-override");
const connectDB = require("./config/db");
const http = require("http");
const { wrap } = require("module");
const cors = require("cors");
const redis = require("./config/redis");
const socket = require("./routes/socket/socket").setServer;
const connectFCM = require("./routes/mapp/push/fcm");
const userEmitter = require("./events/eventDrivenLists");
const reviewRefreshWorks = require("./serverSideWorks/reviewAverage");
const { bubbleCollection } = require("./serverSideWorks/bubbleCollection");

/* for initial server static IP address getting */
const request = require('request');
const notFoundHandler = require("./routes/errorHandler/notFound");

request.get({uri:'https://curlmyip.org/'}, (err, res, body) => {
    console.log("Server Working on IP:", body);
});
/* -------------------------------------------- */

const app = express();
const server = http.createServer(app);
const io = socket(server);

const port = process.env.PORT || 3000;

app.use(session({
    secret: process.env.SESS_SECRET,
    resave: false,
    saveUninitialized: true,
    cookie: {secure: false}
}));

redis.connectRedis().then(console.log("redis connection success"));
connectDB().then(console.log("MongoDB connection success"));
connectFCM();
bubbleCollection();

/* event-driven */
userEmitter.on('reviewUpdated', reviewRefreshWorks);

app.use(expressLayouts);
app.set("view engine", "ejs");
app.set("views", "./views");   
app.use(express.static("public"));
app.use(methodOverride("_method"));
app.use(cookieParser());  
app.use(express.json());
app.use(express.urlencoded({extended: true}));

io.use(wrap(session({
    secret: process.env.SESS_SECRET,
    resave: false,
    saveUninitialized: true,
    cookie: {secure: false}
})));
io.use(wrap(cookieParser()));
io.use(wrap(express.json()));
io.use(wrap(express.urlencoded({extended: true})));
io.of('/chat').use(require('./routes/dm_auth/dm_isValid'));
io.of('/chat').use(require("./middleware/dmAlgorithm"));
const aichat = io.of('/aichat');
aichat.on('connect', require("./routes/mapp/user/chatbot").aiChatting);
const dm_user = io.of('/dm_user');
const dm_doctor = io.of('/dm_doctor');
// dm.on('connect', require("./routes/mapp/dm/socketOperation"));
// dm.on('connect', require("./routes/mapp/user/dm_socket"));
// dm.on('connect', require("./routes/mapp/doctor/files/dm_socket"));
dm_user.on('connect', require("./routes/mapp/user/dm_MQ"));
dm_doctor.on('connect', require("./routes/mapp/doctor/files/dm_MQ"));

app.use(cors());

app.use("/", require("./routes/main"));
app.use("/admin", require("./routes/adminAccount")); 
app.use("/admin", require("./routes/admin_premiumify_psy"));
app.use("/admin", require("./routes/admin_register_doctor_to_psy"));
app.use('/mapp', require("./routes/mapp"));

app.use(notFoundHandler);

server.listen(port, () => {
    console.log(`Server working on port ${port}`);
});