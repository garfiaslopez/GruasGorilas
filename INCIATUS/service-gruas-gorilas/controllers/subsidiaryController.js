//MODELS
var SubsidiaryModel = require("../models/subsidiary");
var CarworkshopModel = require("../models/carworkshop");
var _ = require('lodash');

module.exports = {

	Create: function(req,res){

		var Subsidiary = new SubsidiaryModel();
		Subsidiary.carworkshop_id = req.body.carworkshop_id;

		if(req.body.country){
			Subsidiary.country = req.body.country;
		}
		if(req.body.phone){
			Subsidiary.phone = req.body.phone;
		}
		if(req.body.address){
			Subsidiary.address = req.body.address;
		}
		if(req.body.long && req.body.lat){
			Subsidiary.coords = [req.body.long,req.body.lat];
		}

		CarworkshopModel.findById(req.body.carworkshop_id).exec(function(err,Carworkshop){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			Carworkshop.subsidiary_id.push(Subsidiary);
			Carworkshop.save(function(err){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				Subsidiary.save(function(err){
					if(err){
						res.json({success: false , message: "Error fallo alguna validacion."});;
					}
					res.json({success: true , message: "Sucursal regitrada exitosamente."});
				});
			});
		});
	},

	All: function(req,res){
		SubsidiaryModel.find( function(err, Subsidiaries) {
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , subsidiaries: Subsidiaries});
		});
	},

	ById: function(req,res){
		SubsidiaryModel.findById(req.params.subsidiary_id, function(err,Subsidiary){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , subsidiary: Subsidiary});
		});
	},

	UpdateById: function(req,res){
		SubsidiaryModel.findById(req.params.subsidiary_id, function(err, Subsidiary){
			//some error
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}

			if(req.body.country){
				Subsidiary.country = req.body.country;
			}
			if(req.body.phone){
				Subsidiary.phone = req.body.phone;
			}
			if(req.body.address){
				Subsidiary.address = req.body.address;
			}
			if(req.body.coords){
				Subsidiary.coords = [req.body.long,req.body.lat];
			}

			Subsidiary.save(function(err){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Sucursal regitrada exitosamente."});
			});
		});
	},

	DeleteById: function(req,res){
		SubsidiaryModel.findByIdAndRemove(req.params.subsidiary_id, function(err,Subsidiary){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			CarworkshopModel.findByIdAndUpdate(Subsidiary.carworkshop_id, {$pull: {subsidiary_id: Subsidiary._id}}, function(err, data){
			        if(err) {
						res.json({success: false , message: "Error fallo alguna validacion."});;
			        }
					res.json({success: true , message: "Borrado Satisfactoriamente.."});
			});
			// CarworkshopModel.findById(Subsidiary.carworkshop_id).exec(function(err,Carworkshop){
			// 	if(err){
			// 		res.json({success: false , message: "Error fallo alguna validacion."});;
			// 	}
			// 	console.log(Carworkshop);
			// 	var x = _.findIndex(Carworkshop.subsidiary_id, Subsidiary._id);
			// 	Carworkshop.subsidiary_id.splice(x,1);
			// 	Carworkshop.save(function(err){
			// 		if(err){
			// 			res.json({success: false , message: "Error fallo alguna validacion."});;
			// 		}
			// 		res.json({success: true , message: "Borrado Satisfactoriamente.."});
			// 	});
			// });
		});
	}
}
