require("dotenv").config();
const express = require("express");
const router = express.Router();
const mainLayout = "../views/layouts/main";
const mainLayout_LoggedIn = "../views/layouts/main_LoggedIn";
const asyncHandler = require("express-async-handler");
const bcrypt = require("bcrypt");
const UserSchema = require("../models/User");
const Post = require("../models/Post");
const mongoose = require("mongoose");
const loginMiddleWare = require("./checkLogin");
const serverWorks = require("../serverSideWorks/tagCollection");

const User = mongoose.models.User || mongoose.model("User", UserSchema);

router.post(["/"], 
    loginMiddleWare.ifLoggedInThenProceed, 
    asyncHandler(async (req, res) => {
        const {title, content} = req.body;

        const pageContent = {
            title: title,
            content: content,
        }
        const pageInfo = {
            title: "Welcome to Mentally::Posting"
        };
        const accountInfo = {
            id: req.session.user.id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };

        res.render("posts/addPost", {pageInfo, accountInfo, pageContent, layout: mainLayout_LoggedIn});
        //res.send({pageInfo, accountInfo, pageContent, layout: mainLayout_LoggedIn});
}));

router.post(["/upload"],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const {title, content, content_additional, tags} = req.body;

        const newTags = serverWorks.removeSpacesAndHashes(tags);

        try {
            const newPost = await Post.create({
                title: title,
                details: content,
                additional_material: content_additional,
                tag: newTags,
                user: req.session.user._id,
            });

            req.session.user = await User.findByIdAndUpdate(req.session.user._id,
                {$push: {posts: newPost._id}},
                {new: true}
            );

            res.redirect("/posts/view/" + newPost._id);
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
}));

router.get(["/view/:id"],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        try {
            const post = await Post.findById(req.params.id);
            const user = await post.populate('user');

            // console.log(post);
            // console.log(user.user.id);

            const pageContent = {
                postid: post._id,
                title: post.title,
                details: post.details,
                additional_material: post.additional_material,
                createdAt: post.createdAt,
                editedAt: post.editedAt,
                tag: post.tag,
                usernick: user.user.usernick,
                userid: user.user._id,
            };
            const pageInfo = {
                title: "Welcome to Mentally::Posts::" + post.title
            };
            const accountInfo = {
                id: req.session.user._id,
                usernick: req.session.user.usernick,
                address: req.session.user.address,
                email: req.session.user.email,
            };

            res.render("posts/viewPost", {pageContent, pageInfo, accountInfo, layout: mainLayout_LoggedIn});
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
    })
);

router.patch(["/edit/:id"],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        try {
            const {content_additional, tags} = req.body;
            const post = await Post.findById(req.params.id);

            const newTags = serverWorks.removeSpacesAndHashes(tags);

            /* not to allow unauthorized users */
            if (post.user._id != req.session.user._id) {
                res.redirect("/error");

                return;
            }

            const alteredPost = await Post.findByIdAndUpdate(req.params.id, 
                {
                    additional_material: content_additional,
                    tag: newTags,
                    editedAt: Date.now(),
                }, 
                {new: true})

            res.redirect("/posts/view/" + alteredPost._id);

            return;
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
    })
);

router.get(["/edit/:id"],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        try {
            const post = await Post.findById(req.params.id);

            /* not to allow unauthorized users */
            if (post.user._id != req.session.user._id) {
                res.redirect("/error");

                return;
            }

            const pageContent = {
                title: post.title,
                details: post.details,
                additional_material: post.additional_material,
                tag: post.tag,
                id: post._id,
            }
            const pageInfo = {
                title: "Welcome to Mentally::Posts-Edit::" + post.title
            };
            const accountInfo = {
                id: req.session.user.id,
                usernick: req.session.user.usernick,
                address: req.session.user.address,
                email: req.session.user.email,
            };

            res.render("posts/editPost", {pageContent, pageInfo, accountInfo, layout: mainLayout_LoggedIn});
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
    })
);

router.delete(["/delete/:id"],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        try {
            const post = await Post.findById(req.params.id);

            /* not to allow unauthorized users */
            if (post.user._id != req.session.user._id) {
                res.redirect("/error");

                return;
            }

            await Post.findByIdAndDelete(req.params.id);
            req.session.user = await User.findByIdAndUpdate(req.session.user._id, {
                $pull: {posts: req.params.id}
            }, {
                new: true
            });

            res.redirect("/posts/mine");

            return;
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
    })
);

router.get(["/mine"],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        try {
            const posts = [];
            for (const postid of req.session.user.posts) {
                const post = await Post.findById(postid);

                posts.push(post);
            }

            const pageContent = {
                posts: posts,
            }
            const pageInfo = {
                title: "Welcome to Mentally::My Posts",
            };
            const accountInfo = {
                id: req.session.user.id,
                usernick: req.session.user.usernick,
                address: req.session.user.address,
                email: req.session.user.email,
            };

            res.render("posts/myPostList", {pageContent, pageInfo, accountInfo, layout: mainLayout_LoggedIn});
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
    })
);

module.exports = router;