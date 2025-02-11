const { z } = require("zod");

const appointmentSchema = z.object({
    startFrom: z.string(),
    // endAt: z.string(),
    duration: z.number(),
    patientName: z.string(),
    shortMemo: z.string(),
});

const dailyScheduleSchema = z.object({
    appointments: z.array(appointmentSchema)
});

module.exports = dailyScheduleSchema;