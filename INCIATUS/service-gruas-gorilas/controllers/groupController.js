//MODELS
var GroupModel = require("../models/group");

module.exports = {

	Create: function(req,res){

		var Group = new GroupModel();

        if (req.body.name) {
            Group.name = req.body.name;
        }
        if (req.body.phone) {
            Group.phone = req.body.phone;
        }
        if (req.body.responsiblePhone) {
            Group.responsiblePhone = req.body.responsiblePhone;
        }
		if (req.body.responsibleName) {
			Group.responsibleName = req.body.responsibleName;
		}
        if (req.body.address) {
            Group.address = req.body.address;
        }
        if (req.body.rfc) {
            Group.rfc = req.body.rfc;
        }
        if (req.body.outCityServices) {
            Group.outCityServices = req.body.outCityServices;
        }

		Group.save(function(err, Group){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , message: "Grupo regitrado exitosamente."});
		});
	},

	All: function(req,res){
		GroupModel.find( function(err, Groups) {
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , groups: Groups});
		});
	},

	ById: function(req,res){
		GroupModel.findById(req.params.group_id, function(err,Group){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , group: Group});
		});
	},

	UpdateById: function(req,res){
		GroupModel.findById(req.params.group_id, function(err, Group){
			//some error
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
            if (req.body.name) {
                Group.name = req.body.name;
            }
            if (req.body.phone) {
                Group.phone = req.body.phone;
            }
            if (req.body.responsiblePhone) {
                Group.phone = req.body.responsiblePhone;
            }
            if (req.body.address) {
                Group.phone = req.body.address;
            }
            if (req.body.rfc) {
                Group.phone = req.body.rfc;
            }
            if (req.body.outCityServices) {
                Group.phone = req.body.outCityServices;
            }
			Group.save(function(err){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Actualizado Satisfactoriamente.."});
			});
		});
	},

	DeleteById: function(req,res){
		GroupModel.remove(
			{
				_id: req.params.group_id
			},
			function(err,Connection){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Borrado Satisfactoriamente.."});
			}
		);
	}
}
