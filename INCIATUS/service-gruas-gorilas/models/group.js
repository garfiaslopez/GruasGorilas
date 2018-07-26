var mongoose = require("mongoose");
var Schema = mongoose.Schema;
var Config = require("../config/config");

var GroupSchema = new Schema({
	name: {
		type: String,
		trim: true,
	},
	phone: {
		type: String,
    },
	responsibleName:{
		type: String,
	},
	responsiblePhone:{
        type: String,
	},
	address: {
		type: String
	},
    rfc: {
        type: String
    },
    outCityServices: {
        type: Boolean,
        default: false
    },
    tows: [{
        type: Schema.ObjectId,
        ref: 'Tow'
    }],
    operators_id: [{
        type: Schema.ObjectId,
        ref: 'User'
    }],
    date: {
        type: Date,
        default: Date.now()
    }
});

//Return the module
module.exports = mongoose.model("Group",GroupSchema);
