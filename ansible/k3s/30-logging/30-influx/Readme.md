# Influx

Deploy InfluxDB using Helm charts.

# Use old InfluxQL language with InfluxDB2

### Create a Database in the v1 format as a facade for the bucket:
```shell
influx v1 dbrp create\
    --db example-db  \
    --rp example-rp \
    --bucket-id <bucket-id> \
    --default
```

### Create a user in the old format:

```shell
influx v1 auth create --username grafana --password 'supersecret' --read-bucket <bucket-id>
```

### [Configure in Grafana](https://docs.influxdata.com/influxdb/v2.1/tools/grafana/?t=InfluxQL#configure-your-influxdb-connection)

- Query Language: Select InfluxQL
- HTTP: Enter URL as normal
- Add Custom HTTP Header:
  - `Authorization: Token <token from webui>`
  - Make sure to enter `Token ` before the actual token
- InfluxDB Details
  - Database: exmaple-db (Configured when using `influx v1 dbrp create`)
  - User: grafana (From `influx v1 auth create`)
  - Password: supersecret (Like above)
  - HTTP Method: GET
