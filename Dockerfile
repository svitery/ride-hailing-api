FROM ruby:3.2.2 as base

RUN mkdir /app

WORKDIR /app

FROM base as dev
    CMD ["sh", "scripts/start.sh"]

FROM base as test
    CMD ["sh", "scripts/test.sh"]
