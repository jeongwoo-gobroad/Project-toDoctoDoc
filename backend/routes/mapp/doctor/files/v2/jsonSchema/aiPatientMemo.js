const { z } = require("zod");

const shortMemoSchema = z.object({
    patientName: z.string(),
    shortMemo: z.string(),
});

module.exports = shortMemoSchema;