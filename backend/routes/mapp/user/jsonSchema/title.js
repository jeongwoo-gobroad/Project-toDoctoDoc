const { z } = require("zod");

const titleSchema = z.object({
    title: z.string(),
});

module.exports = titleSchema;