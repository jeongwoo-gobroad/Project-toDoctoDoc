require("dotenv").config();
const express = require("express");
const router = express.Router();
const mainLayout = "../views/layouts/main";
const mainLayout_LoggedIn = "../views/layouts/main_LoggedIn";
const openai = require("openai");
const loginMiddleWare = require("./checkLogin");
const asyncHandler = require("express-async-handler");
const limitMiddleWare = require("./checkLimit");

router.get(["/", "/home", "/index"], async (req, res) => {
    if (await loginMiddleWare.isLoggedIn(req, res)) {
        const pageInfo = {
            title: "Welcome to Mentally",
        };
        const accountInfo = {
            usernick: req.session.user.usernick,
        };
        res.render("main/home", {pageInfo, accountInfo, layout: mainLayout_LoggedIn});
    } else {
        const pageInfo = {
            title: "Welcome to Mentally",
        };
        res.render("main/home", {pageInfo, layout: mainLayout});
    }
});

router.get(["/about"], async (req, res) => {
    if (await loginMiddleWare.isLoggedIn(req, res)) { 
        const pageInfo = {
            title: "Welcome to Mentally::About",
        };
        const accountInfo = {
            usernick: req.session.user.usernick,
        };
        res.render("main/about", {pageInfo, accountInfo, layout: mainLayout_LoggedIn});
    } else {
        const pageInfo = {
            title: "Welcome to Mentally::About",
        };
        res.render("main/about", {pageInfo, layout: mainLayout});
    }
});

router.post(["/query"],
    loginMiddleWare.ifLoggedInThenProceed,
    limitMiddleWare.ifDailyRequestNotExceededThenProceed,
    asyncHandler(async (req, res) => {
        const {input} = req.body;
        const target = new openai({
            apiKey: process.env.OPENAI_KEY,
        });
        const pageInfo = {
            title: "Welcome to Mentally::Query"
        };
        const accountInfo = {
            usernick: req.session.user.usernick,
        };

        if (input.length >= 1) {
            const query = input + " 라는 걱정을 하고 있는데, 걱정 할 필요가 없다는 것을 경어체로 다독이듯이 말해줘";

            try {
                const completion = await target.chat.completions.create({
                    "model": "gpt-4o-mini",
                    "store": false,
                    "messages": [
                        {
                            "role": "developer",
                            "content": "너는 전문 심리 상담사이고, 걱정할 필요가 없다는 것을 가능한 한 긍정적으로, 밝고 긍정적인 어휘를 써서서, 한국어 경어체로 말해줘야 해"
                        },
                        {
                            "role": "user",
                            "content": query
                        }
                    ]
                });
    
                const pageContent = {
                    title: input,
                    context: completion.choices[0].message.content,
                }
                res.render("main/queryResultPage", {pageInfo, pageContent, accountInfo, layout: mainLayout_LoggedIn});
            } catch (error) {
                console.log(error);

                res.redirect("/error");

                return;
            }
        } else {
            res.redirect("/");
        }
})); 

router.get(["/error"], async (req, res) => {
    if (await loginMiddleWare.isLoggedIn(req, res)) {
        const pageInfo = {
            title: "Welcome to Mentally::Error page",
        };
        const accountInfo = {
            usernick: req.session.user.usernick,
        };
        res.render("main/internalError", {pageInfo, accountInfo, layout: mainLayout_LoggedIn});
    } else {
        const pageInfo = {
            title: "Welcome to Mentally::Error page",
        };
        res.render("main/internalError", {pageInfo, layout: mainLayout});
    }
});

router.get(["/freeAccountError"], async (req, res) => {
    if (await loginMiddleWare.isLoggedIn(req, res)) {
        const pageInfo = {
            title: "Welcome to Mentally::Free account limit exceeded",
        };
        const accountInfo = {
            usernick: req.session.user.usernick,
        };
        res.render("main/freeAccountError", {pageInfo, accountInfo, layout: mainLayout_LoggedIn});
    } else {
        const pageInfo = {
            title: "Welcome to Mentally::Error page",
        };
        res.render("main/freeAccountError", {pageInfo, layout: mainLayout});
    }
});

module.exports = router;