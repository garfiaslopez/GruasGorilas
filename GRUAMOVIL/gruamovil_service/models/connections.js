var mongoose = require("mongoose");
var moment = require("moment");
var Schema = mongoose.Schema;
var Config = require("../config/config");

var ConnectionSchema = new Schema({
    operator_id: {
        type: Schema.ObjectId,
        ref: 'User'
    },
    initialDate: {
        type: Date
    },
    finalDate: {
        type: Date
    },
    timeInHours: {
        type: Number,
        default: 0
    }
});

function sumTimeToModel(next){
	var Connection = this;
    // get the total time between initial and exit:
    if (Connection.initialDate !== undefined && Connection.finalDate !== undefined) {
        var initial = moment(Connection.initialDate);
        var final = moment(Connection.finalDate);
        var diff = final.diff(initial, 'hours', true);
        console.log(diff);
        Connection.timeInHours = Connection.timeInHours + diff;
    }
	next();
}

ConnectionSchema.pre("save", sumTimeToModel);

//Return the module
module.exports = mongoose.model("Connection",ConnectionSchema);
