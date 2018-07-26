var app = angular.module('IndexApp',['ngRoute','RouteIndex','ngMaterial']);


app.config(function($mdIconProvider){

    $mdIconProvider
      	.icon("menu", "../public/images/icons/menu.svg"        , 24)
      	.icon("user", "../public/images/icons/account4.svg"    , 24)
      	.icon("home", "../public/images/icons/home149.svg"     , 24)
      	.icon("mail", "../public/images/icons/write20.svg"     , 24)
      	.icon("help", "../public/images/icons/help19.svg"      , 24)
      	;

});


app.controller('IndexController',function($scope,$mdSidenav,$location){



    $location.path("/Home");
    //$scope.Tittle = "Secciones";

    $scope.LoginView = function(){
        window.location = "/Login";
    }

    $scope.ShowMenu = function() {
        $mdSidenav('left').toggle();
    }

    $scope.CloseMenu = function() {
        $mdSidenav('left').close();
    }

    $scope.navigateTo = function(item){

        $scope.Tittle = item.name;
    	$location.path(item.route);
        $scope.CloseMenu();

    }


    $scope.MenuList = [

        {
            name:"Inicio",
            icon:"home",
            route:"/Home",
            selected: true

        },
        {
            name:"Soporte",
            icon:"help",
            route:"/About",
            selected: false

        },
        {
            name:"Contacto",
            icon:"mail",
            route:"/Contact",
            selected: false

        }



    ];

});
