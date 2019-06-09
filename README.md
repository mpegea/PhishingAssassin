# PhishingAssassin
_Usage Instructions_
***

## 0 - Dataset Configuration
### 0.1 - Change working directory to PhishingAssassin's main folder.
```
cd /your/path/to/PhishingAssassin
```
### 0.2 - Move or copy Dataset Files to be analyzed to each correspondant folder by its type.
```
cp /path/to/your/dataset ./test/dataset/__ham__
```
```
cp /path/to/your/dataset ./test/dataset/__phishing__
```
>_Note: Some email examples are given. You can remove them._
## 1 - Build Docker Images
### 1.1 - PhishingAssassin
```
docker image build --tag phishing_assassin ./phishing_assassin/
```
### 1.2 - Test
```
docker image build --tag test ./test/
```
***
## 2 - Create a new network
```
docker network create --subnet=10.0.0.0/24 phishing_test_network
```
***
## 3 - Container deployment
### 3.1 - PhishingAssassin
```
docker container run \
    --name phishing_assassin \
    --hostname phishing_assassin \
    --network test_network \
    --ip 10.0.0.10 \
    phishing_assassin
```    
### 3.2 - Test
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
>_Note: Once the container is deployed, if you want to launch the test again, you must use this command:_
```
docker container start --attach test
```
***
## 4 - Check results
Test results are wrote in `out.csv` for an easy post-analisys processing.
Also, the file `result.md` contains an statistical analysis from the results obtained. 
>_Note: You must use a Markdown file reader to view `result.md` with the intended format._
***
***

## Optional - Clean the Environment
```
rm -rf /your/path/to/PhishingAssassin
```
```
docker container rm -f phishing_assassin test
```
```
docker image rm -f phishing_assassin test
```
```
docker network rm test_network
```