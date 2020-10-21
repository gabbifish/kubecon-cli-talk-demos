# Kpt

Install kpt

```sh
go get github.com/GoogleContainerTools/kpt
```


Generate the prometheus Deployment

```sh
kpt fn run ./ --dry-run --enable-star
```

Customize by uncommenting the args in the deploy.yaml and run again

```sh
kpt fn run ./ --dry-run --enable-star
```
