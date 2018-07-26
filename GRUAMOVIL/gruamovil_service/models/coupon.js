var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var CouponSchema = new Schema({
	description: {
        type: String
	},
	code:{
        type: String,
		trim: true,
		required: true,
        index: {unique: true, dropDups: true}
    },
    discount:{
        type: Number,
        default: 0.0,
        required: true
    },
    expiration:{
        type: Date
    },
    isActive:{
        type:Boolean,
        default:true
    },
    created: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model("Coupon",CouponSchema);
