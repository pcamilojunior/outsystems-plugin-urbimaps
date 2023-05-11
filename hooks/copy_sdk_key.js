var fs = require("fs");
var path = require("path");
var utils = require("./utilities");
var defer = require("q").defer();
var constants = {
  sdkKeyFile: "dgissdk.key"
};

module.exports = function(context) {
  
  var platform = context.opts.plugin.platform;
  var platformConfig = utils.getPlatformConfigs(platform);
  if (!platformConfig) {
    utils.handleError("Invalid platform", defer);
  }

  var wwwPath = utils.getResourcesFolderPath(context, platform, platformConfig);
  console.log("wwwPath: " + wwwPath);
  var sourceFilePath = path.join(wwwPath, constants.sdkKeyFile);
  console.log("⭐️ sourceFilePath: " + sourceFilePath);
  var destFilePath = path.join(context.opts.projectRoot, 'platforms/ios/' + constants.sdkKeyFile);
  console.log("⭐️ destFilePath: " + destFilePath);

  if (fs.existsSync(sourceFilePath)) {
    utils.copyFromSourceToDestPath(defer, sourceFilePath, destFilePath);  
    fs.copyFile(sourceFilePath, destFilePath, (err) => {
      if (err) throw err;
      console.log("⭐️ SDK File copied successfuly to: " + destFilePath);
    });
  } else {
    utils.handleError("🚨 No source file (sdk key) found from resources", defer);
  }

  return defer.promise;
}