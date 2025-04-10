# Database

## Connect

```bash
kubectl --kubeconfig kubeconfig.yml -n db port-forward svc/cluster 3333:3306

kubectl --kubeconfig kubeconfig.yml -n db get secret galera-cluster-root -o jsonpath="{.data.root-password}" | base64 --decode

docker run --rm -it --net host --entrypoint bash mysql

mysql -h 127.0.0.1 -P 3333 -p
```


## Create user

```mysql
CREATE DATABASE  IF NOT EXISTS DB_NAME;

CREATE USER 'USER'@'%' IDENTIFIED BY 'password';


GRANT ALL PRIVILEGES ON DB_NAME.* To 'USER'@'hostname';

```
