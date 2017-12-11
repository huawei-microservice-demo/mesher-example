# Mesher Example

## Making your service resilient using Mesher

This example shows you how to make your service as a Micro-Service using Mesher. In this example we have two simple services called client and server. We make this service use Mesher to do the communication between them and helps you to make your service robust and resilient.

## Running Service in Cloud Service Engine(CSE) or with open source solution

You can run these services in Huawei Public Cloud or in your local Machine and register these micro-services in CSE. And make use of [CSE](http://www.huaweicloud.com/product/cse.html) Governance Console[ to mange and monitor the services.

Or you can connect to [Service center](https://github.com/ServiceComb/service-center) without CSE, but you will lose monitoring, Hot-reconfigurarion and Governance web console features

## Get Started
You can follow the below steps to run the services in your local VM's and use the CSE Service-Center to register the micro-service, you can also use the Config-Center of CSE to manage your configurations. CSE also provider monitoring sever which can help you to monitor your service statistics.

Step 1: Clone the code
```sh
export GOPATH=$PWD
go get github.com/huawei-microservice-demo/mesher-example/server
go get github.com/huawei-microservice-demo/mesher-example/client
```

Step 2: Start the server
```sh
cd bin
./server
```
this will start the Server exposing the below API's on 3000 port
```
    {Name: "latency", Method: rata.GET, Path: "/latency"}, 
    {Name: "error", Method: rata.GET, Path: "/errors"},
    {Name: "latency2", Method: rata.POST, Path: "/latency/:duration"},
    {Name: "error2", Method: rata.POST, Path: "/errors/:status"},
```

Step 3: Download  and start the Mesher Provider
Export the following variables
```
export CSE_REGISTRY_ADDR=https://cse.cn-north-1.myhwclouds.com:443
export CSE_CONFIG_CENTER_ADDR=https://cse.cn-north-1.myhwclouds.com:443
export CSE_MONITOR_SERVER_ADDR=https://cse.cn-north-1.myhwclouds.com:443
#tell mesher where is your service listen at
export SPECIFIC_ADDR=127.0.0.1:3000 
#tell mesher your service name
export SERVICE_NAME=demoServer
```
Run the start script to start the mesher
```
./start.sh
```
this will make the Mesher Provider run at 30101 port

Step 4: Start the Mesher Consumer(you can use the different VM or change the port at which mesher will run)
Export the following variables
```
export CSE_REGISTRY_ADDR=https://cse.cn-north-1.myhwclouds.com:443
export CSE_CONFIG_CENTER_ADDR=https://cse.cn-north-1.myhwclouds.com:443
export CSE_MONITOR_SERVER_ADDR=https://cse.cn-north-1.myhwclouds.com:443
#tell mesher your service name
export SERVICE_NAME=demoClient
```
Run the start script to Start the Mesher Consumer
```
./start.sh
```
This will bring up the Mesher Consumer in 30101 port

Step 5:
Start the Client
```
cd src/github.com/huawei-microservice-demo/mesher-example/client
vi conf/app.conf

## Edit the below addr
PROVIDER_ADDR=http://demoServer

## Save the file and come out

### Export the http_proxy so that all calls going from Client is proxied through MesherConsumer

export http_proxy=http://127.0.0.1:30101

./client
```
This will bring up Client on 3000 port exposing the below Api's
```		
	{Name: "latency", Method: rata.GET, Path: "/TestLatency"},
	{Name: "error", Method: rata.GET, Path: "/TestErrors"},
```

Congratulations, Now all your applications are running with Mesher

now you can call the Client Api's

```
root@mesher-01-eip:~# curl -v http://117.78.44.191:3000/TestLatency
*   Trying 117.78.44.191...
* Connected to 117.78.44.191 (117.78.44.191) port 3000 (#0)
> GET /TestLatency HTTP/1.1
> Host: 117.78.44.191:3000
> User-Agent: curl/7.47.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< Date: Fri, 17 Nov 2017 11:33:21 GMT
< Content-Length: 110
< Content-Type: text/plain; charset=utf-8
< 
The Latency for this request is : 100ms
* Connection #0 to host 117.78.44.191 left intact
The host serving this request is mesher-02 and the IP is 192.168.1.155
```

```
root@mesher-01-eip:~# curl -v http://117.78.44.191:3000/TestErrors
*   Trying 117.78.44.191...
* Connected to 117.78.44.191 (117.78.44.191) port 3000 (#0)
> GET /TestErrors HTTP/1.1
> Host: 117.78.44.191:3000
> User-Agent: curl/7.47.0
> Accept: */*
> 
< HTTP/1.1 500 Internal Server Error
< Date: Fri, 17 Nov 2017 11:34:02 GMT
< Content-Length: 208
< Content-Type: text/plain; charset=utf-8
< 
* Connection #0 to host 117.78.44.191 left intact

```

You can manage your Micro-Service in Governance Console in CSE.


Please follow the steps [here](metricsConfiguration.md) to Configure your application to monitor metrics in Grafana.
