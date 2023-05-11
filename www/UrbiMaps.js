var exec = require('cordova/exec');

exports.openMap = function (success, error) {
    exec(success, error, 'UrbiMaps', 'openMap');
};
