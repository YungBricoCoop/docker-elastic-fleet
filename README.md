# docker-elastic-fleet

## Elastic search self signed certificate

⚠️ The following steps are only required if you are using self signed certificate for elastic search. By default, this project uses the elastic search self signed certificate.

To let elastic fleet server connect to elastic search, we need to update the config of the fleet.
Follow the steps below :

1.  Open kibana : `Management -> Fleet -> Settings -> Output -> edit (default)`.
2.  Run the following command and follow the instructions.
    ```bash
    docker exec -it ef_elastic_search /bin/bash /usr/local/bin/get_ca_certs_info.sh
    ```
