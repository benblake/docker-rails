# docker-rails

This is a basic Rails app setup using Docker compose. Basically a template for a new Rails app with MySQL running with Docker. I may also add new generic services or features from time to time.

## To generate a new Rails app.
The setup of this app was created using the following steps.
1. Create a simple ruby Dockerfile with the following contents:
```Dockerfile
FROM ruby:3.1.2

RUN apt-get update -q && apt-get install -qy nodejs yarn

WORKDIR /app/<app_name>

ENTRYPOINT ["tail", "-f", "/dev/null"]
```

2. Build the docker image by running `docker build .`

3. Once built run the container with a volume in the current directory using
```
docker run -v $(pwd):/app/<app_name> <image-id>
```

4. Shell into the container. Note the `container-id` can be found from using `docker ps`.
```
docker exec -it <container-id> bash
```

5. Install Rails in the container using `gem install rails`.

6. Create a new rails app in the current directory using `rails new .`. Note the database type can be specified, ie. for MySQL use `--database=mysql`. You will now have a skeleton of a new Rails project in your current directory since the container was run with a volume mapping.

7. Update the Dockerfile to be appropriate for running a Rails app:
```Dockerfile
FROM ruby:3.1.2

RUN apt-get update -q && apt-get install -qy nodejs yarn

WORKDIR /app/<app_name>

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

CMD ["rails", "server", "-b", "0.0.0.0"]
```

8. Setup a `docker-compose.yml` file to run the Rails app and MySQL as two services:
```yml
version: "3"

services:
  rails:
    build: .
    volumes:
      - ./:/app/<app_name>
    ports:
      - "3000:3000"
    environment:
      - MYSQL_USER=root
      - MYSQL_PASSWORD=password
      - MYSQL_HOST=mysql
    depends_on:
      - "mysql"
    stdin_open: true
    tty: true
  mysql:
    image: "mysql:8"
    volumes:
      - data-volume:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=password

volumes:
  data-volume:
```

9. Update the Rails app's `database.yml` to point to the MySQL instance in development and test environments:
```yml
default: &default
  adapter: mysql2
  encoding: utf8mb4
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: <%= ENV["MYSQL_USER"] %>
  password: <%= ENV["MYSQL_PASSWORD"] %>
  host: <%= ENV["MYSQL_HOST"] %>

development:
  <<: *default
  database: <app-name>_development

test:
  <<: *default
  database: <app-name>_test
```

10. Run the app with `docker-compose up`. Note that you will have to shell into the Rails container and run `bin/rails db:create` to initialize the database.