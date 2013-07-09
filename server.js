var http = require('http')
var port = process.env.PORT || 3000
var server = exports.server = http.createServer(app).listen(port, function() {
  console.log('<+++ Client app serving ' + port + ' +++>')
});

//var statik = require('statik');
//var server = statik.createServer();
//server.listen(process.env.PORT || 1337);