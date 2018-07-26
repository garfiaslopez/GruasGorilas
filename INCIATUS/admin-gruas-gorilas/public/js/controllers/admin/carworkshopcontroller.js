angular.module('CarworkshopCtrl',[]).controller('CarworkshopController',function($scope,$mdDialog,$timeout,CarworkshopServ,SubsidiaryServ){

    var self = this;
    var CRUD = CarworkshopServ;
    var CRUDSUC = SubsidiaryServ;
    var ServerKeyObject = "carworkshops";
    var ServerKeyObjectSuc = "subsidiaries";
    self.isLoading = false;
	//initialize 'seccion'
	self.ModelObject = {
		name: '',
		description: '',
		categorie:'',
        logoPhoto:'',
        color:'',
        firstPhoto:'',
        secondPhoto:'',
        thirdPhoto:'',
        phone:''
	}

    self.Sucursal = {
        carworkshop_id: '',
        country: '',
        address: '',
        phone: '',
        lat: '',
        long: ''
    }

	self.isEditing = {
		flag: false,
		id: null
	};
    self.isEditingSucursal = {
        flag: false,
        id: null
    };

	function ClearTextFields(){

        self.ModelObject.name = null;
        self.ModelObject.description = null;
        self.ModelObject.categorie = null;
        self.ModelObject.logoPhoto = null;
        self.ModelObject.color = null;
        self.ModelObject.firstPhoto = null;
        self.ModelObject.secondPhoto = null;
        self.ModelObject.thirdPhoto = null;
        self.ModelObject.phone = null;

		self.isEditing.flag = false;
		self.isEditing.id = null;
	}

    function ClearTextFieldsSucursal(){
        self.Sucursal.carworkshop_id = null;
        self.Sucursal.country = null;
        self.Sucursal.address = null;
        self.Sucursal.phone = null;
        self.Sucursal.lat = null;
        self.Sucursal.long = null;

        self.isEditingSucursal.flag = false;
        self.isEditingSucursal.id = null;
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

    self.Types = [
        {
            value: 'FRANQUICIA',
            name: 'Franquicia'
        },
        {
            value: 'INDEPENDIENTE',
            name: 'Independiente'
        },
        {
            value: 'BAJIO',
            name: 'Bajio'
        },
        {
            value: 'ALLY',
            name: 'Aliado'
        }

    ];

    self.Categories = [
        {
            value: 'MECANICA GRAL',
            name: 'Mecanica Gral'
        },
        {
            value: 'HOLATERIA Y PINTURA',
            name: 'Hojalateria y pintura'
        },
        {
            value: 'TRANSMISIONES',
            name: 'Transmisiones automaticas'
        },
        {
            value: 'ACEITES Y LUBRICANTES',
            name: 'Aceites y lubricantes'
        },
        {
            value: 'SEGUROS',
            name: 'Seguros'
        },
        {
            value: 'LLANTAS',
            name: 'Llantas'
        },
        {
            value: 'REFACCIONES',
            name: 'Refacciones en gral'
        },
        {
            value: 'CONSTRUCTORES',
            name: 'Constructores'
        },
        {
            value: 'COMBUSTIBLES',
            name: 'Combustibles'
        },
        {
            value: 'GESTORES',
            name: 'Gestores'
        },
        {
            value: 'ASOCIACIONES',
            name: 'Asociaciones'
        },
        {
            value: 'SISTEMAS',
            name: 'Sistemas'
        },
        {
            value: 'HERRAMENTAL ESPECIALIZADO',
            name: 'Herramental especializado'
        },
        {
            value: 'FRENOS',
            name: 'Frenos'
        },
        {
            value: 'OTROS',
            name: 'Otros'
        }
    ];

	function ReloadData(){
        self.isLoading = true;

        self.ModelObjectDB = [];
        self.SubsidiarysDB = [];
		CRUD.All().success(function(data){
			self.ModelObjectDB = data[ServerKeyObject];
            self.isLoading = false;
			console.log(self.ModelObjectDB);
		});
        CRUDSUC.All().success(function(data){
            self.SubsidiarysDB = data[ServerKeyObjectSuc];
            console.log(self.SubsidiarysDB);
        });
	}

	ReloadData();

	self.Submit = function(){
		if (self.ModelObject.name != undefined &&
			self.ModelObject.description != undefined){

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

    self.SubmitSucursal = function(){
        if(self.Sucursal.carworkshop_id != undefined &&
            self.Sucursal.country != undefined &&
            self.Sucursal.address != undefined &&
            self.Sucursal.phone != undefined &&
            self.Sucursal.lat != undefined &&
            self.Sucursal.long != undefined){

            if(self.isEditingSucursal.flag){
                //UPDATE:
                CRUDSUC.Update(self.isEditingSucursal.id,self.Sucursal).success(function(data){
                    if(data.success){
                        Alerta('Actualizado Correctamente.',data.message);

                        ReloadData();
                        ClearTextFieldsSucursal();
                    }else{
                        Alerta('Error',data.message);
                    }
                }).error(function(data){
                    Alerta('Error',data.message);
                });

            }else{

                //SUBMIT NEW:
                CRUDSUC.Create(self.Sucursal).success(function(data){
                    if(data.success){
                        Alerta('Agregado Correctamente.',data.message);
                        ReloadData();
                        ClearTextFieldsSucursal();
                    }else{
                        Alerta('Error',data.message);
                    }
                }).error(function(data){
                    Alerta('Error',data.message);
                });
            }
        }else {
            Alerta('Error','Favor de rellenar todos los campos.');
        }
    }

	self.Edit = function(ObjDB){

		ClearTextFields();

        self.ModelObject.name = ObjDB.name;
        self.ModelObject.description = ObjDB.description;
        self.ModelObject.categorie = ObjDB.categorie;
        self.ModelObject.color = ObjDB.color;
        self.ModelObject.phone = ObjDB.phone;

		self.isEditing.flag = true;
		self.isEditing.id = ObjDB._id;

	}

    self.EditSucursal = function(ObjDB){
        ClearTextFieldsSucursal();

        self.Sucursal.carworkshop_id = ObjDB.carworkshop_id;
        self.Sucursal.country = ObjDB.country;
        self.Sucursal.address = ObjDB.address;
        self.Sucursal.phone = ObjDB.phone;
        self.Sucursal.lat = ObjDB.coords[1];
        self.Sucursal.long = ObjDB.coords[0];

        self.isEditingSucursal.flag = true;
        self.isEditingSucursal.id = ObjDB._id;

    }

	self.CancelEditing = function(){
		ClearTextFields();
	}

	self.CancelEditingSucursal = function(){
		ClearTextFieldsSucursal();
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

    self.DeleteSucursal = function(ObjDB){
        CRUDSUC.Delete(ObjDB._id).success(function(data){
            Alerta('Eliminado Correctamente',data.message);
            ReloadData();
            ClearTextFieldsSucursal();
        }).error(function(data){
            Alerta('Error',data.message);
        });
    }

    self.openFileLogotipo = function() {
        setTimeout(function() {
            document.getElementById('FileLogotipo').click();
        }, 0);
    }

    self.openFileImageOne = function() {
        setTimeout(function() {
            document.getElementById('FileImageOne').click();
        }, 0);
    }

    self.openFileImageTwo = function() {
        setTimeout(function() {
            document.getElementById('FileImageTwo').click();
        }, 0);
    }


    self.openFileImageThree = function() {
        setTimeout(function() {
            document.getElementById('FileImageThree').click();
        }, 0);
    }

    self.showImageLogo = false;
    self.showImageOne = false;
    self.showImageTwo = false;
    self.showImageThree = false;
    $scope.setLogo = function(image, id) {
        console.log("SET LOGO");
        if (image) {
            var reader = new FileReader();
            reader.onload = function (e) {
                console.log(id);
                switch (id) {
                    case 'FileLogotipo':
                        self.showImageLogo = true;
                        self.imageLogo = e.target.result;
                    break;
                    case 'FileImageOne':
                        self.showImageOne = true;
                        self.imageOne = e.target.result;
                    break;
                    case 'FileImageTwo':
                        self.showImageTwo = true;
                        self.imageTwo = e.target.result;
                    break;
                    case 'FileImageThree':
                        self.showImageThree = true;
                        self.imageThree = e.target.result;
                    break;
                    default:
                }
                $scope.$apply();
            }
            reader.readAsDataURL(image);
        }
    }

});
