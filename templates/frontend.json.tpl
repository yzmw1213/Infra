[
  {
    "essential": true,
    "name": "${CONTAINER_NAME}",
    "image": "${REPOSITORY_URL}",
    "portMappings": [
        {
            "containerPort": 3000,
            "hostPort": 3000
        }
    ]
  }
]
