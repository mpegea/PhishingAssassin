# PhishingAssassin
_PhishingAssassin is an open source tool intended to ease the design of anti-phishing filters. It is based in the well known spam filter SpamAssassin._

_It's formed by two Docker images that works following a Client-Server architecture. It can be deployed both Client and Server in a single Host or in multiple Hosts._

_The SpamAssassin framework it's used to launch rules and plugin filters implemented by the user through an entire email dataset. By default, SpamAssassin won't have any anti-spam filters, because this tool is focused into fighting against phishing._

_You have to insert your own anti-phishing filters and a mail dataset to be analyzed._

_Then, the results are statistically analyzed._


***
***


# Usage Instructions
## Download
```
apt-get install git
git clone https://github.com/mpegea/PhishingAssassin.git
```

## Configuration
### Change working directory to PhishingAssassin's main folder.
```
cd /your/path/to/PhishingAssassin
```
### Move or copy Dataset Files to be analyzed to each correspondant folder by its type.
```
cp /path/to/your/ham/dataset ./test/dataset/__ham__
```
```
cp /path/to/your/phishing/dataset ./test/dataset/__phishing__
```
>_Note: Some email examples are given. You can remove them._


### Insert anti-phishing rules and plugins.

Plugin Load -> `./phishing_assassin/plugin_load/`<br/>
Plugins -> `./phishing_assassin/plugins/`<br/>
Rules -> `./phishing_assassin/rules/`
>_Note: Some filter examples are given. You can remove them._



### Select your Analysis Server
```
Modify the value of the SERVER variable in ./test/run_test.sh
``` 



## Build Docker Images

### PhishingAssassin 
```
docker image build --build-arg ALLOWED_CLIENT_IPS=<your_client_IPs> --tag phishing_assassin ./phishing_assassin/
```
>_Note: You must configure the ALLOWED_CLIENT_IPS argument according to Spamd configuration._<br/>
https://spamassassin.apache.org/full/3.2.x/doc/spamd.html

### Test
```
docker image build --tag test ./test/
```

***

## Single-Host Deployment
### Create a new Docker network
```
docker network create --subnet=10.0.0.0/24 phishing_test_network
```

### PhishingAssassin
```
docker container run \
    --name phishing_assassin \
    --hostname phishing_assassin \
    --network test_network \
    --ip 10.0.0.10 \
    phishing_assassin
```    
### Test
```
docker container run \
    --name test \
    --hostname test \
    --network test_network \
    --ip 10.0.0.5 \
    --mount type=bind,source="$(pwd)"/test/dataset,target=/root/dataset,readonly \
    --mount type=bind,source="$(pwd)"/test/run_test.sh,target=/root/run_test.sh \
    --mount type=bind,source="$(pwd)"/test/check_results.awk,target=/root/check_results.awk \
    --mount type=bind,source="$(pwd)"/test/out.csv,target=/root/out.csv \
    --mount type=bind,source="$(pwd)"/test/result.md,target=/root/result.md \
    test
```

***

## Dual-Host Deployment
### PhishingAssassin
```
docker container run \
    --name phishing_assassin \
    --network host
    phishing_assassin
```

### Test
```
docker container run \
    --name test \
    --mount type=bind,source="$(pwd)"/test/dataset,target=/root/dataset,readonly \
    --mount type=bind,source="$(pwd)"/test/run_test.sh,target=/root/run_test.sh \
    --mount type=bind,source="$(pwd)"/test/check_results.awk,target=/root/check_results.awk \
    --mount type=bind,source="$(pwd)"/test/out.csv,target=/root/out.csv \
    --mount type=bind,source="$(pwd)"/test/result.md,target=/root/result.md \
    test
```
>_Note: Once the container is deployed, if you want to launch the test again, you must use the next command_
```
docker container start --attach test
```

***

## Swarm Cluster Deployment
First, all the nodes must  be configurated (each one according to its kind) to allow Docker Swarm networking.
### Manager Node Firewall Configuration
```
apt-get install iptables-persistent
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 2376 -j ACCEPT
iptables -A INPUT -p tcp --dport 2377 -j ACCEPT
iptables -A INPUT -p tcp --dport 7946 -j ACCEPT
iptables -A INPUT -p udp --dport 7946 -j ACCEPT
iptables -A INPUT -p udp --dport 4789 -j ACCEPT
netfilter-persistent save
systemctl restart docker
```
### Worker Nodes Firewall Configuration
```
apt-get install iptables-persistent
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 2376 -j ACCEPT
iptables -A INPUT -p tcp --dport 7946 -j ACCEPT
iptables -A INPUT -p udp --dport 7946 -j ACCEPT
iptables -A INPUT -p udp --dport 4789 -j ACCEPT
netfilter-persistent save
sudo systemctl restart docker
```

### Initialize the Swarm mode in the Manager Node
Run in the node that you want to set as the Swarm Manager.
```
docker swarm init --advertise-addr <manager_IP>
```
>_Note: The past command will produce the a personalized output for your cluster configuration. The command showed, will be necessary for the next step_
### Add Worker Nodes to the Swarm
Run in each node that you want to add as a Swarm Worker.
```
docker swarm join --token <y0vrT0Ken> <manager_IP>:<port>
```
### Deploying a Service in the Swarm
```
docker service create --replicas <number_of_replicas> --name phishing_assassin phishing_assassin
```
>_Note: You must have phishing_assassin image build in all nodes, or use your own image registry_

***

## Check results
Test results are wrote in `out.csv` for an easy post-analisys processing.
Also, the file `result.md` contains an statistical analysis from the results obtained. 
>_Note: You must use a Markdown file reader to view `result.md` with the intended format._


***
***
***


## Optional - Clean the Environment
```
docker service rm phishing_assassin
```
>_Note: The past command is only necessary in a Swarm Cluster Deployment. It must be executed in the Manager Node_
```
docker container rm -f phishing_assassin test
```
```
docker image rm -f phishing_assassin test
```
```
docker network rm test_network
```
>_Note: The past command is only necessary in a Single-Host Deployment._
```
rm -rf /your/path/to/PhishingAssassin
```