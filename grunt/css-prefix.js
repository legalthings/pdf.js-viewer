var fs = require('fs');
var insertPrefix = require('css-prefix');

var input = fs.readFileSync(process.argv[2], 'utf8');
var output = insertPrefix({ prefix: '', parentClass: process.argv[4] }, input);
fs.writeFileSync(process.argv[3], output, 'utf8');

console.log('Successfully prefixed css');

