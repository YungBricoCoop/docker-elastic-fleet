# docker-elastic-fleet

Running **elastic fleet server** for the first time can be a bit tricky. This repository aims to simplify the process by providing 2 docker-compose files, one for dev and one for prod.

The repo is heavily inspired by the [elastic-stack-docker-part-two](https://github.com/evermight/elastic-stack-docker-part-two/tree/main),

# Dev

> ⚠️ Running in dev mode implies that only the containers within the same network (ef_elastic) can be enrolled. I think this can be changed to allow any agent to connect to the fleet server, but don't know how to do it yet.

1. Create networks and volumes

```bash
docker network create ef_network
docker volume create ef_certs
```

2. Start the services

```bash
docker compose -f docker-compose.dev.yml up -d
```

3. Setup the **fleet server**

    To let the agents connect to the fleet server, we need to update the config of the fleet.
    Follow the steps below :

    1. Open kibana : `Management -> Fleet -> Settings -> Fleet server hosts -> Add`.
    2. Add the following url : `https://fleet-server:8220`.

    Let the agents connect to elastic search :

    1. Open kibana : `Management -> Fleet -> Settings -> Output -> edit (default)`.
    2. Run the following command and follow the instructions.
        ```bash
        docker exec -it ef_elastic_search /bin/bash /usr/local/bin/get_ca_certs_info.sh
        ```

# Prod

> ⚠️ Running this in prod mode implies that you have at least a valid public domain name and a valid SSL certificate for elastic search and fleet server. Using a reverse proxy to expose the services is not mandatory but highly recommended.

1. Create networks and volumes

```bash
docker network create nginx
docker network create ef_network
docker volume create ef_certs
```

2. Start the services

```bash
docker compose up -d
```

3. Update the reverse proxy config

    Below is an example of a reverse proxy config using nginx. A mandatory step is to add the trusted certificate of the CA used to sign the certificates of the services. This is needed to verify the certificates of the services.

    ```nginx
    server {
    	listen 443 ssl;
    	listen [::]:443 ssl;

    	server_name elastic-search.mydomain.com;

    	ssl_certificate         /etc/letsencrypt/live/mydomain.com/fullchain.pem;
    	ssl_certificate_key     /etc/letsencrypt/live/mydomain.com/privkey.pem;
    	ssl_trusted_certificate /etc/letsencrypt/live/mydomain.com/chain.pem;

    	location / {
    		proxy_pass https://elastic-search:9200;
    		proxy_http_version 1.1;
    		proxy_set_header Upgrade $http_upgrade;
    		proxy_set_header Connection 'upgrade';
    		proxy_set_header Host $host;
    		proxy_cache_bypass $http_upgrade;

    		proxy_ssl_verify on;
    		proxy_ssl_trusted_certificate /etc/ef_certs/ca/ca.crt;
    		proxy_ssl_session_reuse on;
    	}
    }

    server {
    	listen 443 ssl;
    	listen [::]:443 ssl;

    	server_name elastic-fleet.mydomain.com;

    	ssl_certificate         /etc/letsencrypt/live/mydomain.com/fullchain.pem;
    	ssl_certificate_key     /etc/letsencrypt/live/mydomain.com/privkey.pem;
    	ssl_trusted_certificate /etc/letsencrypt/live/mydomain.com/chain.pem;

    	ssl_dhparam /etc/letsencrypt/dhparams/dhparam.pem;

    	location / {
    		proxy_pass https://fleet-server:8220;
    		proxy_http_version 1.1;
    		proxy_set_header Upgrade $http_upgrade;
    		proxy_set_header Connection 'upgrade';
    		proxy_set_header Host $host;
    		proxy_cache_bypass $http_upgrade;

    		proxy_ssl_verify on;
    		proxy_ssl_trusted_certificate /etc/ef_certs/ca/ca.crt;
    		proxy_ssl_session_reuse on;
    	}
    }
    ```

    Then restart the reverse proxy.

4. Setup the fleet server

    > ⚠️ The urls you will use in the following steps are the public urls of the services. They need to match the domain names and the ports you used to expose the services with the reverse proxy.

    To let the agents connect to the fleet server, we need to update the config of the fleet.
    Follow the steps below :

    1. Open kibana : `Management -> Fleet -> Settings -> Fleet server hosts -> Add`.
    2. Add the following url : `https://elastic-fleet.mydomain.com`.

    Let the agents connect to elastic search :

    1. Open kibana : `Management -> Fleet -> Settings -> Output -> edit (default)`.
    2. Add the following url : `https://elastic-search.mydomain.com`.
