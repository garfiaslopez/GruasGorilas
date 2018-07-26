var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var RouteExample = new Schema({
	origin: {
        type: String,
		required: true
	},
	destiny: {
		type: String,
		required: true
	},
    price:{
        type: Number,
        default: 0.0,
        required: true
    },
    location:{
		type: String,
		default: 'MX'
    },
    created: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model("RouteExample",RouteExample);
