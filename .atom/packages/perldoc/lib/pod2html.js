var fs = require('fs');
var spawn = require('child_process').spawn;
var os = require('os');

module.exports = function(perl, binary, cb) {
    if (fs.existsSync(binary)) {
        var out = '';

        var pod2html = spawn(binary, ['--cachedir', os.tmpdir()]);
        pod2html.stdin.setEncoding = 'utf-8';
        pod2html.stdout.setEncoding = 'utf-8';

        pod2html.stderr.on('data', function(data){ console.warn(data+"") });
        pod2html.stdout.on('data', function(data) { out += data; });
        pod2html.on('exit', function(code) { cb(out); });

        pod2html.stdin.end(perl);
    }
    else {
        console.error("pod2html not found at '" + binary + "'.");
    }
};
