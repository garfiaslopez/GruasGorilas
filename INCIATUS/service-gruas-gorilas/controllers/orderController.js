//MODELS
var OrderModel = require("../models/order");
var UserModel = require("../models/user");
var mongoose = require("mongoose");
var ObjectId = mongoose.Types.ObjectId;

var moment = require("moment");
moment.locale('MX');

var Schema = mongoose.Schema;
module.exports = {

	Create: function(req,res){
		var Order = new OrderModel();
		console.log(req.body);
		if(req.body.user_id && req.body.origin) {
			//default values:
			Order.date = moment(new Date()).utc();
			Order.user_id = req.body.user_id;
			Order.origin = req.body.origin;
			//optional Values that order can have...
			if (req.body.operator_id) {
				Order.operator_id = req.body.operator_id;
			}
			if (req.body.destiny) {
				Order.destiny = req.body.destiny;
			}
			if (req.body.conditions) {
				Order.conditions = req.body.conditions;
			}
			if (req.body.carinfo) {
				Order.carinfo = req.body.carinfo;
			}
			if (req.body.isSchedule) {
				Order.isSchedule = req.body.isSchedule;
			}
			if (req.body.paymethod) {
				Order.paymethod = req.body.paymethod;
			}
			if(req.body.isSchedule){
				Order.isSchedule = req.body.isSchedule;
			}
			if(req.body.dateSchedule) {
				Order.dateSchedule = new Date(req.body.dateSchedule);
			}
			if(req.body.isQuotation) {
				Order.isQuotation = req.body.isQuotation;
			}
			Order.save(function(err){
				if(err){
					console.log(err);

					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Orden registrada correctamente.", order: Order});
			});

		}else{
			return res.json({success: false , message: "Campos necesarios incompletos."});
		}
	},

	All: function(req, res){
		var Paginator = {
			page: 1,
			limit: 10
		};
		OrderModel.paginate({},Paginator, function(err, result) {
			if(err){
				return res.json({success:false,message:'Algo Salio mal.'});
			}
			res.json({success: true , orders: result});
		});
	},
	LastQuotationByUser: function(req, res) {
		var Query = {};
		var Paginator = {
			page: 1,
			limit: 1,
			sort: { order_id: -1 },
			populate: ['user_id','operator_id','tow','group']
		};
		var today = moment();
		var id = new ObjectId(req.params.user_id);
		Query['$or'] = [{ user_id: id}, { operator_id: id}];
		Query['isQuotation'] = true;
		Query['isSchedule'] = false;
		OrderModel.paginate(Query,Paginator, function(err, result) {
			if(err){
				res.json({success:false,message:'Algo Salio mal.'});
			}
			if(result.docs.length > 0) {
				var actualOrder = result.docs[0];
				if(actualOrder.dateSchedule){
					if(moment(actualOrder.dateSchedule) < today){
						console.log("LOWER THAN TODAY");
						res.json({success: true , order: {}});
					}
				}
				res.json({success: true , order: actualOrder});
			}
			res.json({success: true , order: {}});
		});
	},
	SchedulesByUser: function(req, res) {
		var Query = {};
		var Paginator = {
			page: 1,
			limit: 20,
			sort: { dateSchedule: 1 },
			populate: ['user_id','operator_id','tow','group']
		};
		var today = moment();
		var id = new ObjectId(req.params.user_id);
		Query['$or'] = [{ user_id: id}, { operator_id: id}];
		Query['isSchedule'] = true;
		Query['dateSchedule'] = {
			$gte: today.toDate()
		};
		OrderModel.paginate(Query,Paginator, function(err, result) {
			if(err){
				res.json({success:false,message:'Algo Salio mal.'});
			}
			if(result.docs.length > 0){
				res.json({success: true , orders: result});
			}else{
				res.json({success: true , orders: []});
			}
		});
	},

	Filter: function(req, res){
		// DATES ON UTC();
		// defaultProps Paginator.
		var Query = {};
		var Paginator = {
			page: 1,
			limit: 10,
			sort: { order_id: -1 },
			populate: ['user_id','operator_id', 'tow', 'group']
		};
		if (req.body.page){
			Paginator.page = req.body.page;
		}
		if (req.body.limit) {
			Paginator.limit = req.body.limit;
		}
		var initialDate = undefined;
		var finalDate = undefined;

		if (req.body.dateFilter !== undefined) {
			if (req.body.dateFilter == 'TODAY' || req.body.dateFilter == 'today') {
				initialDate = moment(new Date).startOf('day').utc();
				finalDate = moment(new Date).utc();
			} else if (req.body.dateFilter == 'WEEK' || req.body.dateFilter == 'week') {
				initialDate = moment(new Date).startOf('week').isoWeekday(1).utc();
				finalDate = moment(new Date).utc();
			}else if (req.body.dateFilter == 'MONTH' || req.body.dateFilter == 'month') {
				initialDate = moment(new Date).startOf('month').utc();
				finalDate = moment(new Date).utc();
			}else if (req.body.dateFilter == 'YEAR' || req.body.dateFilter == 'year') {
				initialDate = moment(new Date).startOf('year').utc();
				finalDate = moment(new Date).utc();
			}else{
				initialDate = undefined;
				finalDate = undefined;
			}
		}
		if (initialDate !== undefined && finalDate !== undefined) {
			Query['date'] = {
				$gt: initialDate.toDate(),
				$lt: finalDate.toDate()
			};
		}
		var typeUser = "";
		if(req.body.user_id){
			typeUser = "$user_id";
			Query['user_id'] = new ObjectId(req.body.user_id);
		}
		if(req.body.operator_id){
			typeUser = "$operator_id";
			Query['operator_id'] = new ObjectId(req.body.operator_id);
		}
		if (req.body.group) {
			Query['group'] = req.body.group;
		}
		if (req.body.tow) {
			Query['tow'] = req.body.tow;
		}
		if (req.body.status && req.body.status != "ALL") {
			Query['status'] = req.body.status;
		}
		if (req.body.order_id) {
			Query['order_id'] = req.body.order_id;
		}

		Query['isQuotation'] = false;
		Query['isSchedule'] = false;

		if (req.body.allTypes == true) {
			delete Query['isQuotation'];
			delete Query['isSchedule'];
		}

		if (req.body.isTotals) {
			OrderModel.aggregate([
				{$match: Query},
				{$group: {_id: typeUser, count: {$sum: 1}, total: {$sum: "$total"}}
			}], function (err, result){
				if(err){
					return res.json({success:false,message:'Algo Salio mal.'});
				}
				if (result.length > 0) {
					res.json({ success: true , count: result[0].count, total: result[0].total });
				} else{
					res.json({ success: true , count: 0, total: 0 });
				}
			});
		} else {
			OrderModel.paginate(Query,Paginator, function(err, result) {
				if(err){
					res.json({success:false,message:'Algo Salio mal.'});
				}
				res.json({success: true , orders: result});
			});
		}
	},
	LastByUser: function(req,res){
		OrderModel.findOne({user_id:req.params.user_id}, {sort:{$natural:-1}}).exec(function(err,Order){
			if(err){
				return res.json({success:false,message:'Algo Salio mal.'});
			}
			res.json({success: true , order:Order});

		});
	},
	ById: function(req,res){
		OrderModel.findById(req.params.order_id)
		.populate({ path: 'user_id', select: '_id name phone rate typeuser email push_id'})
		.populate({ path: 'operator_id', select: '_id name phone rate typeuser email push_id'})
		.exec(function(err,Order){
			if(err){
				return res.json({success:false,message:'Algo Salio mal.'});
			}
			res.json({success: true , order:Order});
		});
	},
	UpdateById: function(req,res){
		OrderModel.findById(req.params.help_id, function(err, Order){
			//some error
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			if (req.body.user_id) {
				Order.user_id = req.body.user_id;
			}
			if (req.body.origin) {
				Order.origin = req.body.origin;
			}
			if (req.body.destiny) {
				Order.destiny = req.body.destiny;
			}
			if (req.body.conditions) {
				Order.conditions = req.body.conditions;
			}
			if (req.body.carinfo) {
				Order.carinfo = req.body.carinfo;
			}
			if (req.body.isSchedule) {
				Order.isSchedule = req.body.isSchedule;
			}
			if (req.body.paymethod) {
				Order.paymethod = req.body.paymethod;
			}
			if (req.body.operator_id) {
				Order.operator_id = req.body.operator_id;
			}

			Order.save(function(err){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Actualizado Satisfactoriamente.."});
			});
		});
	},

	DeleteById: function(req,res){
		OrderModel.remove(
			{
				_id: req.params.order_id
			},
			function(err,Order){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Borrado Satisfactoriamente.."});
			}
		);
	}


}
