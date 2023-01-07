# docker
Команды для работы с докером


# Dockerfile

```cmd

# Dockerfile.rails
FROM ruby:3.1.0 AS rails_container

#
RUN apt-get update && apt-get install -y nodejs

#
WORKDIR /app

#
COPY Gemfile* .

#
RUN bundle install

#
COPY . .

#
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]

```

## Сборка образа ```docker```

```docker build . -t my-app```

## Просмотр всех образов

```docker images```

## Запуск образа в контейнере

```docker run -p 3000:3000 rails_conteiner```


## Просмотр запущенных контейнеров
```docker container ls```

## Остановка контейнера
```docker stop id```

## Docker-Compose

```cmd
services:
  db:
    image: postgres
    environment:
      POSTGRES_PASSWORD: root
  app:
    image: rails_container
    
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: root
      POSTGRES_HOST: db
      DATABASE_URL: postgres://postgres@db
      DATABASE_NAME: SportStore
    ports:
      - 3000:3000
    depends_on:
      - db
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rake db:create && bundle exec rails s -p 3000 -b '0.0.0.0' "
    
```





