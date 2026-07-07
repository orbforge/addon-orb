#!/bin/sh

printenv

echo "Starting MQTT publishing script..."
date

# Start MQTT publishing in the background
CONFIG_PATH=/data/options.json
if [ -n "$ORB_EPHEMERAL_MODE" ]; then
  echo "Using ORB_EPHEMERAL_MODE from environment variables"
else
  EPHEMERAL_MODE=$(jq -r '.ephemeral_mode // false' "$CONFIG_PATH")
  if [ "$EPHEMERAL_MODE" = "true" ]; then
    ORB_EPHEMERAL_MODE="1"
    export ORB_EPHEMERAL_MODE
    echo "ORB_EPHEMERAL_MODE is enabled"
  else
    echo "ORB_EPHEMERAL_MODE is disabled"
  fi
fi

if [ -n "$MQTT_PUSH" ]; then
  echo "Using MQTT_PUSH from environment variables"
else
  MQTT_PUSH=$(jq -r '.mqtt_push // false' $CONFIG_PATH)
fi

if [ "$MQTT_PUSH" == "true" ]; then
  echo "MQTT Push is enabled"
  /app/mqtt.sh &
else
  echo "MQTT Push is disabled"
fi


# Now start the original entrypoint or command
exec /app/orb sensor
