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
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
        "awslogs-group": "${ECSTASK_LOG_GROUP}",
        "awslogs-region": "${REGION}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "environment": [
      {
        "name": "NUXT_ENV_API_DNS",
        "value": "${API_DNS}"
      },
      {
        "name": "NUXT_ENV_S3_END",
        "value": "${S3_END}"
      }
    ]
  }
]
