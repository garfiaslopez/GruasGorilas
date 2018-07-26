var Config = require("../config/config");

var mongoose = require("mongoose");
var Schema = mongoose.Schema;
var autoIncrement = require('mongoose-auto-increment');
var mongoosePaginate = require('mongoose-paginate');
var moment = require('moment');

var connection = mongoose.createConnection(Config.dbMongo);
autoIncrement.initialize(connection);

var OrderSchema = new Schema({
	user_id: {
		type: Schema.ObjectId,
		ref: 'User'
	},
	operator_id: {
		type: Schema.ObjectId,
		ref: 'User'
	},
	tow: {
		type: Schema.ObjectId,
		ref: 'Tow'
	},
	group: {
		type: Schema.ObjectId,
		ref: 'Group'
	},
	order_id: {
		type: Number
	},
	carinfo: {
		model: {
			type:String,
			default: ""
		},
		brand: {
			type:String,
			default: ""
		},
		color: {
			type:String,
			default: ""
		},
		plate: {
			type:String,
			default: ""
		}
	},
	conditions: {
		type: String,
		default: "Sin Condiciones"
	},
	origin: {
		denomination: {
			type: String,
			default: ""
		},
		cord: {
	    	type: [Number],  // [<longitude>, <latitude>]
	    	index: '2dsphere'      // create the geospatial index
	    }
	},
	destiny: {
	    denomination: {
			type: String,
			default: "Sin direccion"
		},
	    cord: {
	    	type: [Number],  // [<longitude>, <latitude>]
	    	index: '2dsphere'      // create the geospatial index
	    }
	},
	total: {
		type: Number,
		default: 0.0
	},
	isSchedule: {
		type: Boolean,
		default: false
	},
	dateSchedule: {
		type: Date
	},
	isQuotation: {
		type: Boolean,
		default: false
	},
	status: {
    	type: String,
    	default:"Requesting"
    },
	paymethod: {
		type: String,
		default: "Cash"
	},
	cardForPayment: {
		type: String,
		default: ""
	},
	transaction_id: {
		type: String
	},
	isPaid: {
		type: Boolean,
		default: false,
	},
    date: {
        type: Date
    }
});

OrderSchema.plugin(autoIncrement.plugin, {
	model: 'Order',
	field: 'order_id',
	startAt: 1,
    incrementBy: 1
});
OrderSchema.plugin(mongoosePaginate);

//Return the module
module.exports = mongoose.model("Order",OrderSchema);
