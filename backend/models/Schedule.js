const mongoose = require("mongoose");

const TimeChunkSchema = new mongoose.Schema({
    from: {
        type: String, // 24시제의 00:00 형식으로 기입
    },
    to: {
        type: String, // 24시제의 00:00 형식으로 기입
    },
    memo: {
        type: String // 일정에 관한 간략한 메모
    },
    isAvailableTime: {
        type: Boolean,
    }
});

const ScheduleSchema = new mongoose.Schema({
    isDoctor: {
        type: Boolean,
        default: false,
    },
    isCounselor: {
        type: Boolean,
        default: false,
    },
    userid: {
        type: mongoose.Schema.Types.ObjectId, 
        required: true,
        ref: 'User',
    },
    updatedAt: {
        type: Date,
        default: Date.now
    },
    availableTime: [{ // 0: 월요일 6: 일요일
        type: [TimeChunkSchema],
    }],
    minimalAppointmentTime: {
        type: Number,
    }
});

module.exports = mongoose.model("Schedule", ScheduleSchema);