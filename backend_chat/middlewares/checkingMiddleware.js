const returnResponse = require("../dmWorks/functions/standardResponseJSON");
const { getTokenInformation } = require("../dmWorks/functions/tokenManagement");
const Chat = require("../models/Chat");

const checkIfLoggedIn = async (req, res, next) => {
    const rest = await getTokenInformation(req, res);

    if (rest && rest !== -1) {
        next();

        return;
    } else if (rest && rest === -1) {
        console.log("Expired token");

        res.status(419).json(returnResponse(true, "token_expired", "토큰이 만료되었습니다."));

        return;
    }

    res.status(401).json(returnResponse(true, "not_logged_in", "로그인 해 주세요"));

    return;
};

const checkIfMyChat = async (req, res, next) => {
    const chatId = req.params.cid;
    try {
        const chat = await Chat.findById(chatId);

        if (!chat) {
            res.status(401).json(returnResponse(true, "noSuchChat", "-"));

            return;
        }

        if (chat.user == req.userid || chat.doctor == req.userid) {
            next();

            return;
        }

        res.status(402).json(returnResponse(true, "notYourChat", "-"));

        return;
    } catch (error) {
        res.status(403).json(returnResponse(true, "errorAtCheckIfMyChat", "-"));

        return;
    }
};

module.exports = { checkIfLoggedIn, checkIfMyChat };