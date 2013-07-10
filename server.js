console.log('Launching server')

var express = require('express')
var app = express()
var port = process.env.PORT || 3333

app.configure(function() {
  app.use(express["static"](__dirname + '/public'));
  return app.use(express.bodyParser());
});

exports.startServer = function() {
  console.log("Now serving port: " + port);
  return app.listen(port);
};

exports.startServer()

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
server.listen(process.env.PORT || 1337);

console.log('Starting server')

var statik = require('statik');
var port = process.env.PORT || 3333;
statik(port);

console.log('Now serving port ' + port)

*/