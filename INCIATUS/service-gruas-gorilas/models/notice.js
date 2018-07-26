var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var NoticeSchema = new Schema({
	title: {
        type: String
	},
	description: {
		type: String,
		required: true
	},
    created: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model("Notice",NoticeSchema);
