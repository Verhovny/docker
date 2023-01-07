# Dockerfile.rails
FROM ruby:3.1.0 AS rails_container
RUN apt-get update && apt-get install -y nodejs


# Образ через Alpine Linux

#FROM ruby:3.1.0-alpine as rails_container_alpine

#RUN apk add \
 #   build-base \
 #   postgresql-dev \
 #   tzdata \
 #   nodejs

WORKDIR /app
COPY Gemfile* .
RUN bundle install
COPY . .
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]

# Многоэтапная сборка

#FROM ruby:3.1.0-alpine as builder

#RUN apk add \
 #   build-base \
 #   postgresql-dev 

#COPY Gemfile* .
#RUN bundle install

#FROM ruby:3.1.0-alpine as runner

#RUN apk add \
    #tzdata \
    #nodejs \
    #postgresql-dev 

#WORKDIR /app
# Мы копируем весь каталог gems для нашего образа билдера, содержащего уже собранный артефакт
#COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
#COPY . .
#EXPOSE 3000
#CMD ["rails", "server", "-b", "0.0.0.0"]