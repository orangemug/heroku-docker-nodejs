# heroku-docker-nodejs
A simple heroku-docker example for [nodejs](https://nodejs.org) with development, CI and deployment instructions

This README acts as a tutorial and the repo itself contains the final result

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
      "name": "heroku-docker-nodejs",
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
      res.send("Hello from container land!");
    });

    var server = app.listen(process.env.PORT, function () {
      var port = server.address().port;
      console.log('Example app listening at http:/localhost:%s', port);
    });

...an app.json describing your app

    {
      "name": "nodejs-heroku-docker",
      "description": "A simple docker heroku example for nodejs",
      "image": "heroku/nodejs",
      "addons": []
    }

...and a `Procfile` to start our app with[^](https://ddollar.github.io/foreman)

    web: npm install; node app.js

Now lets get the heroku toolbelt to generate us some heroku config

    $ heroku docker:init
    Wrote Dockerfile
    Wrote docker-compose.yml

This will have created 2 files which _docker-compose_ uses to create and run your containers. Now go and add some additional bits to your `docker-compose.yml`, this will allow you to share files between the host and the container during dev.

    web: 
      volumes:
       - ./:/app/user/
       - /app/user/node_modules

Then run 

    $ docker-compose build

Note if the `Dockerfile` has changed then you'll have to rerun the above command, to rebuild the container


## Development
When running the app in development the main requirement is quick restarts of your app. So instead of reloading the VM each time, we'll start a bash shell in the container and run the app manually.

    $ docker-compose run --service-ports web bash

The important part above is `docker-compose run web` which will run a command in our docker container. `--service-ports` tells _docker-compose_ that we want to setup the port mappings. You should now be seeing a bash prompt where you can start your app.

    root@52697b69237b:/code# npm install
    root@52697b69237b:/code# npm start

Open another terminal and run the following to hit the web server from a browser

    $ open "http://$(docker-machine ip default):8080"


## Deployment
To deploy the VM to production first off create an app on heroku

    heroku create [optional name]

Now instead of running `git push heroku` as you'd normally do with heroku, we instead run

    heroku docker:release

As normal you can now open it in your browser

    heroku open


## Testing
Next up lets setup some CI with [circleci](http://circleci.com), first off [create an account](https://circleci.com/signup) if you haven't already got one.

Create a simple test (ok it doesn't actually test anything but you'll get the idea)

    //  ./test/index.js 
    var assert = require("assert");

    describe("docker-heroku-example", function() {
      it("should pass test :)", function() {
        assert(true);
      });
    });

Add the test script and `mocha` dependency to your `package.json`

    {
      "dependencies": {
        "mocha": "^2.3.3"
      },
      "scripts": {
        "test": "mocha test/index.js"
      }
    }

Next up add a `circle.yml` to the base of the repo and _push this to github_

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

Then [add the project](https://circleci.com/add-projects) in circleci and you should very shortly see passing test :)


## Add ons
We can also include postgresql addons in our development setup, which will allow us to run tests in the same environment in development, CI and production.

Lets add the postgres addon, first off add the following to your `docker-compose.yml`

    web:
      environment:
        DATABASE_URL: 'postgres://postgres:@herokuPostgresql:5432/postgres'
      links:
        - herokuPostgresql
    shell:
      environment:
        DATABASE_URL: 'postgres://postgres:@herokuPostgresql:5432/postgres'
      links:
        - herokuPostgresql
    # This defines a new service called herokuPostgresql
    herokuPostgresql:
      image: postgres

`herokuPostgresql` defines a new service which uses the [postgres image from dockerhub](https://hub.docker.com/_/postgres/), this is linked from the web/shell services. When you setup a link the service will be added to `/etc/hosts`

So the host `herokuPostgresql` will be our postgres server running in the other container, cool huh!

Now we'll add `psql` so we can connect to postgres from within our container. To do this append the following to the `Dockerfile`

    RUN apt-get update && apt-get install -y postgresql-client-9.3

Now rebuild the image

    docker-compose build

We can now start a shell and test that we can connect to postgres.

    $ docker-compose run --service-ports web bash
    $ psql $DATABASE_URL

Note: The `DATABASE_URL` was defined in the `docker-compose-yml` above.

You should now be connected to the postgres server! If you want to know more about the postgres container see <https://hub.docker.com/_/postgres/>


## Extras
I've also added a few scripts (just shorthands really) to the [./scripts](./scripts) directory

 * [shell](./scripts/shell) - to run in development
 * [open](./scripts/open) - to open in a browser
 * [rebuild](./scripts/rebuild) - rebuild the container
 * [run](./scripts/run) - to run in a production like way


## References

 * <https://circleci.com/docs/continuous-deployment-with-heroku>
 * <https://devcenter.heroku.com/articles/docker>
 * <https://ddollar.github.io/foreman>
 * <https://hub.docker.com/_/postgres>


## Thanks!
To [samgiles](https://github.com/samgiles) and [oliverbrooks](https://github.com/oliverbrooks) for the pointers


## License
[MIT](LICENSE)
