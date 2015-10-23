FROM heroku/nodejs
RUN apt-get update && apt-get install -y postgresql-client-9.3

