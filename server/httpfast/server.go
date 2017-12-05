package main

import (
	"fmt"
	"github.com/buaazp/fasthttprouter"
	"github.com/valyala/fasthttp"
	"log"
	"net"
	"os"
	"strconv"
	"sync"
	"time"
)

var (
	server_ip       = os.Getenv("SERVER_IP")
	server_port     = os.Getenv("SERVER_PORT")
	status      int = 500
	mu          sync.RWMutex
	latencyDur  string = "100ms"
)

func errorsFunc(ctx *fasthttp.RequestCtx) {
	mu.RLock()
	resp := fasthttp.Response{}
	header := fasthttp.ResponseHeader{}
	header.SetStatusCode(status)
	fmt.Println("Error in serving the response")
	resp.Header = header
	ctx.Response = resp
	mu.RUnlock()
}

func latency(ctx *fasthttp.RequestCtx) {
	mu.RLock()
	d, _ := time.ParseDuration(latencyDur)
	time.Sleep(d)
	mu.RUnlock()
	hostname, _ := os.Hostname()
	resp := fasthttp.Response{}
	b := []byte("The Latency for this request is : " + d.String() + "\n" +
		"The host serving this request is " + hostname + " and the IP is " + getOutboundIP().String())
	resp.AppendBody(b)
	fmt.Println("Serving the response for /latency")
	ctx.Response = resp
}

func errorStatus(ctx *fasthttp.RequestCtx) {
	mu.Lock()
	s := ctx.UserValue("status")
	status, _ = strconv.Atoi(s.(string))
	resp := fasthttp.Response{}
	header := fasthttp.ResponseHeader{}
	header.SetStatusCode(status)
	fmt.Println("Error in serving the response")
	resp.Header = header
	ctx.Response = resp
	mu.Unlock()
}
func latencyDuration(ctx *fasthttp.RequestCtx) {
	mu.Lock()
	latency := ctx.UserValue("duration")
	d, _ := time.ParseDuration(latency.(string))
	time.Sleep(d)
	mu.Unlock()
	hostname, _ := os.Hostname()
	resp := fasthttp.Response{}
	b := []byte("The Latency for this request is : " + d.String() + "\n" +
		"The host serving this request is " + hostname + " and the IP is " + getOutboundIP().String())
	resp.AppendBody(b)
	fmt.Println("Serving the response for /latency with parameters")
	ctx.Response = resp
}

func getOutboundIP() net.IP {
	conn, err := net.Dial("udp", "8.8.8.8:80")
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	localAddr := conn.LocalAddr().(*net.UDPAddr)

	return localAddr.IP
}

func main() {
	router := fasthttprouter.New()
	router.GET("/latency", latency)
	router.GET("/errors", errorsFunc)
	router.POST("/latency/:duration", latencyDuration)
	router.POST("/errors/:status", errorStatus)
	fmt.Println("Server started..........................")
	err := fasthttp.ListenAndServe(server_ip+":"+server_port, router.Handler)
	if err != nil {
		log.Fatal("Error")
	}
}
