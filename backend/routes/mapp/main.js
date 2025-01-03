const express = require("express");
const router = express.Router();

router.get(["/about"], 
    (req, res, next) => {
        res.status(200).json({
            error: false,
            result: "Good",
            content: {
                string: "복잡해진 현대 사회에서 정신 질환을 앓고 있는 사람의 수는 매년 증가하지만, 정신과 방문에 대한 인식이 여전히 부정적이다. 따라서, 이러한 부정적인 인식을 해결하고 현대인의 건강한 정신건강을 위해, 본인의 정신건강을 지속적으로 추적, 관리하고 이를 의사와 공유, 큐레이팅하는 어플리케이션이다. 이 어플리케이션은 크게 AI를 기반으로 한 고민 해결, AI 챗봇과의 고민 상담, GraphBoard를 통한 고민 해결 내역 공유 시스템, 주변 정신과 찾기, AI 기반 고민 해결 및 AI 챗봇과의 고민 상담 내역을 기반으로 한 주변 정신과 전문의 큐레이팅 및 DM 시스템을 가지고 있다. 이 시스템의 가장 독특한 점은, 기존에는 환자가 정신과를 찾아가야 했고, 이 과정에서 부정적인 인식이 생겨났다면, 이 시스템은 별도로 상담을 요청할 필요가 없이 기존에 환자 본인이 AI와 나누었던 대화를 공유하기만 하면 그것 만으로도 큐레이팅 시스템이 작동하여, 본인에게 가장 적합한 의사를 매칭시켜주는 시스템이다. 즉, 환자가 의사를 찾아가는 것이 아닌, 의사가 환자를 찾아가는 방식의 패러다임 전환을 통해서 정신과에 대한 인식 개선을 도모 및 현대인들의 정신 건강을 개선하고자 한다."
            }
        })

        return;
    }
);

module.exports = router;