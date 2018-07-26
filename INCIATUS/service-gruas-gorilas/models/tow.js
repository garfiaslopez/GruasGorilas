var mongoose = require("mongoose");
var Schema = mongoose.Schema;
var Config = require("../config/config");

var TowSchema = new Schema({
    group: {
		type: Schema.ObjectId,
		ref: 'Group'
	},
    serialNumber:{
        type: String
    },
	economicNumber: {
		type: String,
    },
	plate:{
        type: String,
	},
    policyCompany: {
        type: String
    },
	policyNumber: {
		type: String
	},
    expirationDate: {
        type: Date
    },
    aditional: {
        type: String
    },
    date: {
        type: Date,
        default: Date.now()
    }
});

//Return the module
module.exports = mongoose.model("Tow",TowSchema);
