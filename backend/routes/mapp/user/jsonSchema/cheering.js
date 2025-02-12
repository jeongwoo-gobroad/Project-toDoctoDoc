const { z } = require("zod");

const cheeringSchema = z.object({
    cheering: z.string(),
});

const cheeringArray = z.object({
    sentences: z.array(cheeringSchema)
});

module.exports = cheeringArray;