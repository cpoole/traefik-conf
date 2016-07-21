traefik-conf
==============

This image is the dynamic confd and rancher based sidekick for traefik. 

## Build

```
docker build -t connorpoole/traefik-conf:<version> .
```

## Usage

This repo contains the docker-compose and rancher-compose files needed to deploy this as a stack to rancher. This repo also contains a dockerfile to build the traefik-conf sidekick. This image has to be run as a sidekick of traefik, and makes the /etc/traefik directory as a volume. It scans from rancher-metadata, for services that have traefik labels, and generates traefik frontends and backends to expose the services.

## Configuration labels

The following labels have to be added to your service.

* traefik.enable = *true | stack | manual | false* #Controls if and how you want to publish or not the service
    * true: the service will be published as *service_name.stack_name.traefik_domain*
    * stack: the service will be published as *stack_name.domain*. WARNING: You can have collisions inside services within yout stack
    * manual: the service frontend will be published as the labels *traefik_domain_prefix.traefik_domain*
    * false: the service will not be published
* traefik.domain	= *Domain names to route rules. Multiple domains separated by ","*
* traefik.port = *port to expose throught traefik*

Optional labels:

* traefik.domain_prefix = *first portion of dns name* 
    * **OPTIONAL:** only required if setting traefik.enable to manual. This label sets the first portion of the dns name
* traefik.backend_name = *backend name in traefik rules.toml* 
    * **OPTIONAL:** only required if setting traefik.enable to manual. This label sets the name of the backend in the traefik rules.toml
* traefik.https_backend = *true* will set your backend proxy to https. 
    * Needed if the service container requires https all the way to the container.

WARNING: Only services with healthy state are added to traefik, so health checks are mandatory.

The primary traefik config file is also included in this image and volume mounted into traefik. 
The following environment variables are required:
* CONFD_INTERVAL | the number of seconds between confd polling the rancher metadata. int only, no characters
* CONFD_PREFIX | the rancher metadata version string (ie. latest, 2015-12-19)

The following environment variables can be used to override the defaults:
* TRAEFIK_LOG_LEVEL | default=debug
* TRAEFIK_HTTP_PORT | default=80
* TRAEFIK_HTTPS_PORT | default=443
* TRAEFIK_ADMIN_PORT | default = 8000

## Deployment
```rancher-compose up --upgrade -d```


