# Теория

Все, что нужно приложению для запуска, включено. Образ Docker содержит код, среду выполнения, системные библиотеки и все остальное, что вы бы установили на сервер, чтобы заставить его работать, если бы вы не использовали Docker.

**Замечание:** 

если применить VirtualBox, то надо отключить HyperV
```cmd
bcdedit /set hypervisorlaunchtype off
```
если использовать Docker Desctop в Windows 11
```cmd
bcdedit /set hypervisorlaunchtype auto
```

## Network Linux

адреса:
ifconfig
ip a

роутинг:
route
ip r

DNS:
cat /etc/resolv.conf


## Подключение по ssh к WSL Ubuntu

```sudo apt remove openssh-server```

```sudo apt install openssh-server```

```sudo nano /etc/ssh/sshd_config```

PawordAuthentication   yes

ChallengeResponseAuthentication no

AllowUsers <your_username>

```sudo service ssh restart```

```sudo service ssh status```

```sudo service ssh --full-restart```

```sudo ssh -i key.pem ubuntu@<remote_host_ip>```

порт переопределяем для WSL не 22, а 2022


## Подключение к контейнеру docker по ssh

```
docker run --rm -ti -p 52022:22 ubuntu
apt update && apt install openssh-server && apt install micro && apt install nano
passwd # root password
micro /etc/ssh/sshd_config или nano /etc/ssh/sshd_config
Находим строку PermitRootLogin, раскомментируем и в ней прописываем yes.
/etc/init.d/ssh start
ssh -p 52022 root@127.0.0.1
```


## Подключение по ssh к VirtualBox Ubuntu

1. Сеть => NAT. Проброс портов с 22 гостя на любой хоста
2. Сеть =Ю Сетевой мост. ssh iof@192.168.1.1

## Подключение по ssh
# echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
passwd # изменение пароля root

## Подключчение к запущенному контейнеру

Существует два способа подключения к запущенному контейнеру через SSH: с помощью attach и exec. Это две команды, позволяющие выполнять команды в контейнере. Первая не предназначена для запуска нового процесса в контейнере и позволяет запустить только один экземпляр shell.

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

## Получить ключ rsa сервера
```ssh-keyscan -t rsa server_ip```


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
  
... 
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
...
  
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
