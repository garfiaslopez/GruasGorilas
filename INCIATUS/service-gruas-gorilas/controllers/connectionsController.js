//MODELS
var ConnectionsModel = require("../models/connections");

module.exports = {

	Create: function(req,res){
		var Connection = new ConnectionsModel();
		Connection.initialDate = new Date();

		if(req.body.operator_id) {
            Connection.operator_id = req.body.operator_id;
		}else{
			return res.json({success: false , message: "Campos necesarios incompletos."});
		}
		Connection.save(function(err, Conn){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , message: "Conexión regitrada exitosamente.", _id: Conn._id});
		});
	},

	All: function(req,res){
		ConnectionsModel.find( function(err, Connections) {
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , connections: Connections});
		});
	},
	AllByOperator: function(req,res){
		ConnectionsModel.find({ operator_id: req.params.operator_id }).exec(function(err, Connections) {
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , connections: Connections});
		});
	},
	ById: function(req,res){
		ConnectionsModel.findById(req.params.connection_id, function(err,Connection){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , connection: Connection});
		});
	},
	CloseConnection: function(req,res){
		ConnectionsModel.findOne({operator_id: req.params.operator_id}).sort({$natural:-1}).limit(1).exec(function(err, Connection){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			if (Connection) {
				Connection.finalDate = new Date();
				Connection.save(function(err){
					if(err){
						console.log(err);
						res.json({success: false , message: "Error fallo alguna validacion."});;
					}
					res.json({success: true , message: "Actualizado Satisfactoriamente.."});
				});
			}
		});
	},

	UpdateById: function(req,res){
		ConnectionsModel.findById(req.params.connection_id, function(err, Connection){
			//some error
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
            if (req.body.operator_id) {
                Connection.operator_id = req.body.operator_id;
            }
            if (req.body.initialDate) {
                Connection.initialDate = req.body.initialDate;
            }
            if (req.body.finalDate) {
                Connection.finalDate = req.body.finalDate;
            }

			Connection.save(function(err){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Actualizado Satisfactoriamente.."});
			});
		});
	},

	DeleteById: function(req,res){
		ConnectionsModel.remove(
			{
				_id: req.params.connection_id
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
