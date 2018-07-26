//MODELS
var CarModel = require("../models/car");

module.exports = {

	Create: function(req,res){
		var Car = new CarModel();

        Car.user_id = req.body.user_id;
        Car.brand = req.body.brand;
        Car.plates = req.body.plates;
        Car.model = req.body.model;
        Car.color = req.body.color;

		Car.save(function(err){
			if(err){
                res.json({success: false , message: "Algo no salio bien."});
			}
			res.json({success: true , message: "Auto creado correctamente."});
		});
	},

	All: function(req,res){
		CarModel.find().populate('user_id').exec(function(err, Cars) {
			if(err){
                res.json({success: false , message: "Algo no salio bien."});
			}
			res.json({success: true , cars: Cars});
		});
	},

	ById: function(req,res){
		CarModel.findById(req.params.car_id, function(err,Car){
			if(err){
                res.json({success: false , message: "Algo no salio bien."});
			}
			res.json({success: true , car: Car});
		});
	},

    ByUser: function(req,res){
		CarModel.find({ user_id: req.params.user_id }, function(err,Cars){
			if(err){
                res.json({success: false , message: "Algo no salio bien."});
			}
			res.json({success: true , cars: Cars});
		});
	},

	UpdateById: function(req,res){

		CarModel.findById( req.params.car_id, function(err, Car){
			//some error
			if(err){
                res.json({success: false , message: "Algo no salio bien."});
			}
            if(req.body.user_id) {
                Car.user_id = req.body.user_id;
            }
			if(req.body.brand){
				Car.brand = req.body.brand;
			}
            if(req.body.plates){
				Car.plates = req.body.plates;
			}
            if(req.body.model){
				Car.model = req.body.model;
			}
            if(req.body.color){
                Car.color = req.body.color;
            }
			//Salvar el usuario actualizado en la DB.
			Car.save(function(err){
				if(err){
                    res.json({success: false , message: "Algo no salio bien."});
				}
				res.json({success: true , message: "Auto Actualizado Satisfactoriamente."});
			});
		});
	},

	DeleteById: function(req,res){
		CarModel.remove(
			{
				_id: req.params.car_id
			},
			function(err,Car){
				if(err){
                    res.json({success: false , message: "Algo no salio bien."});
				}
				res.json({success: true , message: "Auto Borrado Satisfactoriamente."});
			}
		);
	}


}
