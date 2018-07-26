var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var CarworkshopSchema = new Schema({
	name:{
        type: String,
		trim: true,
		required: true,
        index: {unique: true, dropDups: true}
    },
    logo:{
        type: String
	},
	type:{
		type: String,
		default: 'Franquicia'
	},
	categorie:{
		type: String,
		default: 'Uncategorized'
	},
	description:{
		type: String
	},
	phone:{
		type:String
	},
	color:{
		type:String
	},
    promo:{
        active: {type: Boolean, default:false},
		description: {type: String, default:'No promo'}
    },
    firstPhoto:{
        type:String
	},
	secondPhoto:{
		type:String
	},
	thirdPhoto:{
		type:String
	},
	subsidiary_id: [{
		type:Schema.ObjectId,
        ref:'Subsidiary'
	}],
    created: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model("Carworkshop",CarworkshopSchema);
