# devops-assessment

This repository contains a NodeJS application with two endpoints.

`/hive`, that will always return:

```
{
    foo: "bar"
}
```

`/healthcheck`, that will return either:

```
{
    status: "up",
    uptime: 2000
}
```

```
{
    status: "down",
    reason: "Why are we down"
}
```

## Environment Variables
There is a single environment variable `PORT` - on which the node application will listen.  If running the application outside of Docker, then a `.env` file will be loaded in which the port can be specified.

## Running outside Docker

If you have node installed on your local machine, then the following commands can be used:

* `npm install` - Install dependencies
* `npm run test` - Run unit tests
* `npm run watch` - Start in watch mode

## Running inside Docker
The included Dockerfile can be used to build a container image. Currently the Dockerfile will copy across all source files, install depencies and run tests.

```
docker build --tag devops:latest .
```

When the image is built, it can be started using:

```
docker run -d -p 3000:3000 devops:latest
```

The application should now be available on `localhost:3000`

## Deployment

To deploy the application you will need Terraform installed, see https://www.terraform.io/downloads.html
You also need to connect Terraform to AWS, see https://www.terraform.io/docs/providers/aws/index.html#authentication

Now, from within the terraform folder, run the changes on AWS:
```
terraform init
terraform apply
```

It will ask you a few questions about your deployment.

As a result, AWS will create your Docker repository, which you now need to populate with a build:
```
$(aws ecr get-login --no-include-email --region [region])
docker build -t devops-assessment .
docker tag devops-assessment:latest [repo]
docker push [repo]
```

Now wait a bit, check out your EC2 load balancer for its DNS name, and the given URL will lead to the API.

# TODO: Here we would want to have a nice domain name to link to, instead of ugly AWS LB names
