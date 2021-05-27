# gowebdemo
This web app is using for CI/CD demo demonstration.

# build docker image
```sh
$ docker build -t goweb .
```

# run web app
```sh
$ docker run -d \
    -p 8088:8088 \
    --name webdemo \
    --restart=always \
    goweb
```

```
用到了docker in docker, 使用到了volume, 先把slave agent的/home/jenkins用pvc挂载出来, 然后使用sshfs把pvc目录共享到slave agent pod的node节点上, 解决

```
