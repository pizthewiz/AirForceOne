
// set bundle version directly from the git repository state
// for example:
// 	CFBundleVersion: 47
// 	CFBundleShortVersionString: 0.8.3
// 	com.chordedconstructions.fleshworld.ProjectHEADRevision: 6c1eab18bd5c8964cc1ebebe90622216cd62fb86

var util = require('util'),
	fs = require('fs'),
	path = require('path'),
	exec = require('child_process').exec,
	async = require('async'),
	$ = require('NodObjC');
$.import('Foundation');

BUNDLE_VERSION_NUMBER_KEY = 'CFBundleVersion';
BUNDLE_VERSION_STRING_KEY = 'CFBundleShortVersionString';
HEAD_REVISION_KEY = 'com.chordedconstructions.fleshworld.ProjectHEADRevision';

// helpers
function buildNumber(callback) {
  exec("git log --pretty=format:'' | wc -l", function (err, stdout, stderr) {
  	var s = parseInt(stdout.trim(), 10) || 0;
  	callback(err, s);
  });
}
function buildString(callback) {
  exec("git describe --dirty", function (err, stdout, stderr) {
  	if (err && err.code === 128) {
	  	callback(null, null);
	  	return;
  	}
    var s = stdout.trim().match(/^v+(.*)/)[1];
  	callback(err, s);
  });
}
function headRevision(callback) {
  exec("git rev-parse HEAD", function (err, stdout, stderr) {
    var s = stdout.trim();
  	callback(err, s);
  });
}

// building upon and inspired by:
//   http://github.com/guicocoa/xcode-git-cfbundleversion/
//   http://github.com/digdog/xcode-git-cfbundleversion/
//   http://github.com/jsallis/xcode-git-versioner
//   http://github.com/juretta/iphone-project-tools/tree/v1.0.3
desc('update Info.plist bundle version and string from git repo');
task('update', [], function (d, p) {
  var buildDirectory = process.env['BUILT_PRODUCTS_DIR'] || d;
  var infoPlistPath = process.env['INFOPLIST_PATH'] || p; // relative to buildDirectory
  var productPlistPath = path.join(buildDirectory, infoPlistPath);
	if (!fs.existsSync(productPlistPath)) {
		console.log('ERROR - plist not found at path: ' + productPlistPath);
		process.exit(code=1);
	}

	async.series([buildNumber, buildString, headRevision], function (err, results) {
		var number = results.shift().toString();
		var string = results.shift();
		var rev = results.shift();

		var pool = $.NSAutoreleasePool('alloc')('init');
			var info = $.NSMutableDictionary('dictionaryWithContentsOfFile', $(productPlistPath));
			info('setObject', $(number), 'forKey', $(BUNDLE_VERSION_NUMBER_KEY));
			if (string) {
				info('setObject', $(string), 'forKey', $(BUNDLE_VERSION_STRING_KEY));
			}
			info('setObject', $(rev), 'forKey', $(HEAD_REVISION_KEY));

			var error = $.NSError.createPointer();
			var data = $.NSPropertyListSerialization('dataWithPropertyList', info, 'format', $.NSPropertyListXMLFormat_v1_0, 'options', 0, 'error', error.ref());
			if (error.code) {
				console.log('ERROR - failed to serialize plist');
				process.exit(code=1);
			}
			var status = data('writeToFile', $(productPlistPath), 'atomically', true);
			if (!status) {
				console.log('ERROR - failed to write updated plist to disk');
				process.exit(code=1);
			}
		pool('drain');

		console.log("set '" + BUNDLE_VERSION_NUMBER_KEY + "' to " + number);
		if (string) {
			console.log("set '" + BUNDLE_VERSION_STRING_KEY + "' to " + string);
		}
		console.log("set '" + HEAD_REVISION_KEY + "' to " + rev);
	});
});
