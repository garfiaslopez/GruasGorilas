var app = angular.module('AdminApp',['RouterCtrl','AuthService','Service','ngMaterial','md.data.table','mdColorPicker']);

app.config(function($mdIconProvider, $httpProvider, $mdThemingProvider){

    $mdIconProvider
        .icon("menu", "../public/images/icons/menu.svg"        , 24)
        .icon("user", "../public/images/icons/account4.svg"    , 24)
        .icon("section", "../public/images/icons/bed24.svg"    , 24)
        .icon("commercial", "../public/images/icons/google128.svg"    , 24)
        .icon("pack", "../public/images/icons/work3.svg"    , 24)
        .icon("commercializer", "../public/images/icons/emoticon117.svg"    , 24)
        .icon("cars", "../public/images/icons/front16.svg"    , 24)
        .icon("receipt", "../public/images/icons/receipt.svg"    , 24)
        .icon("dasboard", "../public/images/Dasboard.svg"    , 24)
        .icon("billing", "../public/images/Facturacion.svg"    , 24)
        .icon("spends", "../public/images/Gastos.svg"    , 24)
        .icon("historial", "../public/images/Historial.svg"    , 24)
        .icon("ingresses", "../public/images/Ingresos.svg"    , 24)
        .icon("services", "../public/images/icons/circles23.svg"    , 24)
        .icon("paybills", "../public/images/Vales.svg"    , 24)
        .icon("ticket", "../public/images/Ticket.svg"    , 24)
        .icon("Ticket", "../public/images/Ticket.svg"    , 400)
        .icon("carwashes", "../public/images/icons/front17.svg"    , 24)
        .icon("products", "../public/images/Ticket.svg"    , 24)
        .icon("delete", "../public/images/icons/cancel19.svg"    , 24)
        .icon("userlogin", "../public/images/icons/account4.svg"    , 120)
        .icon("logout", "../public/images/icons/thermostat1.svg"    , 120)
        .icon("configurations", "../public/images/icons/settings49.svg"    , 120)
        .icon("usercircle", "../public/images/icons/round58.svg"    , 120)
        .icon("view", "../public/images/icons/view12.svg"    , 120)
        .icon("lock", "../public/images/icons/locked57.svg"    , 120);



    $httpProvider.interceptors.push('AuthInterceptor');

    $mdThemingProvider.theme('default')
        .primaryPalette('blue')
        .accentPalette('red');


});


app.directive('ngFileModel', ['$parse', function ($parse) {
    return {
        restrict: 'A',
        link: function (scope, element, attrs) {
            var model = $parse(attrs.ngFileModel);
            var isMultiple = attrs.multiple;
            var modelSetter = model.assign;
            element.bind('change', function () {
                var values = [];
                angular.forEach(element[0].files, function (item) {
                    // var value = {
                    //    // File Name
                    //     name: item.name,
                    //     //File Size
                    //     size: item.size,
                    //     //File URL to view
                    //     url: URL.createObjectURL(item),
                    //     // File Input Value
                    //     _file: item
                    // };
                    console.log(item);
                    values.push(item);
                });
                scope.$apply(function () {
                    if (isMultiple) {
                        modelSetter(scope, values);
                    } else {
                        modelSetter(scope, values[0]);
                    }
                });
            });
        }
    };
}]);


app.directive('fileModel', ['$parse', function ($parse) {
    return {
        restrict: 'A',
        link: function(scope, element, attrs) {
            console.log(element);
            console.log(attrs.id);
            var model = $parse(attrs.fileModel);
            var modelSetter = model.assign;
            console.log(attrs.fileModel);
            element.bind('change', function(){
                scope.$apply(function(){
                    modelSetter(scope, element[0].files[0]);
                    scope.setLogo(element[0].files[0], attrs.id);
                });
            });
        }
    };
}]);



app.controller('MainController',function($rootScope,$mdDialog,$location,$scope,$mdSidenav,Auth,MainVars,HistoryServ){

    $scope.Profile = {
        name: "Usuario",
        rol: "Nivel",
    };

    if(Auth.isLoggedIn()){
        console.log("islogged");
        $location.path("/Dashboard");
        $scope.Tittle = "Dashboard";
    }else{
        window.location = '/Login';
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

    MenuList = [
        {
            name:"Dashboard",
            icon:"section",
            route:"/Dashboard",
            selected: true

        },
        {
            name:"Administradores",
            icon:"user",
            route:"/UserAdmin",
            selected: false

        },
        {
            name:"Usuario",
            icon:"user",
            route:"/User",
            selected: false

        },
        {
            name:"Franquicia",
            icon:"user",
            route:"/Groups",
            selected: false

        },
        {
            name:"Gruas",
            icon:"user",
            route:"/Tows",
            selected: false

        },
        {
            name:"Operador",
            icon:"user",
            route:"/Vendor",
            selected: false

        },
        {
            name:"Socios Comerciales",
            icon:"services",
            route:"/Carworkshop",
            selected: false

        },
        {
            name:"Tarifas",
            icon:"services",
            route:"/RouteExample",
            selected: false

        },
        {
            name:"Cupones y Promociones",
            icon:"services",
            route:"/Coupon",
            selected: false

        },
        {
            name:"Mensajes a operador",
            icon:"services",
            route:"/Notice",
            selected: false

        },
        {
            name:"Historial",
            icon:"historial",
            route:"/History",
            selected: false
        },
        {
            name:"Soporte y Comentarios",
            icon:"historial",
            route:"/Help",
            selected: false
        }

    ];

    Auth.GetUser().success(function(data) {
        $scope.Profile = {
            name: data.user.info.name,
            id: data.user._id,
            rol: data.user.rol,
        };
        MainVars.SetUser($scope.Profile);
        $scope.Menu = MenuList;
    });
    $scope.Menu = MenuList;

    $scope.ShowMenu = function() {
        $mdSidenav('left').toggle();
    }

    $scope.CloseMenu = function() {
        $mdSidenav('left').close();
    }

    $scope.LogOut = function(){
        Auth.LogOut();
        window.location = '/Home';
    }

    $scope.RestartServer = function() {
        var restart = confirm("¿Realmente deseas reiniciar el servidor?");
        if (restart == true) {
            HistoryServ.RestartServer().success(function(data){
                Alerta("Servidor reiniciado.");
            }).error(function(data){
                Alerta('Error',data.message);
            });
        }
    }

    $scope.navigateTo = function(item){

        angular.forEach($scope.Menu, function(value, key) {
          value.selected = false;
        });
        item.selected = true;
        $scope.Tittle = item.name;
    	$location.path(item.route);
        $scope.CloseMenu();

    }
});
