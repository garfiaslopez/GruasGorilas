//JSONWEBTOKEN
var jwt = require("jsonwebtoken");

//Config File
var Config = require("../config/config");
var KeyToken = Config.key;
var UserModel = require("../models/user");

module.exports = {

	AuthToken: function(req,res,next){
		var token = req.headers['authorization'] || req.body.Authorization;
		if(token){
			jwt.verify(token,KeyToken,{ignoreExpiration:true},function(err,decoded){
				if(err){
					res.send(403,JSON.stringify({success:false,message:"Token invalido."}));
				}else{
					if (decoded._id) {
						UserModel.findById(decoded._id).exec(function(err,User) {

							if (User.blocked) {
								res.send(403,JSON.stringify({success:false,message:"Usuario bloqueado."}));
							}else if (User.uuid !== "" && User.uuid !== decoded.uuid) {
								console.log(User.uuid);
								console.log(decoded.uuid);
								console.log("YA CONECTADO");
								res.send(403,JSON.stringify({success:false,message:"Usuario ya conectado."}));
							}else{
								req.decoded = decoded;
								next();
							}
						});
					}else{
						req.decoded = decoded;
						next();
					}
				}
			});
		}else{
			res.send(403,JSON.stringify({success:false,message:"No se encontro token."}));
		}
	}
};
