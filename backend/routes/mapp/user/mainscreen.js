require("dotenv").config();
const express = require("express");
const router = express.Router();
const openai = require("openai");
const { checkIfLoggedIn } = require("../checkingMiddleWare");
const { ifDailyChatNotExceededThenProceed } = require("../limitMiddleWare");
const returnResponse = require("../standardResponseJSON");

router.post(["/query"],
    checkIfLoggedIn,
    ifDailyChatNotExceededThenProceed,
    async (req, res, next) => {
        const {input} = req.body;
        const target = new openai({
            apiKey: process.env.OPENAI_KEY,
        });

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
                
                res.status(200).json(returnResponse(false, "ai_answer", pageContent));

                return;
            } catch (error) {
                res.status(401).json(returnResponse(true, "openaierror", "openaierror"));

                return;
            }
        } else {
            res.status(401).json(returnResponse(true, "typemorethanone", "입력 데이터 없음"));

            return;
        }
    }
);

module.exports = router;