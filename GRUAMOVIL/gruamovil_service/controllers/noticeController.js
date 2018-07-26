//MODELS
var NoticeModel = require("../models/notice");

module.exports = {

	Create: function(req,res){
		var Notice = new NoticeModel();

		if(req.body.title && req.body.description){
			Notice.title = req.body.title;
			Notice.description = req.body.description;
		}else{
			return res.json({success: false , message: "Campos necesarios incompletos."});
		}
		Notice.save(function(err){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , message: "Aviso regitrado exitosamente."});
		});
	},

	All: function(req,res){
		NoticeModel.find().sort({ $natural: -1 }).exec(function(err, Notices) {
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			if(Notices) {
				res.json({success: true , notices: Notices});
			}else{
				res.json({success: true , notices: []});
			}
		});
	},

	ById: function(req,res){
		NoticeModel.findById(req.params.notice_id, function(err,Notice){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , notice: Notice});
		});
	},

	UpdateById: function(req,res){
		NoticeModel.findById(req.params.notice_id, function(err, Notice){
			//some error
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
            if(req.body.title && req.body.description){
    			Notice.title = req.body.title;
    			Notice.description = req.body.description;
    		}else{
    			return res.json({success: false , message: "Campos necesarios incompletos."});
    		}
			Notice.save(function(err){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Actualizado Satisfactoriamente.."});
			});
		});
	},

	DeleteById: function(req,res){
		NoticeModel.remove(
			{
				_id: req.params.notice_id
			},
			function(err,Notice){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Borrado Satisfactoriamente.."});
			}
		);
	}
}
