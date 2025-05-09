ARG DOCKER_VERSION="latest"
FROM orbforge/orb:${DOCKER_VERSION}

# Install mosquitto_pub/sub via system package manager
RUN apk add --no-cache mosquitto-clients curl jq

# Add scripts
COPY mqtt.sh /app/mqtt.sh
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/mqtt.sh /app/entrypoint.sh

# Override the entrypoint to inject the background script
ENTRYPOINT ["/app/entrypoint.sh"]
