Spreader
========

Spreader is an application designed to increase the pace at which Users read.

### Running the App

We've included a Rackup file (static.ru) so that the application can be served with any Rack compatible server.  We like thin.

  `gem install thin`
  
  `thin -R static.ru start`

Then visit localhost:3000.

### Compiling the Coffeescript

`cd` into the project's root directory.

  coffee --watch --compile assets/js/*.coffee
