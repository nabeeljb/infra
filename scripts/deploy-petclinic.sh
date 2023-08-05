#!/bin/bash

#!/bin/bash

ARTIFACTORY_USERNAME='prenabeeljbpre0004@gmail.com'
ARTIFACTORY_PASSWORD='Nbk12575670$'
CONTAINER_REGISTRY='prenabeel.jfrog.io/prealak-docker'
APP_NAME='alak'
MYSQL_ENDPOINT_NAME='your_mysql_endpoint_name_here' # Replace this with your MySQL endpoint name

cat > deploy-petclinic-files.yaml <<EOF
write_files:
  - path: /tmp/docker-compose.yaml
    content: |
      version: "2.2"
      services:
        petclinic:
          image: ${CONTAINER_REGISTRY}/${APP_NAME}:latest
          container_name: petclinic
          ports:
            - 8080:8080
          environment:
            - MYSQL_URL=jdbc:mysql://${MYSQL_ENDPOINT_NAME}/petclinic
runcmd:
  - [/bin/bash, -c, "export MYSQL_ENDPOINT_NAME=${MYSQL_ENDPOINT_NAME}"]
  - [/bin/bash, -c, "echo '$ARTIFACTORY_PASSWORD' | docker login -u $ARTIFACTORY_USERNAME --password-stdin ${CONTAINER_REGISTRY}"]
  - [/bin/bash, -c, "docker-compose -f /tmp/docker-compose.yaml up --detach"]
EOF
