require("dotenv").config();
const express = require("express");
const session = require("express-session");
const expressLayouts = require("express-ejs-layouts");
const cookieParser = require("cookie-parser");
const methodOverride = require("method-override");
const connectDB = require("./config/db");
const serverWorks = require("./serverSideWorks/tagCollection");
const expressErrorHandler = require('express-error-handler');
const SocketIO = require("socket.io");
const http = require("http");
const { wrap } = require("module");
const cors = require("cors");

const app = express();
const server = http.createServer(app);
const io = SocketIO(server, {
    path: '/msg'
});

const port = process.env.PORT || 3000;
const errorHandler = expressErrorHandler({
    static: {
        '404': './public/html/404.html'
    }
}); 

app.use(session({
    secret: process.env.SESS_SECRET,
    resave: false,
    saveUninitialized: true,
    cookie: {secure: false}
}));

connectDB();
serverWorks.serverSideWorks();

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
io.of('/chat').use(require("./middleware/dmAlgorithm"));
io.of('/aichat').use(require("./routes/mapp/user/chatbot").aiChatting);


app.use(cors());

app.use("/", require("./routes/main"));
app.use("/", require("./routes/graphBoard"));
app.use("/", require("./routes/user"));
app.use("/posts", require("./routes/post"));
app.use("/geo", require("./routes/geo"));
app.use("/doctor", require("./routes/doctorAccount"));
app.use("/admin", require("./routes/adminAccount")); 
app.use("/chatbot", require("./routes/chatbot"));
app.use("/helpNeeded", require("./routes/helpNeeded"));
app.use("/helpNeeded_doc", require("./routes/helpNeeded_Doc"));
app.use("/dm", require("./routes/dm_user"));
app.use("/dm", require("./routes/dm"));
app.use("/dm_doc", require("./routes/dm_doctor"));
app.use('/mapp', require("./routes/mapp"));

app.use(expressErrorHandler.httpError(404));
app.use(errorHandler);

server.listen(port, () => {
    console.log(`Server working on port ${port}`);
});