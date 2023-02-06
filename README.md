# Теория

Все, что нужно приложению для запуска, включено. Образ Docker содержит код, среду выполнения, системные библиотеки и все остальное, что вы бы установили на сервер, чтобы заставить его работать, если бы вы не использовали Docker.

**Замечание:** 

если применить ```VirtualBox```, то надо отключить ```HyperV``` в настройках операционной системы Windwos 11

```cmd
bcdedit /set hypervisorlaunchtype off
```
если использовать ```Docker Desktop``` в ```Windows 11```

```cmd
bcdedit /set hypervisorlaunchtype auto
```

## Network Linux

просмотр адресов:

```
ifconfig
ip a
```

роутинг

```
route
ip r
```

DNS

```
cat /etc/resolv.conf
```

## Подключение по ssh к WSL Ubuntu

```sudo apt remove openssh-server```

```sudo apt install openssh-server```

```sudo nano /etc/ssh/sshd_config```

Настройка

```PasswordAuthentication   yes```
```ChallengeResponseAuthentication no```
```AllowUsers <your_username>```
```PermitRootLogin yes``` для root


```sudo service ssh restart```

```sudo service ssh status```

```sudo service ssh --full-restart```

Пример подключение

```sudo ssh -i key.pem ubuntu@<remote_host_ip>```

**Замечание:**

- порт ssh, по умрочанию 22, может переопределен для WSL, например, не 22, а 2022: ```ssh -p 2022 iof@localhost```

- проверить, что сервис ssh работает на wsl

- можно ```FileZilla``` проверить по протоколу ```SFTP``` подключиться к удаленному серверу ```Ubuntu```


## Настройка пароля root
```sudo passwd root```




## Подключение к контейнеру ```docker``` по ```ssh```

```
docker run --rm -ti -p 52022:22 ubuntu
apt update && apt install openssh-server && apt install micro && apt install nano
passwd # root password
micro /etc/ssh/sshd_config или nano /etc/ssh/sshd_config
Находим строку PermitRootLogin, раскомментируем и в ней прописываем yes.
/etc/init.d/ssh start
ssh -p 52022 root@127.0.0.1
```



## Подключение по ```ssh``` к ```VirtualBox``` ```Ubuntu```

1. Сеть => NAT. Проброс портов с 22 гостя на любой хоста
2. Сеть =Ю Сетевой мост. ssh iof@192.168.1.1

## Подключение к запущенному контейнеру ```docker```

Существует два способа подключения к запущенному контейнеру через ```SSH```: с помощью ```attach``` и ```exec```. Это две команды, позволяющие выполнять команды в контейнере. Первая не предназначена для запуска нового процесса в контейнере и позволяет запустить только один экземпляр shell.

Если требуется воспользоваться новым терминалом, то здесь нам поможет команда exec. Она полезна, когда нужно выполнить новую команду или создать новый процесс. Attach же соединяет стандартный ввод, вывод или ошибку основного процесса внутри контейнера с соответствующим стандартным вводом, выводом или ошибкой терминала.

Чтобы отсоединиться от контейнера без его остановки, мы можем воспользоваться комбинацией клавиш «CTRL+P» или «CTRL+Q». Для его остановки достаточно зажать «CTRL+C».

Контейнеры предназначены для одноразового использования, поэтому после создания их следует рассматривать как неизменяемые, за исключением постоянных данных, хранящихся в томах.

```docker container attach my_nginx```
```docker exec -i -t «CONTAINER ID» bash```











## Команды docker

- docker ps -a — позволяет посмотреть, какие контейнеры находятся в системе;
- docker ps -l — показывает последние созданные контейнеры;
- docker start «CONTAINER ID» — запуск остановленного контейнера;
- docker stop peaceful_minsky — выключение активного контейнера;
- docker stop «CONTAINER ID» && docker start «CONTAINER ID» — перезагрузка контейнера без его отключения;
- docker-compose up -d --no-deps –build — запуск compose контейнера;
- docker rm «ID OR NAME CONTAINER» — удаление контейнера.






## Получить ip контейнера

```docker inspect -f "{{ .NetworkSettings.IPAddress }}" ssh_image_test```









## Получить ключ ```rsa``` сервера

```ssh-keyscan -t rsa server_ip```


## Пример ```Dockerfile``` для ```Ruby on Rails```

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

Дополнительно:

```cmd
# Default directory
ENV INSTALL_PATH /opt/app
RUN mkdir -p $INSTALL_PATH
```





## Обрах для nginx
```cmd
# Dockerfile.nginx

FROM nginx:latest
COPY reverse-proxy.conf /etc/nginx/conf.d/reverse-proxy.conf
EXPOSE 8020
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
```

Взгляните на то, что делает каждая строка кода:

- **FROM**: указывает Docker использовать указанный родительский образ в качестве отправной точки при создании образа. Поскольку вы создаете приложение Ruby, вы используете официальный образ Ruby, в котором Ruby предустановлен в качестве основы.
- **RUN**: используется для запуска команд оболочки при создании образа Docker. В этом руководстве вы устанавливаете Node.js , потому что от него зависит Rails.
- **WORKDIR**: устанавливает указанный каталог в качестве рабочего каталога внутри образа Docker. Любые дальнейшие команды, запускаемые в Dockerfile, будут выполняться в контексте этого каталога.
- **COPY**: используется для копирования файлов с хост-компьютера в образ Docker. Синтаксис для этого COPY <source> <destination>.. Точка ( .) относится к текущему каталогу.
- **EXPOSE**: сообщает Docker, что приложение будет прослушивать указанный порт при запуске контейнера. Эта команда в основном предназначена для документирования и фактически не открывает порт.
- **CMD**: это основная точка входа в ваш образ Docker. Это команда, которая запускается всякий раз, когда создается контейнер.






## Сборка образа ```docker```

```docker build . -t my-app```
  
По имени Dockerfile:
  
```docker build -t rails-toolbox -f Dockerfile.rails . ```









## Просмотр всех образов

```docker images```








## Запуск образа в контейнере

```docker run -p 3000:3000 rails_conteiner```

```docker run -it -v $PWD:/opt/app rails-toolbox rails new --skip-bundle drkiq```
- -it: присоединяет ваш терминальный процесс к контейнеру.
- -v $PWD:/opt/app: привязывает текущий каталог вашего хост-компьютера к контейнеру, поэтому файлы, созданные внутри, видны на вашем компьютере
- rails new --skip-bundle drkiq: это команда, которую мы передаем образу Rails. Он создает новый проект под названием «drkiq».
  
**Замечание**: Rails new создает новый репозиторий git, но поскольку он у нас уже есть на верхнем уровне проекта, он нам не понадобится, его можно удалить:
```rm -rf drkiq/.git```






## Просмотр запущенных контейнеров
```docker container ls```






## Остановка контейнера
```docker stop id```







## ```Docker-Compose```

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

## Конфиг ```database.yml``` для Postgres

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


## .dockerignore
```cmd
.git
.dockerignore
.env
drkiq/node_modules/
drkiq/vendor/bundle/
drkiq/tmp/  
```




## Развертывание контейнеров Docker

- Хостинг
- Paas
- Kubernetes

## Тома (Volumes)

Docker поддерживает так называемые тома . Это точки монтирования, которые позволяют вам получать доступ к данным либо с собственного хоста, либо из другого контейнера. В нашем случае мы можем смонтировать папку нашего приложения в контейнер и не нужно создавать новый образ для каждого изменения.

Просто укажите локальную папку, а также место ее монтирования в контейнере Docker при вызове docker run , и все готово!
  
```docker run -itP -v $(pwd):/app demo```




## Entrypoint

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

## Locale
  
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
  
## Пример Docker-Compose для Python Flask

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


# PostgreSQL ASP.NET 7

Convert an ASP.NET Core Web Application project to use PostgreSQL with Entity Framework.

This enables development of ASP.NET Core projects using [VS Code](https://code.visualstudio.com/) on macOS or linux targets.

This project uses [.NET 7.0](https://dotnet.microsoft.com/en-us/download/dotnet/7.0) target framework, ASP.NET Core Web Application MVC project scaffold from Visual Studio 2022 (version 17.4).

![vscode](https://user-images.githubusercontent.com/1213591/210010019-e4b11daf-03df-41b6-b44c-368f0cd3cfde.png)

Project setup has already been completed in this repository - assure [environment setup](#environment-setup); then, jump to [running the solution](#running-the-solution).


## Environment Setup

This project requires PostgreSQL - installation instructions are provided below.

If using Visual Studio Code, you will need to generate ASP.NET Core developer certificates by issuing the following commands from a terminal:

    dotnet dev-certs https --clean
    dotnet dev-certs https

For command line `database ef` commands, you will need to install Entity Framework Core tools .NET CLI:

    dotnet tool install --global dotnet-ef


## Project Setup


Below, instructions are referenced to use PostgreSQL in a ASP.NET Core project.


### Install NuGet packages

Install the `Npgsql.EntityFrameworkCore.PostgreSQL` NuGet package in the ASP.NET web application.

To do this, you can use the `dotnet` command line by executing:

    $ dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL --version 3.1.2

Or, edit the project's .csproj file and add the following line in the `PackageReference` item group:

```xml
<PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="3.1.2" />
```


### Update appsettings.json

Configure connection string in project's appsettings.json, replacing the `username`, `password`, and `dbname` appropriately:

```json
"ConnectionStrings": {
    "DefaultConnection": "User ID=username;Password=password;Server=localhost;Port=5432;Database=dbname;Integrated Security=true;Pooling=true;"
},
```


### Modify Program.cs

Inside Program.cs replace the `UseSqlServer` options with `UseNpgsql`:

```cs
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(connectionString));
```
    

## Running the solution

Before the solution can be executed, be sure to run entity framework migrations.


### Migration Issues with DbContext

Initial migrations may fail, due to ASP.NET Core template come with a pre-generation migration for SQL Server.

When trying to run the migration, you might see errors such as:
> Npgsql.PostgresException (0x80004005): 42704: type "nvarchar" does not exist
>
> System.NullReferenceException: Object reference not set to an instance of an object.
>
> System.InvalidOperationException: No mapping to a relational type can be found for property 'Microsoft.AspNetCore.Identity.IdentityUser.TwoFactorEnabled' with the CLR type 'bool'.

Delete the entire Migrations folder, and regenerate new inital migrations.

Generate a new migration using Visual Studio Package Manager Console (from menu: Tools -> NuGet Package Manager -> Package Manager Console):

    PM> Add-Migration

Or, from the command line via DotNet CLI:

    $ dotnet ef migrations add Initial

If dotnet migration tools don't exist, remember to install the tools using the instruction above in the [environment setup](#environment-setup).


### Run Entity Framework Migrations

Execute the migration using either Visual Studio Package Manager Console (from menu: Tools -> NuGet Package Manager -> Package Manager Console):

    PM> Update-Database

Or, from the command line via DotNet CLI, execute the following command inside the project directory, **where the .csproj file is located**:

    $ dotnet ef database update

After running the migration, the database is created and web application is ready to be run.


## Setting up a PostgresSQL server on Mac

Here are instructions to setup a PostgreSQL server on Mac using Homebrew.


### Installing PostgreSQL on Mac

Use [brew](https://brew.sh/) to install PostgreSQL, then launch the service:

    $ brew install postgresql
    $ brew services start postgresql


### Create a user

Create a user using the `createuser` command from a terminal, where `username` is your desired new user name.  Using the `-P` argument, you will be prompted to setup a password.

    $ createuser username -P


### Create a database

Create your database using the `createdb` command from a terminal, where `dbname` is your desired new database name.

    $ createdb dbname
    
At this time, run the solution's Entity Framework migrations (see above for instructions).


### Verifying database

Launch PostgreSQL interactive terminal and connect to the database.

    $ psql dbname


From the PostgreSQL interface terminal, List tables using the `\dt` command:

    dbname=# \dt
                       List of relations
     Schema |         Name          | Type  |    Owner     
    --------+-----------------------+-------+--------------
     public | AspNetRoleClaims      | table | username
     public | AspNetRoles           | table | username
     public | AspNetUserClaims      | table | username
     public | AspNetUserLogins      | table | username
     public | AspNetUserRoles       | table | username
     public | AspNetUserTokens      | table | username
     public | AspNetUsers           | table | username
     public | __EFMigrationsHistory | table | username
    (8 rows)


### Database permissions issues

If permissions were not setup properly during the creation of the database, retroactively fix by granting privileges where `dbname` is your database name and `username` is the user you created:

    $ psql dbname
    dbname=# GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO username;

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



# Теория контейнеризации Docker
## Применение

- Контейнеризация Web приложений
- Построение отказоустойчивых систем
- Kubernetes
- Тестирование Web приложений
- CI/CD



## Установка docker на Ubuntu 22.04

### Хороший мануал. Прочитать
```
https://docs.docker.com/language/dotnet/develop/
```

### Переключение docker между Windows и Linux

Если полетел docker на WSL2 после запуска на Windows

В файле ```~/.docker/config.json``` будет "currentContext": "some-name"строчка. Вы можете удалить эту строку, чтобы вернуться к контексту по умолчанию. Если это последняя строка, обязательно удалите запятую в предыдущей строке, чтобы сохранить json действительным.



## Установка docker-compose в WSL2
```
sudo curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

## Добавление пользователя в sudo группу в Ubuntu

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

# Команды

### Собрать образ
```docker build --tag imagename .```

### Поднять образ
```docker run imagename```

### Собрать композицию образов
```docker-compose build``` 

### Поднять композицию образов c пересборкой
```docker-compose up -d --build```

## ASP Core + Postgres + Adminer
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

## Строка подключения appsettings.json

```
 "PostgreSQL": "Host=db;Port=5432;Database=postgres;Username=postgres;Password=postgres",
```

---

## Dockerfile для WEB API ASP Core

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

## Docker-compose for WEB API ASP Core

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




