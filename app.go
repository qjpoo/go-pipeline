package main

import (
	"fmt"
	"net/http"
	"strings"
	"time"
)

func getNameLen(name string) int {
	return len(name)
}

func sayHello(w http.ResponseWriter, r *http.Request) {
	message := r.URL.Path
	message = strings.TrimPrefix(message, "/")
	message = "Hello " + message + " : " + fmt.Sprintf("%d", getNameLen(message)) + "\n"
	fmt.Print(getDayString() + " " + message)
	w.Write([]byte(message))
}

func main() {
	http.HandleFunc("/", sayHello)
	if err := http.ListenAndServe(":8088", nil); err != nil {
		panic(err)
	}
}

func getDayString() string {
	nowTime := time.Now()
	//loc, _ := time.LoadLocation("Asia/Shanghai")
	//chTime := nowTime.In(loc)
	return nowTime.Format("20060102150405")
}
