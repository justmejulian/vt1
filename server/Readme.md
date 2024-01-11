# vt1 - server

This is a server-side Swift project using Vapor framework.

## Dev

### Prerequisites

XCode (Version 15+)

iPhone (iOS 17+)

Apple Watch (10+)

### Pre Dev

Before developing you need to set your Team and custom bundle Identifier.

To do so, navigate to Signing & Capabilities in the project settings.
Remember to set the same settings for both the watch and the iPhone projects.

Then you need to set the watchkit companion app bundle identifier in the watch Info.plist.
Use the same as the bundle Identifier.

### Run app in xCode

Add the following to arguments passed on launch. (see [How to add arguments passed at Launch](https://sarunw.com/posts/how-to-set-userdefaults-value-with-launch-arguments/) )

```plain
serve --hostname 0.0.0.0 --port 8080
```

Use custom work directory. (See [Use custom working directory](https://docs.vapor.codes/getting-started/xcode/#custom-working-directory) )

Start DB using Docker. (See DB Section)

Build and Run Project

### Run App in Terminal

```bash
swift run App
```

### DB Dev

Run the following command to build and run the docker containers.

```bash
docker compose up --build db pgadmin --detach
```

Once the containers are up and running, you will be able to view the contents of the DB using PGAdmin.

```bash
http://127.0.0.1:8889
```

### REST Api Documentation

We used OpenApi Swagger, to create locally hosted api Documentation.

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
http://127.0.0.1:8889
```

#### Add the server

Username: <vapor_username@domain-name.com>
PASSWORD: vapor-password

![pgadmin](../img/pgadmin-server.png)

## FAQ

### I can't connect my watch to xcode

Watch needs to be connected to an iPhone.

Make sure developer mode is activated on watch and iPhone.

https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device

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
