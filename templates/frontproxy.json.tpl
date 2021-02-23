[
  {
    "essential": true,
    "name": "${CONTAINER_NAME}",
    "image": "${REPOSITORY_URL}",
    "portMappings": [
        {
            "containerPort": 443,
            "hostPort": 443
        },
        {
            "containerPort": 8080,
            "hostPort": 8080
        }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
        "awslogs-group": "${ECSTASK_LOG_GROUP}",
        "awslogs-region": "${REGION}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
