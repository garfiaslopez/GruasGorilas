//MODELS
var UserModel = require("../models/user");
var UserAdminModel = require("../models/useradmin");
var ConnectionsModel = require("../models/connections");
var OrderModel = require("../models/order");

//JSONWEBTOKEN
var jwt = require("jsonwebtoken");

//Config File
var Config = require("../config/config");
var KeyToken = Config.key;

module.exports = {
	AuthByUser: function(req,res){
		console.log("AUTH");
		console.log(req.body);
		if(req.body.email && req.body.password){
			UserModel.findOne({'email.address': req.body.email.toLowerCase()}).exec(function(err, Usuario){
					if(err){
						res.json({success: false , message: "Error fallo alguna validacion."});;
					}
					if(!Usuario){
						res.json({success:false,message:"Error al ingresar, Usuario no encontrado."});
					}else{
						var validPass = Usuario.comparePassword(req.body.password);
						if(!validPass){
							res.json({success:false,message:"Error al ingresar, Contraseña incorrecta."});
						}else{
							var token = jwt.sign(
								{
									_id: Usuario._id,
									email: Usuario.email.address,
									uuid: req.body.uuid
								},
								KeyToken,
								{
									expiresIn: 2880
								}
							);
							if (Usuario.blocked == false) {
								Usuario.uuid = req.body.uuid;
								if (Usuario.typeuser == "operator") {
									// first check if have one active order:
									OrderModel.findOne({operator_id: Usuario._id}).sort({$natural:-1}).limit(1).exec(function(err,Order){
										if(err) {
											res.json({success:false,message:"Error al consultar ultima orden."});
										}
										if (Order) {
											if (Order.status === "Normal" || Order.status == "Canceled" || Order.status == "NotAccepted"){
												Usuario.available = true;
											}else{
												Usuario.available = false;
											}
										}else{
											Usuario.available = true;
										}
										// create new Connection:
										var Connection = new ConnectionsModel();
										Connection.operator_id = Usuario._id;
										Connection.initialDate = new Date();
										Connection.save();
										Usuario.save(function(err){
											res.json({success:true,message:"Bienvenido.",token:token,user:Usuario});
										});
									});
								}else{
									Usuario.available = true;
									Usuario.save(function(ErrorSave){
										if (ErrorSave){
											res.json({success:false,message:"Error al guardar usuario."});
										}
										res.json({success:true,message:"Bienvenido.",token:token,user:Usuario});
									});
								}
							}else{
								// usuario bloqueado:
								res.json({success:false,message:"Permiso denegado."});
							}
						}
					}
				}
			);
		}else{
			res.json({success:false,message:"Please Send Username And Password."});
		}
	},

	AuthByUserAdmin: function(req,res){
		UserAdminModel.findOne({
				username: req.body.username
			}).select("username password").exec( function(err, Usuario){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				if(!Usuario){
					res.json({success:false,message:"Error al ingresar, Usuario no encontrado."});
				}else{
					//check the pass:
					var validPass = Usuario.comparePassword(req.body.password);
					if(!validPass){
						res.json({success:false,message:"Error al ingresar, Contraseña incorrecta."});
					}else{
						//Usuario OK pass OK
						var token = jwt.sign(
							{
								username: Usuario.username,
							},
							KeyToken,
							{
								expiresIn: 2880
							}
						);
						res.json({success:true,message:"Bienvenido.",token:token,usuario:Usuario});
					}
				}
			}
		);
	},

	LogOutUser: function(req,res) {
		if (req.body.user_id) {
			UserModel.findById(req.params.user_id).exec(function(err, Usuario){
				Usuario.available = false;
				Usuario.uuid = "";
				Usuario.save(function(ErrorSave){
					if (ErrorSave){
						res.json({success:false,message:"Error al guardar usuario."});
					}
					res.json({success:true,message:"Adios."});
				});
			});
		} else if (req.body.operator_id) {
			UserModel.findById(req.body.operator_id).exec(function(err, Operator){
				Operator.available = false;
				Operator.uuid = "";
				Operator.save(function(ErrorSave){
					// validate actual connections for that operator... close it if have one open.
					ConnectionsModel.findOne({ operator_id: req.params.operator_id })
									.sort({ $natural: -1 })
									.limit(1).exec(function(err, Connection) {
						if(err){
							res.json({success: false , message: "Error fallo alguna validacion."});;
						}
						if (Connection.finalDate == "" || Connection.finalDate == undefined) {
							Connection.finalDate = new Date();
							Connection.save(function(ErrorSave){
								res.json({success:true,message:"Adios."});
							});
						}else{
							res.json({success:true,message:"Adios."});
						}
					});
				});
			});

		}
	},
}
