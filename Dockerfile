FROM ruby:3.2.2

RUN mkdir /app

WORKDIR /app

#RUN bundle install

CMD ["sh", "scripts/start.sh"]
