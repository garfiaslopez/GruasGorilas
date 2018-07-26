var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var SubsidiarySchema = new Schema({
	carworkshop_id: {
		type: Schema.ObjectId,
        ref: 'Carworkshop'
	},
	country: {
		type: String
	},
	phone: {
		type: String
	},
	address: {
		type: String
	},
	coords: {
		type: [Number],  // [<longitude>, <latitude>]
		index: '2dsphere'      // create the geospatial index
	},
    created: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model("Subsidiary",SubsidiarySchema);
