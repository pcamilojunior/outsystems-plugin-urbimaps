var fs = require('fs');
var path = require('path');
var child_process = require('child_process');

module.exports = function(context) {

    const projectRoot = context.opts.projectRoot;
    const podfilePath = path.join(projectRoot, 'platforms', 'ios', 'Podfile');

        var target = 'platform :ios';
        
        fs.readFile(podfilePath, {encoding: 'utf-8'}, function(err, data) {

            //Clean Pods
            //var pathiOS = path.join(context.opts.projectRoot,"platforms","ios");

            /*
            var child = child_process.execSync('rm -rf Pods;rm -rf Podfile.lock;pod cache clean --all', {cwd:pathiOS});
            console.log("⭐️ Pod Cleaning: Process finished ⭐️");
            if (typeof child.error !== 'undefined') {
                 console.log("🚨 ERROR cleaning pods");
                console.log("🚨 ERROR cleaning pods: " + child.error);
            } 
            
            
            if(child.error) {
                console.log("🚨 ERROR cleaning pods: ",child.error);
            }*/

            if (err) throw error;

            let dataArray = data.split('\n');

            for (let index=0; index<dataArray.length; index++) {
                console.log("➡️ Linha " + index + ": " +  dataArray[index] );
                if (dataArray[index].includes(target)) {
                    console.log("❤️ FOUND ❤️: " +  dataArray[index] );
                    dataArray[index] = "platform :ios, '12.0'"
                    console.log("❤️ CHANGED TO ❤️: " +  dataArray[index] );
                    //dataArray.splice(index, 1, "\tpod 'PureeOS',  :git => 'https://github.com/andregrillo/puree-ios.git', :branch => '2.0.1.OS6.1'");
                    break; 
                }
            }

            const updatedData = dataArray.join('\n');

            fs.writeFile(podfilePath, updatedData, (err) => {
                if (err) throw err;
                console.log ('⭐️ Podfile Successfully updated ⭐️');
                /*
                //Run "pod install"
                var pathiOS = path.join(context.opts.projectRoot,"platforms","ios");
                var child = child_process.execSync('pod install', {cwd:pathiOS});
                console.log("⭐️ Pod Install: Process finished ⭐️");
                if(child.error) {
                    console.log("🚨 ERROR: ",child.error);
                }
                */
            });

        });
}

