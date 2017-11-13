package main

import (
	"github.com/tedsuo/rata"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"sync"
)

var (
	schema       = "http://"
	desitination = "servermesher"
)

func main() {
	petRoutes := rata.Routes{
		{Name: "latency", Method: rata.GET, Path: "/TestLatency"},
		{Name: "error", Method: rata.GET, Path: "/TestErrors"},
	}
	petHandlers := rata.Handlers{
		"latency": &LatencyHandler{},
		"error":   &ErrorHandler{},
	}
	router, err := rata.NewRouter(petRoutes, petHandlers)
	if err != nil {
		panic(err)
	}

	// The router is just an http.Handler, so it can be used to create a server in the usual fashion:
	err = http.ListenAndServe("0.0.0.0:3000", router)
	if err != nil {
		log.Fatal(err)
	}
}

var status int = 200
var mu sync.RWMutex

type ErrorHandler struct {
}

func doGet(api string, w http.ResponseWriter) {

	providerName, isExsist := os.LookupEnv("PROVIDER_NAME")
	if isExsist {
		desitination = providerName
	}
	req, err := http.NewRequest(http.MethodGet, schema+desitination+api, nil)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
		return
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
		return
	}
	if resp == nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("Resp is nil"))
		return
	}
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
		return
	}
	w.WriteHeader(resp.StatusCode)
	w.Write(body)
	return
}
func (e *ErrorHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	doGet("/errors", w)
}

type LatencyHandler struct {
}

func (e *LatencyHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	doGet("/latency", w)
}
