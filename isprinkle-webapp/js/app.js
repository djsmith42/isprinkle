(function() {

var app = angular.module("iSprinkleApp", []);

app.config(function($httpProvider) {
    $httpProvider.defaults.transformResponse = function(data){
        return yaml.load(data);
    }
});

app.controller("HomeController", function($scope, $interval, $http) {
    $scope.currently = 'Loading...';
    refreshStatus();
    $interval(refreshStatus, 1000);

    function refreshStatus() {
        $http.get('/status').success(function(status) {
            $scope.currently = status['current action'];
        });
    }
});

})();
