//MODELS
var TowModel = require("../models/tow");
var GroupModel = require("../models/group");

module.exports = {

	Create: function(req,res){
		var Tow = new TowModel();
        if (req.body.group) {
            Tow.group = req.body.group;
        }
        if (req.body.economicNumber) {
            Tow.economicNumber = req.body.economicNumber;
        }
        if (req.body.plate) {
            Tow.plate = req.body.plate;
        }
        if (req.body.policyNumber) {
            Tow.policyNumber = req.body.policyNumber;
        }
		if (req.body.serialNumber) {
			Tow.serialNumber = req.body.serialNumber;
		}
		if (req.body.policyCompany) {
			Tow.policyCompany = req.body.policyCompany;
		}
        if (req.body.expirationDate) {
            Tow.expirationDate = req.body.expirationDate;
        }
        if (req.body.aditional) {
            Tow.aditional = req.body.aditional;
        }

		Tow.save(function(err, SavedTow){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , message: "Grua regitrada exitosamente."});

			if (SavedTow.group) {
				GroupModel.findById(req.body.group, function(err, Group){
					if(err){
						console.log(err);
						res.json({success:false,error:err});
					}

					if (Group.tows == undefined) {
						Group.tows = [];
					}
					Group.tows.push(SavedTow._id);

					Group.save(function(err){
						if(err){
							res.json({success:false,error:err});
						}
					});
				});
			}
		});
	},

	All: function(req,res){
		TowModel.find().populate('group').exec(function(err, Tows) {
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , tows: Tows});
		});
	},

	ById: function(req,res){
		TowModel.findById(req.params.tow_id, function(err,Tow){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , tow: Tow});
		});
	},
	ByGroup: function(req,res){
		TowModel.find({group: req.params.group_id}, function(err,Tows){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , tows: Tows});
		});
	},
	UpdateById: function(req,res){
		TowModel.findById(req.params.tow_id, function(err, Tow){
			//some error
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
            if (req.body.group) {
                Tow.group = req.body.group;
            }
            if (req.body.economicNumber) {
                Tow.economicNumber = req.body.economicNumber;
            }
            if (req.body.plate) {
                Tow.plate = req.body.plate;
            }
            if (req.body.policyNumber) {
                Tow.policyNumber = req.body.policyNumber;
            }
            if (req.body.expirationDate) {
                Tow.expirationDate = req.body.expirationDate;
            }
            if (req.body.aditional) {
                Tow.aditional = req.body.aditional;
            }
			Tow.save(function(err){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Actualizado Satisfactoriamente.."});
			});
		});
	},

	DeleteById: function(req,res){
		TowModel.remove(
			{
				_id: req.params.tow_id
			},
			function(err,Tow){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Borrado Satisfactoriamente.."});
			}
		);
	}
}
