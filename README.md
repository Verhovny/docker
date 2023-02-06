# Теория контейнеризации Docker

- Контейнеризация Web приложений
- Построение отказоустойчивых систем
- Kubernetes
- Тестирование Web приложений
- CI/CD

Все, что нужно приложению для запуска, включено. Образ Docker содержит код, среду выполнения, системные библиотеки и все остальное, что вы бы установили на сервер, чтобы заставить его работать, если бы вы не использовали Docker.

# Получить ключ ```rsa``` сервера

```ssh-keyscan -t rsa server_ip```

# Включение виртуализации HyperV
- если применить в ```VirtualBox```, то надо отключить ```HyperV``` в настройках операционной системы Windwos 11
```cmd
bcdedit /set hypervisorlaunchtype off
```
- если использовать ```Docker Desktop``` в ```Windows 11```
```cmd
bcdedit /set hypervisorlaunchtype auto
```

# Команды для работы с сетью Linux
- просмотр адресов:
```
ifconfig
ip a
```
- роутинг
```
route
ip r
```
- DNS
```
cat /etc/resolv.conf
```

# Подключение по ssh к WSL Ubuntu
```sudo apt remove openssh-server```
```sudo apt install openssh-server```
```sudo nano /etc/ssh/sshd_config```

- Настройка конфига sshd_config

```PasswordAuthentication   yes```
```ChallengeResponseAuthentication no```
```AllowUsers <your_username>```
```PermitRootLogin yes``` для root

```sudo service ssh restart```
```sudo service ssh status```
```sudo service ssh --full-restart```

- пример подключение
```sudo ssh -i key.pem ubuntu@<remote_host_ip>```

**Замечание:**
- порт ssh по умрочанию 22
- проверить, что сервис ssh запущен на wsl
- можно ```FileZilla``` проверить по протоколу ```SFTP``` подключиться к удаленному серверу ```Ubuntu```

# Настройка пароля root
```sudo passwd root```

# Подключение к контейнеру ```docker``` по ```ssh```
```
docker run --rm -ti -p 52022:22 ubuntu
apt update && apt install openssh-server && apt install micro && apt install nano
passwd # root password
micro /etc/ssh/sshd_config или nano /etc/ssh/sshd_config
Находим строку PermitRootLogin, раскомментируем и в ней прописываем yes.
/etc/init.d/ssh start
ssh -p 52022 root@127.0.0.1
```
# Подключение по ```ssh``` к ```VirtualBox``` ```Ubuntu```

1. Сеть => NAT. Проброс портов с 22 гостя на любой хоста
2. Сеть =Ю Сетевой мост. ssh iof@192.168.1.1

# Подключение к запущенному контейнеру ```docker```

Существует два способа подключения к запущенному контейнеру через ```SSH```: с помощью ```attach``` и ```exec```. Это две команды, позволяющие выполнять команды в контейнере. Первая не предназначена для запуска нового процесса в контейнере и позволяет запустить только один экземпляр shell.

Если требуется воспользоваться новым терминалом, то здесь нам поможет команда exec. Она полезна, когда нужно выполнить новую команду или создать новый процесс. Attach же соединяет стандартный ввод, вывод или ошибку основного процесса внутри контейнера с соответствующим стандартным вводом, выводом или ошибкой терминала.

Чтобы отсоединиться от контейнера без его остановки, мы можем воспользоваться комбинацией клавиш «CTRL+P» или «CTRL+Q». Для его остановки достаточно зажать «CTRL+C».

Контейнеры предназначены для одноразового использования, поэтому после создания их следует рассматривать как неизменяемые, за исключением постоянных данных, хранящихся в томах.

```docker container attach my_nginx```
```docker exec -i -t «CONTAINER ID» bash```

# Команды docker

- docker ps -a — позволяет посмотреть, какие контейнеры находятся в системе;
- docker ps -l — показывает последние созданные контейнеры;
- docker start «CONTAINER ID» — запуск остановленного контейнера;
- docker stop peaceful_minsky — выключение активного контейнера;
- docker stop «CONTAINER ID» && docker start «CONTAINER ID» — перезагрузка контейнера без его отключения;
- docker-compose up -d --no-deps –build — запуск compose контейнера;
- docker rm «ID OR NAME CONTAINER» — удаление контейнера.
- docker container attach my_nginx
- docker exec -i -t «CONTAINER ID» bash
- docker inspect -f "{{ .NetworkSettings.IPAddress }}" ssh_image_test - получить ip контейнера
- docker build -t rails-toolbox -f Dockerfile.rails .
- docker build . -t my-app

- docker compose run web bundle install```
- docker compose up --build```
- docker compose run app rake db:create

# Команды

# Собрать образ
```docker build --tag imagename .```
# Поднять образ
```docker run imagename```
# Собрать композицию образов
```docker-compose build``` 
# Поднять композицию образов c пересборкой
```docker-compose up -d --build```

# Тома (Volumes)

Docker поддерживает так называемые тома . Это точки монтирования, которые позволяют вам получать доступ к данным либо с собственного хоста, либо из другого контейнера. В нашем случае мы можем смонтировать папку нашего приложения в контейнер и не нужно создавать новый образ для каждого изменения.

Просто укажите локальную папку, а также место ее монтирования в контейнере Docker при вызове docker run , и все готово!
  
```docker run -itP -v $(pwd):/app demo```


# Entrypoint

Поскольку перед большинством команд, которые мы запускаем в контейнере Rails, будет стоять пакет exec , мы можем определить [ ENTRYPOINT ] для всех наших команд. Просто измените Dockerfile следующим образом:

```cmd
# Настройте точку входа, чтобы нам не нужно было 
# указывать "bundle exec" для каждой из наших команд. 
ENTRYPOINT ["bundle", "exec"] 
# Основная команда для запуска при запуске контейнера. Также 
# скажите серверу разработки Rails привязываться ко всем интерфейсам 
# по умолчанию. 
CMD ["рельсы", "сервер", "-b", "0.0.0.0"]
```
Теперь вы можете запускать команды без указания исполняемого пакета на консоли. Если вам нужно, вы также можете переопределить точку входа.  

```cmd
docker run -it demo "rake test" 
docker run -it --entrypoint="" demo "ls -la"
```

# Dockerfile для ```Ruby on Rails```

```cmd
# Dockerfile.rails
FROM ruby:3.1.0 AS rails_container
RUN apt-get update && apt-get install -y nodejs
# Default directory
ENV INSTALL_PATH /opt/app
RUN mkdir -p $INSTALL_PATH
WORKDIR /app
COPY Gemfile* .
RUN bundle install
COPY . .
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
```

# Dockerfile Nginx
```cmd
FROM nginx:latest
COPY reverse-proxy.conf /etc/nginx/conf.d/reverse-proxy.conf
EXPOSE 8020
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
```
 
# Docker-Compose Rails + PostgreSQL

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

# Скрипт ```entrypoint.sh```
ENTRYPOINT ["entrypoint.sh"]

```cmd
#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
```

# Dockerfile Rails

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

# Конфиг Rails database.yml для Postgres

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

# Locale
  
Если вас не устраивает локаль по умолчанию в вашем контейнере Docker, вы можете легко переключиться на другую. Установите необходимый пакет, повторно создайте локали и настройте переменные среды.
  
``` 
# Установите зависимости на основе apt, необходимые для запуска 
# Rails, а также RubyGems. Поскольку сам образ Ruby основан на 
# образе Debian, мы используем apt-get для их установки. 
RUN apt-get update && apt-get install -y \ 
  build-essential \ 
  locales \ 
  nodejs 
# Использовать en_US.UTF-8 в качестве локали 
RUN locale-gen en_US.UTF-8 ЯЗЫК 
ENV en_US.UTF-8 
ЯЗЫК ENV en_US:en 
ENV LC_ALL en_US.UTF -8 
```
  
# Пример Docker-Compose для Python Flask

```cmd
version: '3.9'

services:  
  flask_web:
    container_name: flask_web_container
    build: .
    ports:
      - 5000:5000
    restart: unless-stopped

  postgres:
    env_file: ./docker/.env-postgresql
    container_name: postgres_flask_container
    image: postgres:14
    volumes:
       - flaskdb:/var/lib/postgresql/data
    ports:
      - 5432:5432
    restart: unless-stopped
    networks:
      - backend
  
  pgadmin:
    container_name: pgadmin_container
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_DEFAULT_EMAIL:-qlik@ivan-shamaev.ru}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_DEFAULT_PASSWORD:-A->V9>pS6HJ~xY8d}
      PGADMIN_CONFIG_SERVER_MODE: 'False'
    volumes:
       - pgadmin:/var/lib/pgadmin
    ports:
      - "${PGADMIN_PORT:-5050}:80"
    restart: unless-stopped
    networks:
      - backend

volumes:
    flaskdb:
      driver: local
    pgadmin:
      driver: local

networks:
  backend:
    driver: bridge  
```
---


# Начало работы
```cmd
sudo dotnet new webapi -n webapitest
sudo chmode 777 -R webapitest
sudo chmod 777 -R /tmp
dotnet run
code . -r
```

# Node. Установка или обновление node.js на Ubuntu 22.04
```cmd
curl -sL https://deb.nodesource.com/setup_18.x | sudo bash -
sudo apt remove libnode-dev
sudo apt remove libnode72:amd64
sudo apt install nodejs
node -v
npm -v

powershell: wsl --shutdown
```

# React

```cmd
sudo npx create-react-app my-app
sudo chmod -R 777 my-app/
npm start
```

```docker
FROM node:15.13-alpine 
WORKDIR /app 
COPY . . 
RUN  npm run build 
CMD ["npm","start"]
```
```cmd
docker build --tag client .
docker run -d --rm -p 5000:3000 client
```

```yml
version: '2' 
services: 
  backend: 
    restart: always 
    build: 
      context: . 
      dockerfile: dockerfile 
    environment: 
      - ASPNETCORE_ENVIRONMENT=Development 
    ports: 
      - "5000:80" 
  client: 
    image: client 
    ports: 
      - "5001:3000"
```

# Установка docker на Ubuntu 22.04

# Хороший мануал. Прочитать
```
https://docs.docker.com/language/dotnet/develop/
```

# Переключение docker между Windows и Linux

Если полетел docker на WSL2 после запуска на Windows

В файле ```~/.docker/config.json``` будет "currentContext": "some-name"строчка. Вы можете удалить эту строку, чтобы вернуться к контексту по умолчанию. Если это последняя строка, обязательно удалите запятую в предыдущей строке, чтобы сохранить json действительным.

# Установка docker-compose в WSL2
```
sudo curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

# Добавление пользователя в sudo группу в Ubuntu

```
usermod -aG sudo newuser
groups newuser
su - newuser
```

# Решение проблемы запуска docker в WSL

Установщик докеров использует iptables для nat. К сожалению, Debian использует nftables. Вы можете преобразовать записи в nftables или просто настроить Debian для использования устаревших iptables.

```sudo update-alternatives --set iptables /usr/sbin/iptables-legacy```
```sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy```
```dockerd``` должен нормально запускаться после перехода на ```iptables-legacy```.

# Просмотреть все активность сервисов
```sudo service --status-all```

# Запуск контейнера из образа

```sudo docker run -p 3001:80 aspapiimage54```
**Замечание**: -p 3001:80  => 3001 порт хоста, а 80 порт контейнера

# Dockerfile for ASP Core 7
```cmd
FROM mcr.microsoft.com/dotnet/aspnet:7.0
COPY publish_output .
ENTRYPOINT ["dotnet", "AspApiTest.dll"]c
```
# Dockercompose for ASP Core (ASP + Postgres + Adminer)

```cmd
version: '2'

services:

  testapp:
    image: aspapiimage54
    restart: always
    build:
      context: .
      dockerfile: .Dockerfile
    ports:
       - 3001:80

  db:
    image: postgres:13.0
    restart: always
    ports:
      - 5432:5432
    environment:
      POSTGRES_PASSWORD: root
      POSTGRES_DB: postgres
       
  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080
```

# ASP Core + Postgres + Adminer
```
version: '2'

services:

  asp:
    build:
      context: .
      dockerfile: dockerfile
    ports:
       - 3000:80
    depends_on:
      - db

  db:
      image: postgres:13.0
      restart: always
      ports:
        - 5432:5432
      volumes:
        - postgres-data:/var/lib/postgresql/data

  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080
      
volumes:
  postgres-data:


```
# Строка подключения appsettings.json для Docker

```
 "PostgreSQL": "Host=db;Port=5432;Database=postgres;Username=postgres;Password=postgres",
```

# Dockerfile для WEB API ASP Core
```
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["WebApiTestLinux.csproj", "."]
RUN dotnet restore "WebApiTestLinux.csproj"
COPY . .
RUN dotnet build "WebApiTestLinux.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "WebApiTestLinux.csproj" -c Release -o /app/publish /p:UseAppHost=false
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "WebApiTestLinux.dll"]
```

# Docker-compose for WEB API ASP Core
```yml
version: '3.4'

services:
  webapitestlinux:
    build:
      context: .
      dockerfile: WebApiTestLinux/Dockerfile
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
    ports:
      - "5000:80" 
```
