[
  {
    "essential": true,
    "name": "${CONTAINER_NAME}",
    "image": "${REPOSITORY_URL}",
    "portMappings": [
        {
            "containerPort": 50053,
            "hostPort": 50053
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
      },
      {
        "name": "USER_URL",
        "value": "${USER_URL}"
      }
    ]
  },
  {
    "name": "postenvoy",
    "image": "${PROXY_REPOSITORY_URL}",
    "user": "0",
    "essential": true,
    "cpu": 64,
    "memoryReservation": 256,
    "portMappings": [
      {
        "containerPort": 9901,
        "hostPort": 9901,
        "protocol": "tcp"
      },
      {
        "containerPort": 8081,
        "hostPort": 8081,
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
