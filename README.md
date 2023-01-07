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
Пример запуска через ```docker compose```:

```docker compose run --no-deps web rails new . --force --database=postgresql```

Сначала Compose создает образ webслужбы с помощью файла ```Dockerfile```. Параметр --no-deps говоритне запускать связанные службы. Затем он запускается rails new внутри нового контейнера, используя этот образ



Можно отдельно вызывать команды:


```cmd
docker compose run app rake db:create
```

## Точка входа ```Entrypoint.sh```
ENTRYPOINT ["entrypoint.sh"]

```cmd
#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
```



## Примеры Dockerfile

```cmd
# syntax=docker/dockerfile:1
FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]

```

**Замечание**: Если вы используете Docker в Linux, rails newсозданные файлы принадлежат пользователю root. Это происходит потому, что контейнер работает от имени пользователя root. В этом случае измените владельца новых файлов.

```$ sudo chown -R $USER:$USER .```

**Замечание**: когда у вас есть новый ```Gemfile```, вам нужно снова собрать образ. (Это и изменения в Gemfile файле или Dockerfile должны быть единственными случаями, когда вам потребуется перестроить.)

```docker compose build```

## Конфиг ``database.yml``` для Postgres

```yml

default: &default 
  adapter: postgresql 
  pool: 25 
  timeout: 5000 

  encoding: unicode 
development: 
  <<: *default 
  host: <%= ENV['POSTGRES_HOST'] || 'db' %> 
  username: <%= ENV['POSTGRES_USER']%> 
  password: <%= ENV['POSTGRES_PASSWORD']%> 
  port: <%= ENV['POSTGRES_PORT'] || 5432 %> 
  database: SportStore


```

## Перестройка приложения в контейнере

```docker compose run web bundle install```
```docker compose up --build```





