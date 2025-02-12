const express = require('express');
const router = express.Router();
const OpenAI = require("openai");
const { zodResponseFormat } = require('openai/helpers/zod');
const cheeringSchema = require("../jsonSchema/cheering");
const returnResponse = require('../../standardResponseJSON');
const { checkIfLoggedIn } = require('../../checkingMiddleWare');
const { ifDailyRequestNotExceededThenProceed_chatHintMessage } = require('../../limitMiddleWare');

router.post(["/sentences"],
    checkIfLoggedIn,
    ifDailyRequestNotExceededThenProceed_chatHintMessage,
    async (req, res, next) => {
        const {keyword} = req.body;

        try {
            const openai = new OpenAI({
                apiKey: process.env.OPENAI_KEY,
            });

            console.log(keyword);

            const completion = await openai.beta.chat.completions.parse({
                "model": "gpt-4o-mini",
                "store": false,
                "messages": [
                    {
                        "role": "developer",
                        "content": "내가 제시한 키워드에 대해서 응원하는 긍정의 문장을 짧게 한국어 경어체로 5개 제시 해 줘."
                    },
                    {
                        "role": "user",
                        "content": keyword
                    }
                ],
                "response_format": zodResponseFormat(cheeringSchema, "cheering")
            });

            const result = completion.choices[0].message.parsed;

            res.status(200).json(returnResponse(false, "cheeringMessage", result));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "Internal Server Error", "-"));

            console.error(error, "errorAtCheeringMessage");

            return;
        }
    }
);

module.exports = router; 