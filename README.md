# nodejs-heroku-docker
A simple docker heroku example for [nodejs](https://nodejs.org) with development, CI and deployment instructions

This README acts as a tutorial and the repo itself contains the files the tutorial results in

[![circleci](https://circleci.com/gh/teamguideio/docker-heroku-example.png?style=shield)](https://circleci.com/gh/teamguideio/docker-heroku-example)
[![Dependency Status](https://david-dm.org/teamguideio/docker-heroku-example.svg)](https://david-dm.org/teamguideio/docker-heroku-example)
[![Dev Dependency Status](https://david-dm.org/teamguideio/docker-heroku-example/dev-status.svg)](https://david-dm.org/teamguideio/docker-heroku-example#info=devDependencies)


## Prerequisites
Install some deps

 * [docker-compose](https://docs.docker.com/compose/install)
 * [heroku toolbelt](https://toolbelt.heroku.com/)

Via the CLI, install the `heroku-docker` plugin

    heroku plugins:install heroku-docker

We'll also assume you'll have this code in a repo on [github](http://github.com)


## Setup
Create a `package.json`

    {
      "name": "nodejs-heroku-docker",
      "private": true,
      "version": "0.0.0",
      "dependencies": {
        "express": "^4.13.3"
      }
    }

...an `app.js`

    var express = require('express');
    var app = express();

    app.get('/', function (req, res) {
      res.send("hello world!");
    });

    var server = app.listen(process.env.PORT, function () {
      var port = server.address().port;
      console.log('Example app listening at http:/localhost:%s', port);
    });

...and a app.json, here we'll include the postgresql addon

    {
      "name": "nodejs-heroku-docker",
      "description": "A simple docker heroku example for nodejs",
      "image": "heroku/nodejs",
      "addons": [
        "heroku-postgresql"
      ]
    }

Now lets get the heroku toolbelt to generate us some heroku config

    $ heroku docker:init
    Wrote Dockerfile
    Wrote docker-compose.yml

This will have created 2 files now go and add some additional bits to your `docker-compose.yml`, this will allow you to share files between the host and the container during dev.

    web: 
      volumes:
       - ./:/app/user/
       - /app/user/node_modules

Then run 

    $ docker-compose build

Note if the `Dockerfile` has changed then you'll have to rerun the above, to rebuild the container


## Development
When running the app in development the main aim for a quick turn around, so instead of reloading the VM each time we'll start a bash shell in the container and run the app manually.

    $ docker-compose run --service-ports web bash

The important part above is `docker-compose run web` which will run a command in our docker container. `--service-ports` tells docker that we want to setup the port mappings. You should now be seeing a bash terminal prompt where you can start your app.

    root@52697b69237b:/code# npm install
    root@52697b69237b:/code# npm start

Open another terminal and run the following to hit the web server in a browser

    $ open "http://$(docker-machine ip default):8080"


## Deployment
To deploy the VM to production first off create an app on heroku

    heroku create [optional name]

Release the app

    heroku docker:release

And open it in your browser

    heroku open


## Testing
Next up lets setup some CI with [circleci](http://circleci.com), first off [create an account](http://circleci.com) if you haven't already got one.

Create a simple test (ok it doesn't actually test anything but you'll get the idea)

    //  ./test/index.js 
    var assert = require("assert");

    describe("docker-heroku-example", function() {
      it("should pass test :)", function() {
        assert(true);
      });
    });

Add the test script and `mocha` dep to your `package.json`

    {
      "dependencies": {
        "mocha": "^2.3.3"
      },
      "scripts": {
        "test": "mocha test/index.js"
      }
    }

Next up add a `circle.yml` to the base of the repo and push this to github

    machine:
      services:
        - docker

    dependencies:
      pre:
        - sudo pip install --upgrade docker-compose==1.3.0
      override:
        - docker-compose build

    test:
      override:
        - docker-compose run --service-ports web npm test

Then [add the project](https://circleci.com/add-projects) to circleci and you should see a passing test :)



## References

 * <https://circleci.com/docs/continuous-deployment-with-heroku>
 * <https://devcenter.heroku.com/articles/docker>


## License
[MIT](LICENSE)
