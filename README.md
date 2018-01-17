## typescript-koa-boilerplate
### start server
```
$ yarn
$ npm start
```

### How to use with docker
#### put npm authToken to env
```
cat ~/.npmrc
```
you'll see `//registry.npmjs.org/:_authToken=blablabla`

```
export NPM_TOKEN=blablabla
```
it's because we may have private module to install while we're building docker image
now, build your own docker image!
