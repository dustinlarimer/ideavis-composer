var statik = require('statik');
var server = statik.createServer('public');
server.listen(process.env.PORT || 1337);