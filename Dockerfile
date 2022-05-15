FROM ruby:3.1.2

RUN apt-get update -q && apt-get install -qy nodejs yarn

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

CMD ["rails", "server", "-b", "0.0.0.0"]
