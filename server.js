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