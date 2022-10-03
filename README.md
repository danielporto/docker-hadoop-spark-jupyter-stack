# Docker multi-container environment with Hadoop/HDFS, Spark and PySpark/Jupyter

This is it: a Docker multi-container environment with Hadoop/HDFS, Spark and Jupyter. 

## Create the certificates required to access with https:
go to certs folder and run the script:
```
bash generate-certs.sh
```

## Quick Start local deployment

To deploy an the HDFS-Spark-Jupyter cluster, run:
```
  docker-compose build
  docker-compose --env-file env up
```

`docker-compose` creates a docker network that can be found by running `docker network list`, e.g. `docker-hadoop-spark-jupter-stack_default`.

Run `docker network inspect` on the network (e.g. `docker-hadoop-spark-jupter-stack_default`) to find the IP the hadoop interfaces are published on. Access these interfaces with the following URLs:

| Service          | Without Proxy                                     | With Proxy                        |
|------------------|---------------------------------------------------|-----------------------------------|
| Traefik dashboard| http://localhost                                  | https://traefik.pluribus.vcap.me  |
| Portainer        | http://localhost:9090                             | https://portainer.pluribus.vcap.me |
| Logs/Dozzle      | http://localhost:9090                             | https://logs.pluribus.vcap.me     |
| Namenode         | http://localhost:9870                             | https://namenode.pluribus.vcap.me |
| History server   | http://localhost:8188/applicationhistory          | https://history.pluribus.vcap.me  |
| Datanode         | http://localhost:9864/                            | https://datanode.pluribus.vcap.me |
| Nodemanager      | http://localhost:8042/node                        | https://nodemanager.pluribus.vcap.me/node |
| Resource manager | http://localhost:8088/                            | https://resources.pluribus.vcap.me |
| Spark master     | http://localhost:8080/                            | http://spark.pluribus.vcap.me     |
| Spark worker     | http://localhost:8081/                            | http://worker.pluribus.vcap.me    |
| Jupyter          | http://localhost:10000                            | http://jupyter.pluribus.vcap.me   |

## Preliminaries upload file to hdfs:

Use the namenode as starting point to upload content to hfds:
```
 docker exec -it namenode bash
```
Then, create a directory on hfds where the dataset must be uploaded. 
Create a HDFS directory /data/openbeer/breweries.
```
  hdfs dfs -mkdir -p /data/openbeer/breweries
```

Copy breweries.csv to HDFS:
```
  hdfs dfs -put /data/breweries.csv /data/openbeer/breweries/breweries.csv
```

## Quick Start with Jupyter:
Navigate to Jupyter website: http://jupyter.pluribus.vcap.me and create a new notebook.
run:
```
from pyspark.sql import SparkSession
spark = SparkSession.builder.master("spark://spark-master:7077").appName("Dataframe from csv in hdfs").getOrCreate()
brewfile = spark.read.csv("hdfs://namenode:9000/data/openbeer/breweries/breweries.csv")
  
brewfile.show()

+----+--------------------+-------------+-----+---+
| _c0|                 _c1|          _c2|  _c3|_c4|
+----+--------------------+-------------+-----+---+
|null|                name|         city|state| id|
|   0|  NorthGate Brewing |  Minneapolis|   MN|  0|
|   1|Against the Grain...|   Louisville|   KY|  1|
|   2|Jack's Abby Craft...|   Framingham|   MA|  2|
|   3|Mike Hess Brewing...|    San Diego|   CA|  3|
|   4|Fort Point Beer C...|San Francisco|   CA|  4|
|   5|COAST Brewing Com...|   Charleston|   SC|  5|
|   6|Great Divide Brew...|       Denver|   CO|  6|
|   7|    Tapistry Brewing|     Bridgman|   MI|  7|
|   8|    Big Lake Brewing|      Holland|   MI|  8|
|   9|The Mitten Brewin...| Grand Rapids|   MI|  9|
|  10|      Brewery Vivant| Grand Rapids|   MI| 10|
|  11|    Petoskey Brewing|     Petoskey|   MI| 11|
|  12|  Blackrocks Brewery|    Marquette|   MI| 12|
|  13|Perrin Brewing Co...|Comstock Park|   MI| 13|
|  14|Witch's Hat Brewi...|   South Lyon|   MI| 14|
|  15|Founders Brewing ...| Grand Rapids|   MI| 15|
|  16|   Flat 12 Bierwerks| Indianapolis|   IN| 16|
|  17|Tin Man Brewing C...|   Evansville|   IN| 17|
|  18|Black Acre Brewin...| Indianapolis|   IN| 18|
+----+--------------------+-------------+-----+---+
only showing top 20 rows
```
more info: https://sparkbyexamples.com/pyspark/pyspark-read-csv-file-into-dataframe/


# Advanced:
## Quick Start Spark (PySpark)

Go to http://spark.pluribus.vcap.me or http://localhost:8080/ on your Docker host (laptop) to see the status of the Spark master.

Use Portainer to access the shell of the spark-master container.
Go to the command line of the Spark master/worker/jupyter and start PySpark.
```
  docker exec -it spark-master bash

  /spark/bin/pyspark --master spark://spark-master:7077

Python 3.7.10 (default, Mar  2 2021, 09:06:08) 
[GCC 8.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
22/07/25 14:12:37 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /__ / .__/\_,_/_/ /_/\_\   version 3.2.1
      /_/

Using Python version 3.7.10 (default, Mar  2 2021 09:06:08)
Spark context Web UI available at http://3b5822d57c5b:4040
Spark context available as 'sc' (master = spark://spark-master:7077, app id = app-20220725141239-0000).
SparkSession available as 'spark'.
>>> 
```

Load breweries.csv from DFS.
```
  brewfile = spark.read.csv("hdfs://namenode:9000/data/openbeer/breweries/breweries.csv")
  
  brewfile.show()
+----+--------------------+-------------+-----+---+
| _c0|                 _c1|          _c2|  _c3|_c4|
+----+--------------------+-------------+-----+---+
|null|                name|         city|state| id|
|   0|  NorthGate Brewing |  Minneapolis|   MN|  0|
|   1|Against the Grain...|   Louisville|   KY|  1|
|   2|Jack's Abby Craft...|   Framingham|   MA|  2|
|   3|Mike Hess Brewing...|    San Diego|   CA|  3|
|   4|Fort Point Beer C...|San Francisco|   CA|  4|
|   5|COAST Brewing Com...|   Charleston|   SC|  5|
|   6|Great Divide Brew...|       Denver|   CO|  6|
|   7|    Tapistry Brewing|     Bridgman|   MI|  7|
|   8|    Big Lake Brewing|      Holland|   MI|  8|
|   9|The Mitten Brewin...| Grand Rapids|   MI|  9|
|  10|      Brewery Vivant| Grand Rapids|   MI| 10|
|  11|    Petoskey Brewing|     Petoskey|   MI| 11|
|  12|  Blackrocks Brewery|    Marquette|   MI| 12|
|  13|Perrin Brewing Co...|Comstock Park|   MI| 13|
|  14|Witch's Hat Brewi...|   South Lyon|   MI| 14|
|  15|Founders Brewing ...| Grand Rapids|   MI| 15|
|  16|   Flat 12 Bierwerks| Indianapolis|   IN| 16|
|  17|Tin Man Brewing C...|   Evansville|   IN| 17|
|  18|Black Acre Brewin...| Indianapolis|   IN| 18|
+----+--------------------+-------------+-----+---+
only showing top 20 rows

```