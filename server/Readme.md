# vt1 - server

This is a server-side Swift project using Vapor framework.

## Dev

```bash
swift run App
```

### OpenApi Swagger

All the api endpoints are documented with the help of Swagger.

Once the server is running that can be found here:
[http://127.0.0.1:8080](http://127.0.0.1:8080)

### Postman

We have added a simple post man collection, that can be used to test the application.

[See Postman collection](../postman)

### Connect via iPhone

Make sure you iPhone and server are on the same local network.

Then run:

```bash
swift run App serve --hostname 0.0.0.0 --port 8080
```

## Prod

Make sure you have Doker installed.

Navigate to the folder that contains the docker-compose file.

Run:

```bash
docker compose up -build
```

### DB

Connect to PGAdmin

```bash
http://127.0.0.1:8888
```

#### Add the server

Username: <vapor_username@domain-name.com>
PASSWORD: vapor-password

![pgadmin](../img/pgadmin-server.png)

## FAQ

### What do I do if I can't start the sever because the port is already used?

```bash
❯ lsof -i :8080
COMMAND   PID          USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
App     80913 julian.visser   16u  IPv4 0x6a20422a63379f4d      0t0  TCP *:http-alt (LISTEN)

vt1/app
❯ kill 80913
```

### How do I connect to the DB

Connect to docker container

```bash
docker exec -it vt-1-db-1 bash
```

Then connect to the database.

```bash
psql -U vapor_username vapor_database
```
