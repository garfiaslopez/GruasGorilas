var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var CarSchema = new Schema({
    user_id: {
        type: Schema.ObjectId,
        ref: 'User'
	},
	brand: {
		type: String,
		trim: true
    },
    plates: {
		type: String,
		trim: true
    },
    model: {
        type: String,
        trim: true
    },
    color: {
        type: String,
        trim: true
    },
    date: {
        type: Date,
        default: Date.now()
    }
});

module.exports = mongoose.model("Car",CarSchema);
