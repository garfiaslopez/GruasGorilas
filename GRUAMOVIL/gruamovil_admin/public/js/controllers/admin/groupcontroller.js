angular.module('GroupCtrl',[]).controller('GroupController',function($scope,$mdDialog,GroupServ){

	var self = this;

	//initialize 'seccion'
	self.NewGroup = {
        name: '',
    	phone: '',
    	responsibleName: '',
    	responsiblePhone: '',
    	address: '',
        rfc: '',
        outCityServices: ''
	}

	self.isEditing = {
		flag: false,
		id: null
	};

	function ClearTextFields(){

		self.NewGroup.name = null;
        self.NewGroup.phone = null;
        self.NewGroup.responsibleName = null;
        self.NewGroup.responsiblePhone = null;
        self.NewGroup.rfc = null;
        self.NewGroup.outCityServices = null;
        self.NewGroup.address = null;

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
		self.GroupsOnDB = [];
		GroupServ.All().success(function(data){
			self.GroupsOnDB = data.groups;
			console.log(self.GroupsOnDB);
		});
	}

	ReloadData();

	self.Submit = function(){

		if (self.NewGroup.name != undefined &&
			self.NewGroup.phone != undefined ){

			if(self.isEditing.flag){

				GroupServ.Update(self.isEditing.id,self.NewGroup).success(function(data){

					if(data.success){
						Alerta('Grupo Actualizado.',data.message);

						ReloadData();
						ClearTextFields();

					}else{
						Alerta('Error',data.message);
					}

				}).error(function(data){
					Alerta('Error',data.message);
		       	});

			}else{
				GroupServ.Create(self.NewGroup).success(function(data){
					if(data.success){

						Alerta('Grupo Agregado.',data.message);

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

	self.Edit = function(ObjectDB){

		ClearTextFields();

        self.NewGroup.name = ObjectDB.name;
        self.NewGroup.phone = ObjectDB.phone;
        self.NewGroup.responsibleName = ObjectDB.responsibleName;
        self.NewGroup.responsiblePhone = ObjectDB.responsiblePhone;
        self.NewGroup.rfc = ObjectDB.rfc;
        self.NewGroup.outCityServices = ObjectDB.outCityServices;

		self.isEditing.flag = true;
		self.isEditing.id = ObjectDB._id;

	}

	self.CancelEditing = function(){
		ClearTextFields();
	}

	self.Delete = function(ObjectDB){
		GroupServ.Delete(ObjectDB._id).success(function(data){
			Alerta('Grupo Eliminado',data.message);
			ReloadData();
			ClearTextFields();
		}).error(function(data){
			Alerta('Error',data.message);
	    });
	}
});
