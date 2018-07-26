angular.module('NoticeCtrl',[]).controller('NoticeController',function($scope, $mdDialog, NoticeServ){

    var self = this;
    var CRUD = NoticeServ;
    var ServerKeyObject = "notices";
    self.isLoading = false;
    //initialize 'seccion'
    self.ModelObject = {
        title: '',
        description: '',
    }


    self.isEditing = {
        flag: false,
        id: null
    };

    function ClearTextFields(){
        self.ModelObject.title = null;
        self.ModelObject.description = null;

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
        self.isLoading = true;

        self.ModelObjectDB = [];
        CRUD.All().success(function(data){
            self.ModelObjectDB = data[ServerKeyObject];
            self.isLoading = false;
            console.log(self.ModelObjectDB);
        });
    }

    ReloadData();
    self.Submit = function(){
        if (self.ModelObject.title != undefined &&
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

    self.Edit = function(ObjDB){

        ClearTextFields();

        self.ModelObject.title = ObjDB.title;
        self.ModelObject.description = ObjDB.description;

        self.isEditing.flag = true;
        self.isEditing.id = ObjDB._id;
    }

    self.CancelEditing = function(){
        ClearTextFields();
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
});
