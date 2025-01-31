require("dotenv").config();
const express = require("express");
const router = express.Router();
const { checkIfLoggedIn, ifPremiumThenProceed } = require("../checkingMiddleWare");
const returnResponse = require("../standardResponseJSON");
const { getTokenInformation } = require("../../auth/jwt");
const UserSchema = require("../../../models/User");
const mongoose = require("mongoose");
const Review = require("../../../models/Review");
const Chat = require("../../../models/Chat");
const Psychiatry = require("../../../models/Psychiatry");
const userEmitter = require("../../../events/eventDrivenLists");

const User = mongoose.model("User", UserSchema);

router.get(["/visited"],
    checkIfLoggedIn,
    // ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const usr = await User.findById(user.userid).populate('visitedPsys');

            res.status(200).json(returnResponse(false, "returnVisitedPsyList", usr.visitedPsys));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtReviewVisited", "-"));

            console.error(error, "errorAtUserVisitedGET");

            return;
        }
    }
);

router.post(["/write"], 
    checkIfLoggedIn,
    // ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);
        const {pid, stars, content} = req.body;

        try {
            if (!(await User.findById(user.userid)).visitedPsys.toString().includes(pid)) {
                res.status(401).json(returnResponse(true, "notVisitedYet", "-"));

                return;
            }

            if (stars < 0 || stars > 5) {
                stars = 5;
            }

            const review = await Review.create({
                user: user.userid,
                place_id: pid,
                stars: stars,
                content: content,
            });

            await User.findByIdAndUpdate(user.userid, {
                $push: {reviews: review._id}
            });

            userEmitter.emit('reviewUpdated', pid, 0, stars, -1);

            await Psychiatry.findByIdAndUpdate(pid, {
                $push: {reviews: review._id}
            });

            res.status(200).json(returnResponse(false, "reviewWritten", "-"));

            return;
        } catch (error) {
            console.log(error, "errorAtReviewWriting");

            res.status(403).json(returnResponse(true, "errorAtReviewWriting", "-"));

            return;
        }
    }
);

router.patch(["/edit/:id"], 
    checkIfLoggedIn,
    // ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);
        const {stars, content, pid} = req.body;

        try {
            const review = await Review.findById(req.params.id);

            if (!review || review.user != user.userid) {
                res.status(401).json(returnResponse(true, "notYourReviewOrNoSuchReview", "-"));

                return;
            }

            if (stars < 0 || stars > 5) {
                stars = 5;
            }

            userEmitter.emit('reviewUpdated', pid, review.stars, stars, 0);

            await Review.findByIdAndUpdate(req.params.id, {
                stars: stars,
                content: content,
                updatedAt: Date.now()
            });

            res.status(200).json(returnResponse(false, "reviewEdited", "-"));

            return;
        } catch (error) {
            console.log(error, "errorAtReviewEditing");

            res.status(403).json(returnResponse(true, "errorAtReviewEditing", "-"));

            return;
        }
    }
);

router.delete(["/delete/:id"], 
    checkIfLoggedIn,
    // ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);
        const {pid} = req.body;

        try {
            const review = await Review.findById(req.params.id);

            if (!review || review.user != user.userid) {
                res.status(401).json(returnResponse(true, "notYourReviewOrNoSuchReview", "-"));

                return;
            }

            userEmitter.emit('reviewUpdated', pid, review.stars, 0, 1);

            await User.findByIdAndUpdate(user.userid, {
                $pull: {reviews: req.params.id}
            });
            await Psychiatry.findByIdAndUpdate(review.place_id, {
                $pull: {reviews: req.params.id}
            });
            await Review.findByIdAndDelete(req.params.id);

            res.status(200).json(returnResponse(false, "reviewDeleted", "-"));

            return;
        } catch (error) {
            console.log(error, "errorAtReviewDeleting");

            res.status(403).json(returnResponse(true, "errorAtReviewDeleting", "-"));

            return;
        }
    }
);

router.get(["/listing/:placeid"], 
    checkIfLoggedIn,
    // ifPremiumThenProceed,
    async (req, res, next) => {
        try {
            const reviews = await Psychiatry.findById(req.params.placeid).populate('reviews', '-user');

            res.status(200).json(returnResponse(false, "reviewListing", reviews));

            return;
        } catch (error) {
            console.log(error, "errorAtReviewListing");

            res.status(403).json(returnResponse(true, "errorAtReviewListing", "-"));

            return;
        }
    }
);

router.get(["/myReviews"],
    checkIfLoggedIn,
    // ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const reviews = await User.findById(user.userid).populate('reviews', '-user');

            res.status(200).json(returnResponse(false, "myReviewListing", reviews));

            return;
        } catch (error) {
            console.log(error, "errorAtReviewListing");

            res.status(403).json(returnResponse(true, "errorAtReviewListing", "-"));

            return;
        }
    }
);

module.exports = router;