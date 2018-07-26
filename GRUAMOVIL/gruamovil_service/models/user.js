var mongoose = require("mongoose");
var Schema = mongoose.Schema;
var bcrypt = require("bcrypt-nodejs");
var encrypt = require('mongoose-encryption');
var Config = require("../config/config");

var UserSchema = new Schema({
	typeuser: {
		type: String,
		default: 'user'   // user || vendor ||
	},
	group: {
		type: Schema.ObjectId,
		ref: 'Group'
	},
	tow: {
		type: Schema.ObjectId,
		ref: 'Tow'
	},
	name: {
		type: String,
		trim: true,
	},
	username: {
		type: String,
		trim: true,
	},
	email: {
		address:{
			type: String,
			trim: true,
			required: true,
			index: {unique: true, dropDups: true}
		},
		token: {
			type: String
		},
		isVerified: {
			type: Boolean,
			default: false
		}
	},
	password: {
		type: String,
		required: true
	},
	phone:{
		type: String,
		trim: true,
		index: {unique: true, dropDups: true}
	},
	push_id: {
		type:String
	},
	coupons: [{
		coupon_id:{
			type: Schema.ObjectId,
			ref: 'Coupon'
		},
		used: {
			type: Boolean,
			default: false
		}
	}],
	gender:{
		type: String,
		trim: true
	},
	birthdate:{
		type: String,
		trim: true
	},
	paydata:{
		clabe:{
			type: String,
			trim: true
		},
		bank:{
			type: String,
			trim: true
		},
		name:{
			type: String,
			trim: true
		}
	},
	othercontact: {
		name: {
			type: String,
			trim: true
		},
		phone: {
			type: String,
			trim: true
		}
	},
	conektauser: {
		type: String
	},
	paymethod: {
		type: String
	},
	loc: {
	    denomination: String,
	    cord: {
	    	type: [Number],  // [<longitude>, <latitude>]
	    	index: '2dsphere'      // create the geospatial index
	    },
	    date: {type: Date, default: Date.now()}
	},
	rate: {
		onestar: {
			type: Number,
			default: 0
		},
		twostar: {
			type: Number,
			default: 0
		},
		threestar: {
			type: Number,
			default: 0
		},
		fourstar: {
			type: Number,
			default: 0
		},
		fivestar: {
			type: Number,
			default: 0
		},
		average: {
			type: Number,
			default: 0.0
		}
	},
	driverLicense: {
		firstNumber: {
			type: String
		},
		secondNumber: {
			type: String
		},
		firstTypeLicense: {
			type: String
		},
		secondTypeLicense: {
			type: String
		}
	},
	blocked: {
		type: Boolean,
		default: false
	},
	uuid: {
		type: String,
		default: ""
	},
    date: {
        type: Date,
        default: Date.now()
    },
    available: {
    	type: Boolean,
    	default: true
    }
});

function hashPassword(next){
	var user = this;
	if(!user.isModified("password")){
		return next();
	}
	bcrypt.hash(user.password, null, null, function(err,hash){
		if(err){
			return next(err);
		}
		user.password = hash;
		next();
	})
}
function calculateAvg(next){
	var user = this;
	var sum = (1*user.rate.onestar) + (2*user.rate.twostar) + (3*user.rate.threestar) + (4*user.rate.fourstar) + (5*user.rate.fivestar);
	var totalStars = user.rate.onestar + user.rate.twostar + user.rate.threestar + user.rate.fourstar + user.rate.fivestar;
	user.rate.average = sum/totalStars;
	next();
}

UserSchema.pre("save", hashPassword);
UserSchema.pre("save", calculateAvg);

function isEqualPassword(password){
	var user = this;
	return bcrypt.compareSync(password,user.password);
}

UserSchema.methods.comparePassword = isEqualPassword;

var encryptKey = Config.encKey;
var signedKey = Config.sigKey;

UserSchema.plugin(encrypt, {
	encryptionKey: encryptKey,
	signingKey: signedKey,
	encryptedFields: ['paydata','paymethod']
});

//Return the module
module.exports = mongoose.model("User",UserSchema);
