# aws-lambda-container-cicd-example
This is an example of CI/CD using AWS Lambda's container image support and terraform.

## Usage

create a dummy container image in ecr repository
```sh
$ FUNCTION_NAME=aws-lambda-container-cicd-example
$ REGION=$(aws configure get region)
$ ACCOUNTID=$(aws sts get-caller-identity --output text --query Account)
$ docker build -t ${FUNCTION_NAME} .
$ aws ecr create-repository --repository-name ${FUNCTION_NAME}
$ docker tag ${FUNCTION_NAME}:latest ${ACCOUNTID}.dkr.ecr.${REGION}.amazonaws.com/${FUNCTION_NAME}:latest
$ aws ecr get-login-password | docker login --username AWS --password-stdin ${ACCOUNTID}.dkr.ecr.${REGION}.amazonaws.com
$ docker push ${ACCOUNTID}.dkr.ecr.${REGION}.amazonaws.com/${FUNCTION_NAME}:latest
```

terraform apply
```sh
$ cd terraform
$ terraform init
$ terraform apply
```

automatically deployed to Lambda function with each push.
