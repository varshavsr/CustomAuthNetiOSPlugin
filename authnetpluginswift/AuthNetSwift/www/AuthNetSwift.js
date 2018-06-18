var exec = require('cordova/exec');

exports.echo = function(arg0, success, error) {
    exec(success, error, "AuthNetSwift", "echo", [arg0]);
};

exports.paymentUI = function (arg0, successCallback, errorCallback) {
    var success = function (result) {
        alert(result);
        successCallback(result);
    };
    var error = function (err) {
        if (errorCallback) {
            errorCallback(err);
        }
    };

    exec(success, error, 'AuthNetSwift', 'paymentUI', ["Success Response"]);
};

exports.coolMethod = function (arg0, success, error) {
    exec(success, error, 'AuthNetSwift', 'coolMethod', [arg0]);
};
