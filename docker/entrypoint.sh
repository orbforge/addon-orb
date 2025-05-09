#!/bin/sh

printenv

echo "Starting MQTT publishing script..."
date

# Start MQTT publishing in the background
CONFIG_PATH=/data/options.json
MQTT_PUSH=$(jq -r '.mqtt_push // false' $CONFIG_PATH)

if [ "$MQTT_PUSH" == "true" ]; then
  echo "MQTT Push is enabled"
  /app/mqtt.sh &
else
  echo "MQTT Push is disabled"
fi


# Now start the original entrypoint or command
exec /app/orb sensor
