[
  {
    "essential": true,
    "name": "${CONTAINER_NAME}",
    "image": "${REPOSITORY_URL}",
    "portMappings": [
        {
            "containerPort": 50052,
            "hostPort": 50052
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
        "name": "DB_ADRESS",
        "value": "${DB_ADRESS}"
      },
      {
        "name": "DB_NAME",
        "value": "${DB_NAME}"
      },
      {
        "name": "DB_PASSWORD",
        "value": "${DB_PASSWORD}"
      },
      {
        "name": "DB_USER",
        "value": "${DB_USER}"
      }
    ]
  },
  {
    "name": "userenvoy",
    "image": "${PROXY_REPOSITORY_URL}",
    "user": "0",
    "essential": true,
    "cpu": 64,
    "memoryReservation": 256,
    "portMappings": [
      {
        "containerPort": 9902,
        "hostPort": 9902,
        "protocol": "tcp"
      },
      {
        "containerPort": 8082,
        "hostPort": 8082,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "ENVOY_LOG_LEVEL",
        "value": "info"
      },
      {
        "name": "ENABLE_ENVOY_STATS_TAGS",
        "value": "1"
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
