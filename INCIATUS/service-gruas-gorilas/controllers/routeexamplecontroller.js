//MODELS
var RouteExampleModel = require("../models/routeexample");

module.exports = {

	Create: function(req,res){

		var RouteExample = new RouteExampleModel();
		if(req.body.origin && req.body.destiny && req.body.price){
			RouteExample.origin = req.body.origin;
			RouteExample.destiny = req.body.destiny;
			RouteExample.price = req.body.price;
		}else{
			return res.json({success: false , message: "Campos necesarios incompletos."});
		}

		//POSIBLE OPTIONALS ON COUPON
		if(req.body.location){
			RouteExample.location = req.body.location;
		}
		RouteExample.save(function(err){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , message: "Ejemplo de ruta regitrada exitosamente."});
		});
	},

	All: function(req,res){
		RouteExampleModel.find( function(err, Routes) {
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , routes: Routes});
		});
	},

	ById: function(req,res){
		RouteExampleModel.findById(req.params.route_id, function(err,Route){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , route: Route});
		});
	},

	UpdateById: function(req,res){
		RouteExampleModel.findById(req.params.route_id, function(err, RouteExample){
			//some error
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}

			if(req.body.origin){
				RouteExample.origin = req.body.origin;
			}
			if(req.body.destiny){
				RouteExample.destiny = req.body.destiny;
			}
			if(req.body.price){
				RouteExample.price = req.body.price;
			}

			//POSIBLE OPTIONALS ON COUPON
			if(req.body.location){
				RouteExample.location = req.body.location;
			}

			RouteExample.save(function(err){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Actualizado Satisfactoriamente.."});
			});
		});
	},

	DeleteById: function(req,res){
		RouteExampleModel.remove(
			{
				_id: req.params.route_id
			},
			function(err,Route){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Borrado Satisfactoriamente.."});
			}
		);
	}


}
