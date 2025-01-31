require("dotenv").config();
const express = require("express");
const router = express.Router();
const { checkIfLoggedIn, ifPremiumThenProceed } = require("../checkingMiddleWare");
const returnResponse = require("../standardResponseJSON");
const { getTokenInformation } = require("../../auth/jwt");
const UserSchema = require("../../../models/User");
const mongoose = require("mongoose");
const Review = require("../../../models/Review");
const Premium_Psychiatry = require("../../../models/Premium_Psychiatry");
const Chat = require("../../../models/Chat");
const Psychiatry = require("../../../models/Psychiatry");
const userEmitter = require("../../../events/eventDrivenLists");

const User = mongoose.model("User", UserSchema);

router.post(["/write"], 
    checkIfLoggedIn,
    ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);
        const {cid, pid, stars, content} = req.body;

        try {
            const chat = await Chat.findById(cid).populate({
                path: 'doctor',
                select: 'isPremiumPsy'
            });

            if (!chat.hasAppointmentDone) {
                res.status(401).json(returnResponse("true", "cannotReviewNow", "-"));

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

            if (chat.doctor.isPremiumPsy) {
                userEmitter.emit('reviewUpdated', pid, true, 0, stars, -1);
                await Premium_Psychiatry.findByIdAndUpdate(pid, {
                    $push: {reviews: review._id}
                });
            } else {
                userEmitter.emit('reviewUpdated', pid, false, 0, stars, -1);
                await Psychiatry.findByIdAndUpdate(pid, {
                    $push: {reviews: review._id}
                });
            }

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
    ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);
        const {stars, content, pid, isPremiumPsy} = req.body;

        try {
            const review = await Review.findById(req.params.id);

            if (!review || review.user != user.userid) {
                res.status(401).json(returnResponse(true, "notYourReviewOrNoSuchReview", "-"));

                return;
            }

            if (stars < 0 || stars > 5) {
                stars = 5;
            }

            userEmitter.emit('reviewUpdated', pid, isPremiumPsy, review.stars, stars, 0);

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
    ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);
        const {pid, isPremiumPsy} = req.body;

        try {
            const review = await Review.findById(req.params.id);

            if (!review || review.user != user.userid) {
                res.status(401).json(returnResponse(true, "notYourReviewOrNoSuchReview", "-"));

                return;
            }

            userEmitter.emit('reviewUpdated', pid, isPremiumPsy, review.stars, 0, 1);

            await User.findByIdAndUpdate(user.userid, {
                $pull: {reviews: req.params.id}
            });
            if (await Premium_Psychiatry.findById(review.place_id)) {
                await Premium_Psychiatry.findByIdAndUpdate(review.place_id, {
                    $pull: {reviews: req.params.id}
                });
            } else {
                await Psychiatry.findByIdAndUpdate(review.place_id, {
                    $pull: {reviews: req.params.id}
                });
            }
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
    ifPremiumThenProceed,
    async (req, res, next) => {
        try {
            let reviews = false;
            if (req.query.isPremium) {
                reviews = await Premium_Psychiatry.findById(req.params.placeid).populate('reviews', '-user');
            } else {
                reviews = await Psychiatry.findById(req.params.placeid).populate('reviews', '-user');
            }

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
    ifPremiumThenProceed,
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