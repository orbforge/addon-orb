#!/bin/sh

printenv

echo "Starting MQTT publishing script..."
date

# Start MQTT publishing in the background
/app/mqtt.sh &

# Now start the original entrypoint or command
exec /app/orb sensor
