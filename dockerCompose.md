### Running this example using docker compose

To run this example using docker compose you can execute the following commands

```
git clone https://github.com/huawei-microservice-demo/mesher-example

mkdir -p /opt/mesher

tar -xvf release/mesher-1.0.5.tar

tar -C /opt/mesher -xvf mesher-1.0.5-linux.tar.gz

docker-compose up
```

This will bring up Service-Center, Client, Server, MesherConsumer, MesherProviderm, Zipkin, Grafana and Prometheus in your machine.

