//MODELS
var Config = require("../config/config");


var UserModel = require("../models/user");
var GroupModel = require("../models/group");
var api_key = Config.mailgunKey;
var domain = Config.mailgunUrl;
var mailgun = require('mailgun-js')({apiKey: api_key, domain: domain});

module.exports = {

	Create: function(req,res){
		var User = new UserModel();
		if(req.body.email && req.body.password && req.body.phone){
			User.email.address = req.body.email.toLowerCase();
			User.password = req.body.password;
			User.phone = req.body.phone.replace(/\s+/g, '');;
			if (req.body.group) {
				User.group = req.body.group;
			}
			if (req.body.tow) {
				User.tow = req.body.tow;
			}

		}else{
			return res.json({success: false , message: "Campos necesarios incompletos."});
		}

		//POSIBLE OPTIONALS ON USER
		if(req.body.name){
			User.name = req.body.name;
		}
		if(req.body.typeuser){
			User.typeuser = req.body.typeuser;
		}
		if(req.body.push_id){
			User.push_id = req.body.push_id;
		}

		//POSIBLE OPTIONALS ON VENDOR
		User.loc.cord = [];
		if(req.body.loc){
			User.loc.denomination = req.body.loc.denomination;
			User.loc.cord = [Number(req.body.loc.cord.long),Number(req.body.loc.cord.lat)];
		}
		if(req.body.gender){
			User.gender = req.body.gender;
		}
		if(req.body.birthdate){
			User.birthdate = req.body.birthdate;
		}
		if(req.body.paydata){
			User.paydata = req.body.paydata;
		}
		if(req.body.othercontact){
			User.othercontact = req.body.othercontact;
		}
		if(req.body.paymethod){
			User.paymethod = req.body.paymethod;
		}
		if(req.body.driverLicense) {
			User.driverLicense = req.body.driverLicense;
		}

		// generate random string for verify email.

		var rString = '';
		var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
		for (var i=8; i > 0; --i) rString += chars[Math.floor(Math.random() * chars.length)];
		User.email.token = rString;

		User.save(function(err, SavedUser){

			if(err){
				//entrada duplicada
				if(err.code == 11000){
					return res.json({success: false , message: "Ya Existe Alguien Registrado Con Este Correo o Numero."});
				}else{
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
			}
			if (SavedUser.group) {
				GroupModel.findById(req.body.group, function(err, Group){
					if(err){
						res.json({success:false,error:err});
					}
					if (Group.operators_id === undefined) {
						Group.operators_id = [];
					}
					Group.operators_id.push(SavedUser._id);
					Group.save(function(err){
						if(err){
							res.json({success:false,error:err});
						}
					});
				});
			}

			if(SavedUser.typeuser !== 'operator') {
				var welcomeEmail = 'Muchas gracias por subirte a bordo!, para disfrutar de una mejor experiencia te invitamos a confirmar tu correo electronico. <a href="http://gorilasapp.com.mx:3000/validate/' + User.email.address + '/' + rString + '">Click aqui para confirmar.</a>'
				var data = {
				  from: 'App Gorilas <soporte@inciatus.mx>',
				  to: User.email.address,
				  subject: 'Gracias por tu registro!',
				  html: welcomeEmail
				};
				mailgun.messages().send(data, function (error, body) {
				});
			}
			res.json({success: true , message: "Muchas gracias por tu registro."});
		});
	},

	ValidateEmail: function(req,res){
		UserModel.findOne({'email.address': req.params.email }, function(err,User){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			if(User.email.token === req.params.token) {
				User.email.isVerified = true;
				User.save(function(err, SavedUser){
					if(err) {
						res.json({success: false , message: "Error fallo alguna validacion."});;
					}
					res.json({success: true , message: 'Correo verificado correctamente.'});
				});
			}else{
				res.json({success: false , message: "Codigo de verificacion invalido."});;
			}
		});
	},

	All: function(req,res){
		UserModel.find( function(err, Users) {
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , users: Users});
		});
	},

	AllUsers: function(req,res){
		UserModel.find( {typeuser: 'user'}, function(err,Users){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , users: Users});
		});
	},

	SearchByAvailable: function(req, res) {
		UserModel.find({available: true}, function(err,Users){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , users: Users});
		});
	},

	AllVendors: function(req,res){
		UserModel.find({typeuser:'operator'}).exec(function(err,Vendors){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , operators: Vendors});
		});
	},

	AllAvailableVendors: function(req,res){
		UserModel.find({typeuser:'operator',available:true}).exec(function(err,Vendors){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , operators: Vendors});
		});
	},

	SearchVendorsByLoc: function(req,res){
    	var limit = Config.searchLimit;
	    var maxDistance = Config.searchDistance;
	    if(req.params.lat && req.params.long){
	    	var coords = [Number(req.params.long),Number(req.params.lat)];
			UserModel.find({
				'loc.cord': {
					$near: {
						$geometry: {
							type:'Point',
							coordinates:coords
						},
						$maxDistance:maxDistance
					}
				}
			}).limit(limit).exec(function(err, vendors) {
		      		if (err) {
		        		return res.json({success: false , message: err});
		      		}

		      	res.json({success: true , vendors: vendors});
		    });
	    }else{
			res.json({success: false , message: 'Campos incompletos.'});
		}
	},

	SearchVendorsByStatus: function(req,res) {
		var limit = Config.searchLimit;
		var maxDistance = Config.searchDistance;
		if(req.params.lat && req.params.long) {
			var coords = [Number(req.params.long),Number(req.params.lat)];
			var Status = true;
			UserModel.find({
				'blocked': false,
				'available': Status,
				'loc.cord': {
					$near: {
						$geometry: {
							type:'Point',
							coordinates:coords
						},
						$maxDistance:maxDistance
					}
				}
			}).limit(limit).exec(function(err, vendors) {
				if (err) {
					return res.json({success: false , message: err});
				}
				res.json({success: true , vendors: vendors});
			});
		}else{
			res.json({success: false , message: 'Campos incompletos.'});
		}
	},

	ById: function(req,res){
		UserModel.findById(req.params.user_id, function(err,User){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , user: User});
		});
	},

	ByGroup: function(req,res){
		UserModel.find({ group: req.params.group_id }, function(err,Users){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , users: Users});
		});
	},

	AvailableOperator: function(req,res){
		if (req.body.operator_id) {
			UserModel.findById(req.body.operator_id).exec(function(err,User){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				User.available = true;
				User.save(function(err){
					res.json({success: true , message: msg});
				});
			});
		} else {
			res.json({success: false , message: "Error fallo alguna validacion."});;
		}
	},

	BlockUser: function(req,res){

		if (req.body.operator_id) {
			UserModel.findById(req.body.operator_id).exec(function(err,User){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				var msg = "OP";
				if (User.blocked) {
					User.blocked = false;
					msg = "Operador desbloqueado";
				}else{
					User.blocked = true;
					msg = "Operador bloqueado";

				}

				User.save(function(err){
					res.json({success: true , message: msg});
				});
			});
		} else if (req.body.user_id) {
			UserModel.findById(req.body.user_id).exec(function(err,User){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				var msg = "OP";

				if (User.blocked) {
					User.blocked = false;
					msg = "Usuario desbloqueado";

				}else{
					User.blocked = true;
					msg = "Usuario bloqueado";

				}
				User.save(function(err){
					res.json({success: true , message: msg});
				});
			});
		}
	},

	UpdateById: function(req,res){
		UserModel.findById(req.params.user_id).select("password").exec(function(ErrorUser, User){
			if(ErrorUser){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			if(req.body.oldPassword){
				if(req.body.password) {
					var validPass = User.comparePassword(req.body.oldPassword);
					if(!validPass){
						res.json({success: false , message: "Contraseñas no coinciden."});;
					}else{
						User.password = req.body.password;
					}
				}
			}

			if(req.body.email){
				User.email.address = req.body.email.toLowerCase();
			}
			if(req.body.password){
				User.password = req.body.password;
			}
			if(req.body.phone){
				User.phone = req.body.phone.replace(/\s+/g, '');;
			}
			if(req.body.name){
				User.name = req.body.name;
			}
			if(req.body.push_id){
				User.push_id = req.body.push_id;
			}
			if(req.body.typeuser){
				User.typeuser = req.body.typeuser;
			}
			if(req.body.marketname){
				User.marketname = req.body.marketname;
			}
			if(req.body.gender){
				User.gender = req.body.gender;
			}
			if(req.body.birthdate){
				User.birthdate = req.body.birthdate;
			}
			if(req.body.paydata){
				User.paydata = req.body.paydata;
			}
			if(req.body.othercontact){
				User.othercontact = req.body.othercontact;
			}
			if(req.body.paymethod){
				User.paymethod = req.body.paymethod;
			}

			// LOCATION AND AVAILABLE METHODS
			if(req.body.loc){
				User.loc.denomination = req.body.loc.denomination;
				User.loc.cord = [Number(req.body.loc.cord.long),Number(req.body.loc.cord.lat)];
			}

			if(req.body.available !== undefined) {
				User.available = req.body.available;
			}

			//Salvar el usuario actualizado en la DB.
			User.save(function(err){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Actualizado Satisfactoriamente.."});
			});
		});
	},

	ForgotPassword: function(req, res) {
		if(req.body.email){
			UserModel.findOne({'email.address' : req.body.email}).exec(function(ErrorUser, User){
				if(User){
					var rString = '';
					var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
					for (var i=8; i > 0; --i) rString += chars[Math.floor(Math.random() * chars.length)];
					User.password = rString;
					User.save(function(ErrorSave){
						if(ErrorSave){
							res.json({success: false , message: "Error fallo alguna validacion."});;
						}
						var welcomeEmail = 'Te enviamos tu nueva contraseña, con esta podras acceder nuevamente a la aplicación.  CONTRASEÑA: ' + rString + ' , Una vez adentro de la app la podras cambiar en el menu de perfil.'
						var data = {
						  from: 'Gruas Gorilas <soporte@gorilasapp.com.mx>',
						  to: User.email.address,
						  subject: 'Recuperación de contraseña!',
						  html: welcomeEmail
						};
						mailgun.messages().send(data, function (error, body) {
						});
						res.json({success: true , message: "Se ha enviado tu nueva contraseña a tu correo."});
					});
				}else{
					res.json({success: false , message: "Error, usuario no encontrado."});
				}
			});
		}else{
			res.json({success: false , message: "Error, datos incompletos."});;
		}
	},

	RateUserById: function(req,res){
		if(req.body.user_id && req.body.rate){
			UserModel.findById(req.body.user_id).exec(function(ErrorUser, User){
				if(ErrorUser){
					res.json({success: false , message: "Error, usuario no encontrado."});;
				}
				switch (Number(req.body.rate)) {
					case 1:
						User.rate.onestar += 1;
						break;
					case 2:
						User.rate.twostar += 1;
						break;
					case 3:
						User.rate.threestar += 1;
						break;
					case 4:
						User.rate.fourstar += 1;
						break;
					case 5:
						User.rate.fivestar += 1;
						break;
					default:
						res.json({success: false , message: "Rankeo no valido."});;
				}
				User.save(function(ErrorSave){
					if(ErrorSave){
						res.json({success: false , message: "Error fallo alguna validacion."});;
					}
					res.json({success: true , message: "Calificado correctamente."});
				});
			});
		}else{
			res.json({success: false , message: "Campos incompletos."});;
		}
	},

	DeleteById: function(req,res){
		UserModel.remove(
			{
				_id: req.params.user_id
			},
			function(err,User){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Usuario Borrado Satisfactoriamente.."});
			}
		);
	}
}
