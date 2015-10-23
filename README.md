# docker-heroku-example
A simple docker heroku example with CI


## Prerequisites
Install some deps

 * [docker-compose](https://docs.docker.com/compose/install)
 * [heroku toolbelt](https://toolbelt.heroku.com/)

Via the CLI install the `heroku-docker` plugin

    heroku plugins:install heroku-docker


## 
Create a `package.json`

    {
      "dependencies": {
        "express": "^4.13.3",
        "lodash": "*"
      }
    }

...an app.js

    var express = require('express');
    var app = express();

    app.get('/', function (req, res) {
      res.send("hello world!");
    });

    var server = app.listen(process.env.PORT, function () {
      var port = server.address().port;
      console.log('Example app listening at http:/localhost:%s', port);
    });

...and a app.json, here we'll include the postgresql and redis addons

    {
      "name": "Example Name",
      "description": "An example app.json for heroku-docker",
      "image": "heroku/nodejs",
      "addons": [
        "heroku-postgresql",
        "heroku-redis"
      ]
    }

Add some additional bits to your `docker-compose.yml` to get live reload of files

    web: 
      volumes:
       - ./:/app/user/
       - /app/user/node_modules

Then run 

    docker-compose build

Note if the `Dockerfile` has changed then you'll have to rerun the above, to rebuild the image


## Dev mode
This will open the app in a shell on the docker VM

    $ docker-compose run --service-ports web bash
    $ npm install
    $ npm start


## Prod mode
To run in prod mode

    $ docker-compose up



## Todo
Takes the `app.json` and prepends the `env` name infront of the host.

 * Get nodejs app working on heroku-docker
 * Get that app working on CI using docker
 * Get that app deployed to heroku
   * <https://blog.heroku.com/archives/2014/5/22/introducing_the_app_json_application_manifest>

