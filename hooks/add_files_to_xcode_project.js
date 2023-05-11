var fs = require("fs");
var path = require("path");
var utils = require("./utilities");
var defer = require("q").defer();
var xcode = require('xcode');
var constants = {
  sdkKeyFile: "dgissdk.key"
};

function getProjectName() {
    var config = fs.readFileSync('config.xml').toString();
    var parseString = require('xml2js').parseString;
    var name;
    parseString(config, function (err, result) {
        name = result.widget.name.toString();
        const r = /\B\s+|\s+\B/g;  //Removes trailing and leading spaces
        name = name.replace(r, '');
    });
    return name || null;
}

module.exports = function(context) {
  
  var platform = context.opts.plugin.platform;
  var platformConfig = utils.getPlatformConfigs(platform);
  if (!platformConfig) {
    utils.handleError("Invalid platform", defer);
  }

  var wwwPath = utils.getResourcesFolderPath(context, platform, platformConfig);
  console.log("wwwPath: " + wwwPath);
  var sourceFilePath = path.join(wwwPath, constants.sdkKeyFile);
  var destFilePath = path.join(context.opts.projectRoot, 'platforms/ios/' + constants.sdkKeyFile);

  if (fs.existsSync(sourceFilePath)) {
    utils.copyFromSourceToDestPath(defer, sourceFilePath, destFilePath);  
    fs.copyFile(sourceFilePath, destFilePath, (err) => {
      if (err) throw err;
      console.log("⭐️ SDK File copied successfuly to: " + destFilePath);
    });
  } else {
    utils.handleError("🚨 dgissdk.key file not found in resources!", defer);
  }



var projectName = getProjectName();
var pbxProjPath = path.join(context.opts.projectRoot, 'platforms/ios/' + projectName + ".xcodeproj/project.pbxproj");
var projPath = path.join(context.opts.projectRoot, 'platforms/ios/' + projectName);

var project = xcode.project(pbxProjPath);
project.parseSync();

var classesKey = project.findPBXGroupKey({name: 'CustomTemplate'});

//project.addToPbxGroup(constants.sdkKeyFile, classesKey);

project.addSourceFile(constants.sdkKeyFile, null, classesKey);
project.addToPbxBuildFileSection(constants.sdkKeyFile);

/*
var resourceFile = project.addResourceFile(constants.sdkKeyFile);
if (resourceFile){
    project.addToPbxResourcesBuildPhase(resourceFile);
    project.addToPbxBuildFileSection(resourceFile);
    fs.writeFileSync(pbxProjPath, project.writeSync());
    console.log('⭐️ Project written')
}
*/

fs.writeFileSync(pbxProjPath, project.writeSync());
console.log('⭐️ Project written')






  /*const groupName = 'CustomTemplate';
  const [hash] = Object.entries(project.hash.project.objects['PBXGroup']).find(
    ([, group]) => group.name === groupName,
  );
  project.addFile(constants.sdkKeyFile, hash, {});
*/


/*
if (!fs.existsSync(projPath + "groupName")) {
    fs.mkdir(path.join(projPath, "groupName"), err => {
        if (err) console.log(err);
    })
}*/



  return defer.promise;
}
















 