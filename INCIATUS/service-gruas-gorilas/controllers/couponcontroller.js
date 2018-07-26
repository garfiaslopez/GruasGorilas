//MODELS
var CouponModel = require("../models/coupon");
var UserModel = require("../models/user");

var _ = require("lodash");

module.exports = {

	Create: function(req,res){

		var Cupon = new CouponModel();
		if(req.body.code && req.body.discount){
			Cupon.code = req.body.code;
			Cupon.discount = req.body.discount;
		}else{
			return res.json({success: false , message: "Campos necesarios incompletos."});
		}

		//POSIBLE OPTIONALS ON COUPON
		if(req.body.description){
			Cupon.description = req.body.description;
		}
		if(req.body.expiration){
			Cupon.expiration = req.body.expiration;
		}
		if(req.body.isActive){
			Cupon.isActive = req.body.isActive;
		}

		Cupon.save(function(err){
			if(err){
				//entrada duplicada
				if(err.code == 11000){
					return res.json({success: false , message: "Ya Existe Un Cupon Con Ese Codigo."});
				}else{
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
			}
			res.json({success: true , message: "Cupon regitrado exitosamente."});
		});
	},

	Apply: function(req,res){

		if (req.body.coupon_id && req.body.user_id){

			CouponModel.findById(req.body.coupon_id, function(err, Coupon){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}

				if(Coupon){
					UserModel.findById(req.body.user_id, function(err, User){
						if(err){
							res.send(err);
						}

						var alreadyApply = false;
						_.map(User.coupons, function(cupon){
							if(cupon.coupon_id == Coupon.coupon_id){
								alreadyApply = true;
							}
						});

						if(!alreadyApply){
							User.coupons.push(Coupon.toObject());
							User.save(function(err){
								if(err){
									res.json({success: false , message: "Error fallo alguna validacion."});;
								}
								res.json({success: true , message: "Cupon aplicado correctamente."});
							});
						}else{
							res.json({success: false , message: "Cupon ya aplicado."});
						}
					});
				}else{
					res.json({success: false , message: "Cupon inexistente."});
				}
			});
		}else {
			res.json({success: false , message: "Falta de parametros para operacion."});
		}

	},


	All: function(req,res){
		CouponModel.find( function(err, Coupons) {
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , coupons: Coupons});
		});
	},

	ById: function(req,res){
		CouponModel.findById(req.params.coupon_id, function(err,Coupon){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , coupon: Coupon});
		});
	},


	UpdateById: function(req,res){
		CouponModel.findById(req.params.coupon_id, function(err, Cupon){
			//some error
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}

            if(req.body.code){
    			Cupon.code = req.body.code;
    		}
            if(req.body.discount){
                Cupon.discount = req.body.discount;
            }
    		if(req.body.description){
    			Cupon.description = req.body.description;
    		}
    		if(req.body.expiration){
    			Cupon.expiration = req.body.expiration;
    		}
    		if(req.body.isActive){
    			Cupon.isActive = req.body.isActive;
    		}

			Cupon.save(function(err){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Actualizado Satisfactoriamente.."});
			});
		});
	},

	DeleteById: function(req,res){
		CouponModel.remove(
			{
				_id: req.params.coupon_id
			},
			function(err,Coupon){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Borrado Satisfactoriamente.."});
			}
		);
	}


}
