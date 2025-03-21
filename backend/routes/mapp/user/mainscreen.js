require("dotenv").config();
const express = require("express");
const router = express.Router();
const openai = require("openai");
const { checkIfLoggedIn, ifTokenIsNotExpriredThenProceed } = require("../checkingMiddleWare");
const { ifDailyChatNotExceededThenProceed, ifDailyRequestNotExceededThenProceed } = require("../limitMiddleWare");
const returnResponse = require("../standardResponseJSON");
const { getTokenInformation } = require("../../auth/jwt");
const UserSchema = require("../../../models/User");
const { removeSpacesAndHashes } = require("../../../middleware/usefulFunctions");
const Post = require("../../../models/Post");
const mongoose = require("mongoose");
const returnLongLatOfAddress = require("../../../middleware/getcoordinate");
const bcrypt = require("bcrypt");
const userEmitter = require("../../../events/eventDrivenLists");
const { tagCountRefreshWorksViaRedis, viewCountRefreshWorksViaRedis, tagCountMinusWorksViaRedis } = require("../../../serverSideWorks/redisBubbleCollection");
const Redis = require("../../../config/redisObject");

const User = mongoose.model("User", UserSchema);

router.post(["/query"],
    checkIfLoggedIn,
    ifDailyRequestNotExceededThenProceed,
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
                            "content": process.env.OPENAI_PROMPT,
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
                console.log(error, "errorAtOpenAIPrompt");

                res.status(401).json(returnResponse(true, "openaierror", "openaierror"));

                return;
            }
        } else {
            res.status(403).json(returnResponse(true, "typemorethanone", "입력 데이터 없음"));

            return;
        }
    }
);
 
router.post(["/upload"],
    checkIfLoggedIn,
    async(req, res, next) => {
        const {title, content, content_additional, tags} = req.body;

        const user = await getTokenInformation(req, res);

        const newTags = removeSpacesAndHashes(tags);

        try {
            const newPost = await Post.create({
                title: title,
                details: content,
                additional_material: content_additional,
                tag: newTags,
                user: user.userid,
                editedAt: Date.now(),
            });

            await User.findByIdAndUpdate(user.userid,
                {$push: {posts: newPost._id}},
                {new: true}
            );

            tagCountRefreshWorksViaRedis(newTags);

            res.status(200).json(returnResponse(false, "ai_answer", newPost));

            return;
        } catch (error) {
            console.error(error, "errorAtPostUpload");

            res.status(401).json(returnResponse(true, "uploaderror", "uploaderror"));

            return;
        }
    }
);

router.get(["/view/:id"], 
    checkIfLoggedIn,
    async(req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            let redis = new Redis();

            await redis.connect();

            const post = await Post.findById(req.params.id).populate("user");

            let isOwner = false;
            // let viewed = await getCache("User: " + user.userid);

            if (post.user._id == user.userid) {
                isOwner = true;
            }

             /* logic for view counting */
            // if (!(viewed) || !viewed.includes(post._id.toString())) {
            //     if (!viewed) {
            //         viewed = [];
            //     }
            //     viewed.push(post._id);
            //     setCacheForNDaysAsync("User: " + user.userid, viewed, 1);
            //     viewCountRefreshWorksViaRedis(post.tag);
            //     // console.log("View++ for postid", post._id, "view:", post.views + 1);
            //     post.views++;
            //     await post.save();
            // }

            const pageContent = {
                postid: post._id,
                title: post.title,
                details: post.details,
                additional_material: post.additional_material,
                createdAt: post.createdAt,
                editedAt: post.editedAt,
                tag: post.tag,
                usernick: post.user.usernick,
                userid: post.user._id,
                views: post.views,
                isOwner: isOwner,
            };

            res.status(200).json(returnResponse(false, "view", pageContent));

            if (!(await redis.doesHashContains("VIEW:" + req.userid, post._id))) {
                viewCountRefreshWorksViaRedis(post.tag);

                post.views++;
                await post.save();

                // setSetForNDays("VIEW:" + req.userid, post._id, 1);
                await redis.setHashValueWithTTL("VIEW:" + req.userid, post._id, 1, 1);
                // console.log("Set cache");
            }

            redis.closeConnnection();
            redis = null;

            return;
        } catch (error) {
            console.error(error, "errorAtUserPostView");

            res.status(401).json(returnResponse(true, "viewerror", "viewerror"));

            return;
        }
    }
);

router.patch(["/edit/:id"],
    checkIfLoggedIn,
    async(req, res, next) => {
        const {content_additional, tags} = req.body;

        const user = await getTokenInformation(req, res);

        const newTags = removeSpacesAndHashes(tags);

        try {
            const check = await Post.findById(req.params.id);

            if (check.user != user.userid || !check) {
                res.status(400).json(returnResponse(true, "notOwnerOrNoSuchPostExists", "-"));

                return;
            }

            tagCountMinusWorksViaRedis(check.tag);

            const post = await Post.findByIdAndUpdate(req.params.id, {
                additional_material: content_additional,
                tag: newTags,
                editedAt: Date.now(),
            }, {new: true});

            tagCountRefreshWorksViaRedis(newTags);

            res.status(200).json(returnResponse(false, "edit", post));

            return;
        } catch (error) {
            console.error(error, "errorAtEditingPost");

            res.status(401).json(returnResponse(true, "editerror", "editerror"));

            return;
        }
    }
);

router.delete(["/delete/:id"],
    checkIfLoggedIn,
    async(req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const check = await Post.findById(req.params.id);

            if (check.user != user.userid || !check) {
                res.status(400).json(returnResponse(true, "notOwnerOrNoSuchPostExists", "-"));

                return;
            }

            tagCountMinusWorksViaRedis(check.tag);

            await Post.findByIdAndDelete(req.params.id);
            await User.findByIdAndUpdate(user.userid, {
                $pull: {posts: req.params.id}
            });

            res.status(200).json(returnResponse(false, "delete", "delete"));

            return;
        } catch (error) {
            res.status(401).json(returnResponse(true, "deleteerror", "deleteerror"));

            return;
        }
    }
);

router.get(["/myPosts"],
    checkIfLoggedIn,
    async(req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const userinfo = await User.findById(user.userid).populate("posts", "title tag createdAt editedAt _id");

            const posts = userinfo.posts.sort((a, b) => {
                return b.editedAt - a.editedAt;
            });

            res.status(200).json(returnResponse(false, "myposts", posts));

            return;
        } catch (error) {
            res.status(401).json(returnResponse(true, "mypostserror", "mypostserror"));

            return;
        }
    }
);

router.get(["/userInfo"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const userinfo = await User.findById(user.userid, "id usernick email address limits isPremium");

            res.status(200).json(returnResponse(false, "info", userinfo));

            return;
        } catch (error) {
            res.status(401).json(returnResponse(true, "infoerror", "infoerror"));

            return;
        }
    }
);

router.patch(["/editUserInfo"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const {usernick, email, postcode, address, detailAddress, extraAddress, password, password2} = req.body;

        const user = await getTokenInformation(req, res);

        try {
            const {long, lat} = await returnLongLatOfAddress(address);

            await User.findByIdAndUpdate(user.userid,
                {
                    usernick: usernick,
                    address: {
                        postcode: postcode,
                        address: address,
                        detailAddress: detailAddress,
                        extraAddress: extraAddress,
                        longitude: long,
                        latitude: lat,
                    },
                    email: email,
                },
            );

            if (password && password.length > 8 && password != password2) {
                res.status(401).json(returnResponse(true, "password_not_match", "password_not_match"));

                return;
            } else if (password && password.length > 8 && password == password2) {
                const hashedPassword = await bcrypt.hash(password, 10);

                await User.findByIdAndUpdate(user.userid, {
                    password: hashedPassword
                });
            }
            
            const newUserInfo = await User.findById(user.userid, "id usernick email address limits isPremium");

            res.status(200).json(returnResponse(false, "editinfo", newUserInfo));

            return;
        } catch (error) {
            console.error(error);

            res.status(401).json(returnResponse(true, "editinfoerror", "editinfoerror"));

            return;
        }
    }
);

module.exports = router;