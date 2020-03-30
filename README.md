Table of Contents
-------------------

 * [Installation](#installation)
 * [Quick Start](#quick-start)
 * [Persistence](#developmentpersistence)
 * [Logging](#logging)

Installation
-------------------

 * [Install Docker 1.9+](https://docs.docker.com/installation/) or [askubuntu](http://askubuntu.com/a/473720)
 * Pull the latest version of the image.
 
```bash
docker pull partychen/docker-nginx-phpfpm
```

Alternately you can build the image yourself.

```bash
git clone https://github.com/partychen/docker-nginx-phpfpm.git
cd docker-nginx-phpfpm
docker build -t="$USER/docker-nginx-phpfpm" .
```

Quick Start
-------------------

Run the application container:

```bash
docker run --name app -d -p 8080:80 partychen/docker-nginx-phpfpm
```

The simplest way to login to the app container is to use the `docker exec` command to attach a new process to the running container.

```bash
docker exec -it app bash
```

Development/Persistence
-------------------

For development a volume should be mounted at `/var/www/app/`.

The updated run command looks like this.

```bash
docker run --name app -d -p 8080:80 \
  -v /host/to/path/app:/var/www/app/ \
  partychen/docker-nginx-phpfpm
```


Logging
-------------------

All the logs are forwarded to stdout and sterr. You have use the command `docker logs`.

```bash
docker logs app
```

#### Split the logs

You can then simply split the stdout & stderr of the container by piping the separate streams and send them to files:

```bash
docker logs app > stdout.log 2>stderr.log
cat stdout.log
cat stderr.log
```

or split stdout and error to host stdout:

```bash
docker logs app > -
docker logs app 2> -
```

#### Rotate logs

Create the file `/etc/logrotate.d/docker-containers` with the following text inside:

```
/var/lib/docker/containers/*/*.log {
    rotate 31
    daily
    nocompress
    missingok
    notifempty
    copytruncate
}
```
> Optionally, you can replace `nocompress` to `compress` and change the number of days.
