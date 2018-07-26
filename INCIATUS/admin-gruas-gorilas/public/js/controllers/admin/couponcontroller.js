angular.module('CouponCtrl',[]).controller('CouponController',function($scope,$mdDialog,CouponServ,CarworkshopServ){


        var self = this;
        var CRUD = CouponServ;
        var ServerKeyObject = "coupons";

    	//initialize 'seccion'
    	self.ModelObject = {
    		code: '',
    		discount: '',
    		description:'',
            expiration:'',
            isActive:''
    	}

        self.Promo = {
            active: false,
            description: ''
        }
        self.SelectedCarworkshop = null;

    	self.isEditing = {
    		flag: false,
    		id: null
    	};

    	function ClearTextFields(){

            self.ModelObject.code = null;
            self.ModelObject.discount = null;
            self.ModelObject.description = null;
            self.ModelObject.expiration = null;
            self.ModelObject.isActive = null;

    		self.isEditing.flag = false;
    		self.isEditing.id = null;
    	}

    	function Alerta(title, message){

    		$mdDialog.show( $mdDialog.alert()
    	        .parent(angular.element(document.body))
    	        .title(title)
    	        .content(message)
    	        .ariaLabel('Alert Dialog Demo')
    	        .ok('OK')
    		);

    	}

    	function ReloadData(){
            self.ModelObjectDB = [];
            self.CarworkshopDB = [];
    		CRUD.All().success(function(data){
    			self.ModelObjectDB = data[ServerKeyObject];
    			console.log(self.ModelObjectDB);
    		});
            CarworkshopServ.All().success(function(data){
                self.CarworkshopDB = data['carworkshops'];
                console.log(self.CarworkshopDB);
            });
    	}

    	ReloadData();

    	self.Submit = function(){
    		if (self.ModelObject.code != undefined &&
    			self.ModelObject.discount != undefined){

    			if(self.isEditing.flag){
                    //UPDATE:
    				CRUD.Update(self.isEditing.id,self.ModelObject).success(function(data){
    					if(data.success){
    						Alerta('Actualizado Correctamente.',data.message);

    						ReloadData();
    						ClearTextFields();
    					}else{
    						Alerta('Error',data.message);
    					}
    				}).error(function(data){
    					Alerta('Error',data.message);
    		       	});

    			}else{
                    //SUBMIT NEW:
    				CRUD.Create(self.ModelObject).success(function(data){
    					if(data.success){
    						Alerta('Agregado Correctamente.',data.message);
    						ReloadData();
    						ClearTextFields();
    					}else{
    						Alerta('Error',data.message);
    					}
    				}).error(function(data){
    					Alerta('Error',data.message);
    		       	});
    			}
    		}else{
    			Alerta('Datos Incompletos','Favor de rellenar todos los campos.');
    		}
    	}

        self.SavePromo = function(){

            if(self.SelectedCarworkshop){
                if(self.Promo.description){
                    CarworkshopServ.UpdatePromo(self.SelectedCarworkshop._id,self.Promo).success(function(data){
                        ReloadData();
                        self.CancelEditingPromo();
                        Alerta('Agregado Correctamente.',data.message);
                    });
                }else{
                    Alerta('Datos Incompletos','Favor de agregar una descripcion.');
                }
            }else{
                Alerta('Datos Incompletos','Favor de elegir algun taller.');
            }

        }

        self.SelectCarworkshop = function(ObjDB) {
            angular.forEach(self.CarworkshopDB,function(obj){
                obj.selected = false;
            })
            self.SelectedCarworkshop = ObjDB;
            ObjDB.selected = true;

            if(self.SelectedCarworkshop.promo.description != 'No promo'){
                self.Promo.description = self.SelectedCarworkshop.promo.description;
                self.Promo.active = self.SelectedCarworkshop.promo.active;
            }else{
                self.Promo.description = '';
                self.Promo.active = false;
            }
        }

    	self.Edit = function(ObjDB){

    		ClearTextFields();

            self.ModelObject.code = ObjDB.code;
            self.ModelObject.discount = ObjDB.discount;
            self.ModelObject.description = ObjDB.description;
            self.ModelObject.expiration = moment(ObjDB.expiration).toDate();
            self.ModelObject.isActive = ObjDB.isActive;

    		self.isEditing.flag = true;
    		self.isEditing.id = ObjDB._id;

    	}

    	self.CancelEditing = function(){
    		ClearTextFields();
    	}

        self.CancelEditingPromo = function(){
            angular.forEach(self.CarworkshopDB,function(obj){
                obj.selected = false;
            });
    		self.SelectedCarworkshop = null;
            self.Promo.description = null;
            self.Promo.active = null;
    	}

    	self.Delete = function(ObjDB){
    		CRUD.Delete(ObjDB._id).success(function(data){
    			Alerta('Eliminado Correctamente',data.message);
    			ReloadData();
    			ClearTextFields();
    		}).error(function(data){
    			Alerta('Error',data.message);
    	    });
    	}


        self.DeletePromo = function(){
            var emptypromo = {
                description:'No promo',
                active: false
            }
            CarworkshopServ.UpdatePromo(self.SelectedCarworkshop._id,emptypromo).success(function(data){
                ReloadData();
                self.CancelEditingPromo();
                Alerta('Eliminado Correctamente.',data.message);
            });
        }


});
