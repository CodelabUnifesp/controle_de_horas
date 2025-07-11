FROM ruby:3.2.2

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update -qq && \
    apt-get install -y nodejs

RUN apt-get install -y build-essential libpq-dev

WORKDIR /app

COPY Gemfile* ./
RUN bundle install

COPY package.json package-lock.json ./
RUN npm install

COPY . .

EXPOSE 3000

ENV RAILS_ENV=development

ENTRYPOINT ["./docker/entrypoint.sh"]
