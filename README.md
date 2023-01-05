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


