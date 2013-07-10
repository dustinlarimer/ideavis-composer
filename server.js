/*
var http = require('http')
var port = process.env.PORT || 3333
var server = http.createServer().listen(port, function() {
  console.log('Client app serving ' + port)
});*/

//exports.server = 
/*
var statik = require('statik');
var server = statik.createServer();
server.listen(process.env.PORT || 1337);*/

var statik = require('statik');
var port = process.env.PORT || 3333;
statik(port);