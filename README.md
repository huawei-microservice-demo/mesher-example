# Mesher Example

## Making your service resilient using Mesher

This example shows you how to make your service as a Micro-Service using Mesher. In this example we have two simple services called client and server. We make this service use Mesher to do the communication between them and helps you to make your service robust and resilient.  
You can watch a short demonstration of this example in this [video](https://www.youtube.com/watch?v=5Lg8kWVmrCU) and  full tutorial of running this example with [CSE](http://www.huaweicloud.com/product/cse.html) Governance Console [here](https://www.youtube.com/watch?v=MKHklgzAyaw). 

## Running Service in Cloud Service Engine(CSE) or with open source solution

You can run these services in Huawei Public Cloud or in your local Machine and register these micro-services in CSE. And make use of [CSE](http://www.huaweicloud.com/product/cse.html) Governance Console to mange and monitor the services.

Or you can connect to [Service center](https://github.com/ServiceComb/service-center) without CSE, but you will lose monitoring, Hot-reconfigurarion and Governance web console features

## Get Started

### Run with Docker-Compose
One of the great options to run this example is to use docker-compose, you can follow [this guideline](dockerCompose.md) to run this example.

### Run locally
You can follow the below steps to run the services in your local VM's and use the CSE Service-Center to register the micro-service, you can also use the Config-Center of CSE to manage your configurations. CSE also provider monitoring sever which can help you to monitor your service statistics.

**Notice**: you should prepare 2 VM to run this demo

Step 1: Clone the code in VM1
```sh
export GOPATH=$PWD
go get github.com/huawei-microservice-demo/mesher-example/client
```
Clone in VM2
```sh
export GOPATH=$PWD
go get github.com/huawei-microservice-demo/mesher-example/server
```

Step 2: Start the server in VM2
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

Step 3: Download  and start the Mesher in both VM
You can download the Mesher release from [here](/release/mesher-1.0.5.tar) and choose one of the below options for running the Mesher.
#### Running Mesher with Open Source [Service-Center](https://github.com/ServiceComb/service-center)
One way for bringing up the Mesher easily is to [download](https://github.com/ServiceComb/service-center/releases) the open-source service-center and follow the [guide](https://github.com/ServiceComb/service-center#quick-start) to bring up the service-center locally.
Once the Service-Center is running then you can follow the below steps to run Mesher in VM2.

1.Export the following variables in VM2
```sh
export CSE_REGISTRY_ADDR=http://127.0.0.1:30100
#tell mesher where is your service listen at
export SPECIFIC_ADDR=127.0.0.1:3000
```
2.edit conf/chassis.yaml
change advertiseAddress and listenAddress to external IP
**Example:**
```yaml
  protocols:
    http:
      listenAddress: 192.168.1.1:30101
```

3.edit conf/microservice.yaml
change name to `demoServer`

4.Run  mesher
```sh
./mesher
```
this will make the Mesher Provider run at 30101 port

#### Running Mesher with [CSE](http://www.huaweicloud.com/product/cse.html)
Another way to bring up the Mesher is to use the  [CSE](http://www.huaweicloud.com/product/cse.html) Service-Center and Governance Console. For registering your microservice to CSE service-center you will need the AK/SK of your project which can be found by following the steps [here](https://support.huaweicloud.com/api-dis/mrs_02_0008.html).  
Once you got the AK/SK then you need to configure the AK/SK in mesher conf/auth.yaml by following the steps [here](https://support.huaweicloud.com/devg-servicestage/cse_mesh_0013.html) 

1.Export the following variables in VM2
```sh
#tell mesher where is your service listen at
export SPECIFIC_ADDR=127.0.0.1:3000 
```
2.edit conf/chassis.yaml
change advertiseAddress and listenAddress to external IP
**Example:**
```yaml
  protocols:
    http:
      listenAddress: 192.168.1.1:30101
```

3.edit conf/microservice.yaml
change name to `demoServer`

4.Run  mesher
```sh
./mesher
```
this will make the Mesher Provider run at 30101 port

Step 4: Start the Mesher in VM1
Based on your selection of Service-Center in Step 3 you can configure the Mesher in VM1 

##### Running Mesher with Open Source Service-Center
Export the following variables
```sh
#Based on where your opensource service-center is running you can configure the below IP
export CSE_REGISTRY_ADDR=http://127.0.0.1:30100
```
Run mesher
```sh
./mesher
```
This will bring up the Mesher in 30101 port

##### Running Mesher with [CSE](http://www.huaweicloud.com/product/cse.html)

You need to configure AK/SK as per steps given in Step3 and then follow the below commands.

1.edit conf/microservice.yaml
change name to `demoClient`
Run mesher
```sh
./mesher
```
This will bring up the Mesher in 30101 port

Step 5:
Start the Client in VM1
```sh
cd src/github.com/huawei-microservice-demo/mesher-example/client
vi conf/app.conf

## Edit the below addr
PROVIDER_ADDR=http://demoServer

## Save the file and come out

### Export the http_proxy so that all calls going from Client is proxied through MesherConsumer

export http_proxy=127.0.0.1:30101

./client
```
This will bring up Client on 3000 port exposing the below Api's
```     
    {Name: "latency", Method: rata.GET, Path: "/TestLatency"},
    {Name: "error", Method: rata.GET, Path: "/TestErrors"},
```

Congratulations, Now all your applications are running with Mesher

now you can call the Client Api's

```sh
root@mesher-01-eip:~# curl -v 117.78.44.191:3000/TestLatency
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

```sh
root@mesher-01-eip:~# curl -v 117.78.44.191:3000/TestErrors
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
# mesher-examples
