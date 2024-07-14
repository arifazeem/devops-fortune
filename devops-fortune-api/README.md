# Fortune API 

## Installation

This requires below Packages 

```[Docker](https://docs.docker.com/get-docker/) ```

Start the Docker in Local.

```
cd api
docker build -t fortune-api .
docker run -d -p 8080:8080  --name fortune-container fortune-api
```

Access the below URL to check the status of the API

`http://localhost:8080/`

`http://localhost:8080/healthcheck`

`http://localhost:8080/v1/fortune`
