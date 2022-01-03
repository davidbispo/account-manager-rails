FROM ruby:2.7.4

RUN apt-get update && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.0.1
RUN bundle install
COPY . .

RUN chmod +X entrypoint.sh

CMD puma -C config/puma.rb