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
const socket = require("./routes/socket/socket").setServer;
const connectFCM = require("./routes/mapp/push/fcm");
const userEmitter = require("./events/eventDrivenLists");
const reviewRefreshWorks = require("./serverSideWorks/reviewAverage");
const { bubbleCollection } = require("./serverSideWorks/bubbleCollection");

/* for initial server static IP address getting */
const axios = require('axios');
const notFoundHandler = require("./routes/errorHandler/notFound");
const errorHandler = require("./routes/errorHandler/errorHandler");

axios.get('https://myexternalip.com/raw')
    .then((response) => {
        console.log(response.data);
    })
    .catch((error) => {
        console.error(error, "errorAtGettingIPAddress");
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

connectDB();
connectFCM();
bubbleCollection();

/* event-driven */
/* lazy-recomputing review update */
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
const aichat = io.of('/aichat');
aichat.on('connect', require("./routes/mapp/user/chatbot").aiChatting);
const dm_user = io.of('/dm_user');
const dm_doctor = io.of('/dm_doctor');
const dm_user_listView = io.of('/dm_user_list');
const dm_doctor_listView = io.of('/dm_doctor_list');
dm_user.on('connect', require("./routes/mapp/user/dm_MQ"));
dm_doctor.on('connect', require("./routes/mapp/doctor/files/dm_MQ"));
dm_user_listView.on('connect', require("./routes/mapp/user/dm_MQ_list"));
dm_doctor_listView.on('connect', require("./routes/mapp/doctor/files/dm_MQ_list"));

app.use(cors());

app.use("/", require("./routes/main"));
app.use("/", require("./routes/accountDeletion"));
app.use("/admin", require("./routes/adminAccount")); 
app.use("/admin", require("./routes/admin_premiumify_psy"));
app.use("/admin", require("./routes/admin_register_doctor_to_psy"));
app.use('/mapp', require("./routes/mapp"));

app.use(notFoundHandler);
app.use(errorHandler);

server.listen(port, () => {
    console.log(`Server working on port ${port}`);
});