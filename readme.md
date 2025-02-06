# Project ToDocToDoc(토닥toDoc)

##### A project by Jeongwoo Kim, KNU CSE

---
###### Participants
> - Jeongwoo Kim (Project Leader, Backend Developer, Web Frontend Developer, AI Prompt Developer, KNU CSE)
> - Hyunjong Yoon (Flutter Frontend Developer, AI Prompt Developer, KNU SME)
> - Junhyeong Jeon (Flutter Frontend Developer, KNU CSE)

---
### What is this project about?

The number of people suffering from mental illness increases every year in the complex modern society, but the perception of psychiatric visits is still negative. Therefore, it is an application that continuously tracks, manages, and curates one's mental health for solving these negative perceptions and for the healthy mental health of modern people. This application is largely based on AI-based problem solving, counseling with AI chatbots, sharing of problem solving through GraphBoard, finding surrounding psychiatrists, curating and DM systems for surrounding psychiatrists based on AI chatbots, and counseling with AI chatbots. The most unique thing about this system is that if a patient previously had to go to a psychiatrist, and negative perceptions were created in this process, the system works by simply sharing the conversation that the patient had with AI without having to ask for counseling separately, and matches the most suitable doctor for him. In other words, it aims to improve awareness of psychiatry and improve the mental health of modern people through a paradigm shift in the way doctors visit patients, rather than patients visit doctors.

복잡해진 현대 사회에서 정신 질환을 앓고 있는 사람의 수는 매년 증가하지만, 정신과 방문에 대한 인식이 여전히 부정적이다. 따라서, 이러한 부정적인 인식을 해결하고 현대인의 건강한 정신건강을 위해, 본인의 정신건강을 지속적으로 추적, 관리하고 이를 의사와 공유, 큐레이팅하는 어플리케이션이다. 이 어플리케이션은 크게 AI를 기반으로 한 고민 해결, AI 챗봇과의 고민 상담, GraphBoard를 통한 고민 해결 내역 공유 시스템, 주변 정신과 찾기, AI 기반 고민 해결 및 AI 챗봇과의 고민 상담 내역을 기반으로 한 주변 정신과 전문의 큐레이팅 및 DM 시스템을 가지고 있다. 이 시스템의 가장 독특한 점은, 기존에는 환자가 정신과를 찾아가야 했고, 이 과정에서 부정적인 인식이 생겨났다면, 이 시스템은 별도로 상담을 요청할 필요가 없이 기존에 환자 본인이 AI와 나누었던 대화를 공유하기만 하면 그것 만으로도 큐레이팅 시스템이 작동하여, 본인에게 가장 적합한 의사를 매칭시켜주는 시스템이다. 즉, 환자가 의사를 찾아가는 것이 아닌, 의사가 환자를 찾아가는 방식의 패러다임 전환을 통해서 정신과에 대한 인식 개선을 도모 및 현대인들의 정신 건강을 개선하고자 한다.

---
### How this project is built
* Backend
    - node.js
* Frontend
    -  ejs View Engine
    -  Flutter
---
### Documentation

Please refer to /documentation.docx

---
### Design Architecture

Please refer to /uxDesign

---
### Version History

* #### 0.8.0
    * Initial commit to GitHub
    * Supports [Home, About, My Posts, GraphBoard, Finding a Close Psychiatry, AI Chatbot, AI-based problem solving, Psychiatrist Curating, DM with Psychiatrist] Features based on node.js and ejs view engine on website
    * Only supported in Korean (Ko/KR)
  
* #### 0.9.0
    * The chatbot has been improved to support asynchronous chat, and there have been enhancements in the aspect of database storage for chatbot data.
    * Frontend implementation through Flutter has been added.

* #### 0.9.1
    * The user authentication process of web version has been changed from session-only-method to session-and-token-hybrid-method. (No need to re-login after server reboot while developing!)
    * Flutter frontend features implemented so far: login(register) -> about/welcome page -> Query -> Query result -> Query share -> My query list

* #### 0.9.2
    * AI Chat feature has been enabled in Flutter app version!
    * Totally redesigned UX layout for Flutter app version.
    * Token related backend part has been redesigned.

* #### 0.9.3
    * AI Chat listing feature has been enabled in Flutter app version.
    * User info editing feature has been enabled in Flutter app version.
    * Advanced Business Model: Premium Psychiatry related schema and admin feature has been updated.
    * /mapp/curate/around?radius="someValue" API has been implemented.

* #### 0.9.4
    * Currently implementing star rating system...
    * implemented address-based user-doctor curation mechanism.
    * Random welcome message printing feature has been enabled in Flutter app version.
    * Finding near psychiatry feature has been implemented in Flutter app version, but no map printing yet.
    * Premium psychiatry advertisement feature has been implemented in Flutter app version.

* #### 0.9.5
    * Currently implementing DM system...
    * Currently implementing star rating system...
    * Implemented Redis DB system.

* #### 0.9.6
    * Currently implementing DM system...
    * Currently implementing Review system...
    * Currently implementing Psy-Premiumify system...

* #### 0.9.7
    * Implemented DM System! Yay!
    * Currently implementing Review system...
    * Currently implementing Psy-Premiumify system...
    * Fixed some DM-related bugs
    * Currently implementing Push notification system...

* #### 0.9.8
    * DM system has been improved.
    * Currently implementing Review system...
    * Currently implementing Psy-Premiumify system...
    * Currently implementing Push notification system...
    * Currently implementing Appointment system...

* #### 0.9.9
    * DM system has been improved.
    * Currently implementing Review system...
    * Currently implementing Psy-Premiumify system...
    * Currently implementing Push notification system... <- Partially implemented. Yay!
    * Implemented Appointment system.
    * Implemented View counting system with GraphBoard layout.
    * Currently implementing Doctor profile image & Psychiatry profile image system...