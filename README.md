## canner-backend
### How to start
#### install docker
https://docs.docker.com/docker-for-mac/install/
download from `Get Docker for Mac (Stable)`

#### put npm authToken to env
```
cat ~/.npmrc
```
you'll see `//registry.npmjs.org/:_authToken=blablabla`

```
export NPM_TOKEN=blablabla
```

#### run docker
docker compose will start mongo,redis,canner-backend at same time
```
docker-compose up
```
