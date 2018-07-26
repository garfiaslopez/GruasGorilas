//MODELS
var CarworkshopModel = require("../models/carworkshop");

var fs = require('fs');
var mkdirp = require('mkdirp');
var async = require('async');
var _ = require('lodash');
module.exports = {

	Create: function(req,res){
		var CarWorkshop = new CarworkshopModel();
		var dir = __dirname.substring(0, __dirname.indexOf('\controllers'));
		var maindirectory = 'uploads/photos/' + req.body.name.replace(/\s/g, '');
		var fulldirectory = dir + maindirectory;

		var Tasks = [];

		mkdirp(fulldirectory, function(err) {

			if(err){
				res.json({success: false , message: "Error creando directorio para imagenes."});;
			}else{
				if(req.body){
					Tasks.push(function(callback){
						if(req.body.name){
							CarWorkshop.name = req.body.name;
						}
						if(req.body.categorie){
							CarWorkshop.categorie = req.body.categorie;
						}
						if(req.body.type){
							CarWorkshop.type = req.body.type;
						}
						if(req.body.description){
							CarWorkshop.description = req.body.description;
						}
						if(req.body.phone){
							CarWorkshop.phone = req.body.phone;
						}
						if(req.body.color){
							CarWorkshop.color = req.body.color;
						}
						callback(null,'bodyChanges');
					});
				}
				if (req.files.logoPhoto) {
					Tasks.push(function(callback){
						var filedirectory = fulldirectory + '/' + req.files.logoPhoto.name.replace(/\s/g, '');
						fs.readFile(req.files.logoPhoto.path, function (err, data) {
							if (err) {
								res.json({success: false , message: "Error al subir imagen."});;
							}
							fs.writeFile(filedirectory, data, function (err) {
								if (err) {
									res.json({success: false , message: "Error al subir imagen."});;
								}
								CarWorkshop.logo = req.files.logoPhoto.name.replace(/\s/g, '');
								callback(null, 'logoPhoto');

							});
						});
					});
				}
				if(req.files.firstPhoto) {
					Tasks.push(function(callback){
						var filedirectory = fulldirectory + '/' + req.files.firstPhoto.name.replace(/\s/g, '');
						fs.readFile(req.files.firstPhoto.path, function (err, data) {
							if (err) {
								res.json({success: false , message: "Error al subir imagen."});;
							}
							fs.writeFile(filedirectory, data, function (err) {
							  	if (err) {
									res.json({success: false , message: "Error al subir imagen."});;
								}
								CarWorkshop.firstPhoto = req.files.firstPhoto.name.replace(/\s/g, '');
								callback(null, 'firstPhoto');

							});
						});
					});
				}
				if(req.files.secondPhoto) {
					Tasks.push(function(callback){
						var filedirectory = fulldirectory + '/' + req.files.secondPhoto.name.replace(/\s/g, '');
						fs.readFile(req.files.secondPhoto.path, function (err, data) {
							if (err) {
								res.json({success: false , message: "Error al subir imagen."});;
							}
							fs.writeFile(filedirectory, data, function (err) {
							  	if (err) {
									res.json({success: false , message: "Error al subir imagen."});;
								}
								CarWorkshop.secondPhoto = req.files.secondPhoto.name.replace(/\s/g, '');
								callback(null, 'secondPhoto');
							});
						});
					});
				}
				if(req.files.thirdPhoto) {
					Tasks.push(function(callback){
						var filedirectory = fulldirectory + '/' + req.files.thirdPhoto.name.replace(/\s/g, '');
						fs.readFile(req.files.thirdPhoto.path, function (err, data) {
							if (err) {
								res.json({success: false , message: "Error al subir imagen."});;
							}
							fs.writeFile(filedirectory, data, function (err) {
							  	if (err) {
									res.json({success: false , message: "Error al subir imagen."});;
								}
								CarWorkshop.thirdPhoto = req.files.thirdPhoto.name.replace(/\s/g, '');
								callback(null, 'thirdPhoto');
							});
						});
					});
				}
			}

			if(Tasks.length > 0){
				async.parallel(Tasks,function(err,results){
					//Upload is DONE: Save the Object in mongo with the files name.
					CarWorkshop.save(function(err){
						if(err){
							//entrada duplicada
							if(err.code == 11000){
								return res.json({success: false , message: "Ya Existe Un Taller con ese nombre."});
							}else{
								res.json({success: false , message: "Error fallo alguna validacion."});;
							}
						}
						res.json({success: true , message: "Taller actualizado exitosamente."});
					});
				});
			}else {
				res.json({success: true , message: "Actualizado, pero sin ningun cambio"});;
			}
		});
	},

	All: function(req,res){
		CarworkshopModel.find().populate('subsidiary_id').exec(function(err, Carworkshops) {
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , carworkshops: Carworkshops});
		});
	},

	ById: function(req,res){
		CarworkshopModel.findById(req.params.carworkshop_id).populate('subsidiary_id').exec(function(err,Carworkshop){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , carworkshop: Carworkshop});
		});
	},

	ByType: function(req,res){

		if (req.params.type == "ALL") {
			CarworkshopModel.find({type:{ $ne: "ALLY"}}).populate('subsidiary_id').exec(function(err, Carworkshops) {
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				console.log(req.params);
				console.log(Carworkshops);
				console.log(Carworkshops[0]);
				res.json({success: true , carworkshops: Carworkshops});
			});
		}else{
			CarworkshopModel.find({type: req.params.type}).populate('subsidiary_id').exec(function(err,Carworkshop){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , carworkshops: Carworkshop});
			});

		}

	},

	UpdateById: function(req,res){
		CarworkshopModel.findById(req.params.carworkshop_id, function(err, CarWorkshop){
			//some error
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			var dir = __dirname.substring(0, __dirname.indexOf('\controllers'));
			var maindirectory = 'uploads/photos/' + CarWorkshop.name.replace(/\s/g, '');
			var fulldirectory = dir + maindirectory;
			var Tasks = [];
			mkdirp(fulldirectory, function(err) {
				if(err){
					res.json({success: false , message: "Error creando directorio para imagenes."});;
				}else{
					if(req.body){
						Tasks.push(function(callback){
							if(req.body.name){
								CarWorkshop.name = req.body.name;
							}
							if(req.body.categorie){
								CarWorkshop.categorie = req.body.categorie;
							}
							if(req.body.type){
								CarWorkshop.type = req.body.type;
							}
							if(req.body.description){
								CarWorkshop.description = req.body.description;
							}
							if(req.body.phone){
								CarWorkshop.phone = req.body.phone;
							}
							if(req.body.color){
								CarWorkshop.color = req.body.color;
							}
							if(req.body.promo){
								CarWorkshop.promo.description = req.body.promo.description;
								CarWorkshop.promo.active = req.body.promo.active;
							}
							callback(null,'bodyChanges');
						});
					}

					if(req.files){

						if (req.files.logoPhoto) {
							Tasks.push(function(callback){
								var filedirectory = fulldirectory + '/' + req.files.logoPhoto.name.replace(/\s/g, '');
								if(CarWorkshop.logo){
									fs.unlink(fulldirectory + '/' + CarWorkshop.logo , function(err){
										if(err){
											res.json({success: false , message: "Error al borrar imagen anterior."});
										}
										fs.readFile(req.files.logoPhoto.path, function (err, data) {
											if (err) {
												res.json({success: false , message: "Error al leer stream de imagen."});;
											}
											fs.writeFile(filedirectory, data, function (err) {
												if (err) {
													res.json({success: false , message: "Error al subir imagen."});;
												}
												CarWorkshop.logo = req.files.logoPhoto.name.replace(/\s/g, '');
												callback(null, 'logoPhoto');
											});
										});
									});
								}else{
									fs.readFile(req.files.logoPhoto.path, function (err, data) {
										if (err) {
											res.json({success: false , message: "Error al leer stream de imagen."});;
										}
										fs.writeFile(filedirectory, data, function (err) {
											if (err) {
												res.json({success: false , message: "Error al subir imagen."});;
											}
											CarWorkshop.logo = req.files.logoPhoto.name.replace(/\s/g, '');
											callback(null, 'logoPhoto');
										});
									});
								}
							});
						}

						if(req.files.firstPhoto) {
							Tasks.push(function(callback){
								var filedirectory = fulldirectory + '/' + req.files.firstPhoto.name.replace(/\s/g, '');
								if(CarWorkshop.firstPhoto){
									fs.unlink(fulldirectory + '/' + CarWorkshop.firstPhoto , function(err){
										if(err){
											res.json({success: false , message: "Error al borrar imagen anterior."});
										}
										fs.readFile(req.files.firstPhoto.path, function (err, data) {
											if (err) {
												res.json({success: false , message: "Error al leer stream de imagen."});;
											}
											fs.writeFile(filedirectory, data, function (err) {
												if (err) {
													res.json({success: false , message: "Error al subir imagen."});;
												}
												CarWorkshop.firstPhoto = req.files.firstPhoto.name.replace(/\s/g, '');
												callback(null, 'firstPhoto');

											});
										});
									});
								}else{
									fs.readFile(req.files.firstPhoto.path, function (err, data) {
										if (err) {
											res.json({success: false , message: "Error al leer stream de imagen."});;
										}
										fs.writeFile(filedirectory, data, function (err) {
											if (err) {
												res.json({success: false , message: "Error al subir imagen."});;
											}
											CarWorkshop.firstPhoto = req.files.firstPhoto.name.replace(/\s/g, '');
											callback(null, 'firstPhoto');

										});
									});
								}
							});
						}

						if(req.files.secondPhoto) {
							Tasks.push(function(callback){
								var filedirectory = fulldirectory + '/' + req.files.secondPhoto.name.replace(/\s/g, '');
								if(CarWorkshop.secondPhoto){
									fs.unlink(fulldirectory + '/' + CarWorkshop.secondPhoto , function(err){
										if(err){
											res.json({success: false , message: "Error al borrar imagen anterior."});
										}
										fs.readFile(req.files.secondPhoto.path, function (err, data) {
											if (err) {
												res.json({success: false , message: "Error al subir imagen."});;
											}
											fs.writeFile(filedirectory, data, function (err) {
												if (err) {
													res.json({success: false , message: "Error al subir imagen."});;
												}
												CarWorkshop.secondPhoto = req.files.secondPhoto.name.replace(/\s/g, '');
												callback(null, 'secondPhoto');
											});
										});
									});
								}else{
									fs.readFile(req.files.secondPhoto.path, function (err, data) {
										if (err) {
											res.json({success: false , message: "Error al subir imagen."});;
										}
										fs.writeFile(filedirectory, data, function (err) {
											if (err) {
												res.json({success: false , message: "Error al subir imagen."});;
											}
											CarWorkshop.secondPhoto = req.files.secondPhoto.name.replace(/\s/g, '');
											callback(null, 'secondPhoto');
										});
									});
								}
							});
						}

						if(req.files.thirdPhoto) {
							Tasks.push(function(callback){
								var filedirectory = fulldirectory + '/' + req.files.thirdPhoto.name.replace(/\s/g, '');
								if(CarWorkshop.thirdPhoto){
									fs.unlink(fulldirectory + '/' + CarWorkshop.thirdPhoto , function(err){
										if(err){
											res.json({success: false , message: "Error al borrar imagen anterior."});
										}
										fs.readFile(req.files.thirdPhoto.path, function (err, data) {
											if (err) {
												res.json({success: false , message: "Error al subir imagen."});;
											}
											fs.writeFile(filedirectory, data, function (err) {
												if (err) {
													res.json({success: false , message: "Error al subir imagen."});;
												}
												CarWorkshop.thirdPhoto = req.files.thirdPhoto.name.replace(/\s/g, '');
												callback(null, 'thirdPhoto');
											});
										});
									});
								}else{
									fs.readFile(req.files.thirdPhoto.path, function (err, data) {
										if (err) {
											res.json({success: false , message: "Error al subir imagen."});;
										}
										fs.writeFile(filedirectory, data, function (err) {
											if (err) {
												res.json({success: false , message: "Error al subir imagen."});;
											}
											CarWorkshop.thirdPhoto = req.files.thirdPhoto.name.replace(/\s/g, '');
											callback(null, 'thirdPhoto');
										});
									});
								}
							});
						}
					}
				}



				if(Tasks.length > 0){
					async.parallel(Tasks,function(err,results){
						//Upload is DONE: Save the Object in mongo with the files name.
						CarWorkshop.save(function(err){
							if(err){
								//entrada duplicada
								if(err.code == 11000){
									return res.json({success: false , message: "Ya Existe Un Taller con ese nombre."});
								}else{
									res.json({success: false , message: "Error fallo alguna validacion."});;
								}
							}
							res.json({success: true , message: "Taller actualizado exitosamente."});
						});
					});
				}else {
					res.json({success: true , message: "Actualizado, pero sin ningun cambio"});;
				}
			});
		});
	},

	DeleteById: function(req,res){
		CarworkshopModel.remove(
			{
				_id: req.params.carworkshop_id
			},
			function(err,Carworkshop){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Borrado Satisfactoriamente.."});
			}
		);
	}


}
