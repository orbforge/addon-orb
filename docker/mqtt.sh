#!/bin/sh

AUTH_HEADER="Authorization: Bearer ${SUPERVISOR_TOKEN}"

CONFIG_PATH=/data/options.json
MQTT_PAUSE=$(jq -r '.mqtt_frequency // 5' $CONFIG_PATH)
_MQTT_HOST=$(jq -r '.mqtt_host // empty' $CONFIG_PATH)
# if DEBUG_MODE is set in environment variables, use environment variables, otherwise use config
if [ -n "$DEBUG_MODE" ]; then
  echo "Using DEBUG_MODE from environment variables"
else
  DEBUG_MODE=$(jq -r '.mqtt_debug // false' $CONFIG_PATH)
fi

# if MQTT_HOST is set in environment variables, use environment variables
if [ -n "$MQTT_HOST" ]; then
  echo "Using MQTT configuration from environment variables"
else if [ -n "$_MQTT_HOST" ]; then
  echo "Using MQTT configuration from options.json"
  if [ "$DEBUG_MODE" == "true" ]; then
    echo "MQTT settings from options.json:"
    cat $CONFIG_PATH
  fi
  MQTT_HOST=$_MQTT_HOST
  MQTT_PORT=$(jq -r '.mqtt_port // 1883' $CONFIG_PATH)
  MQTT_USER=$(jq -r '.mqtt_user // empty' $CONFIG_PATH)
  MQTT_PASS=$(jq -r '.mqtt_password // empty' $CONFIG_PATH)
else
  echo "Using Supervisor MQTT configuration"
  MQTT_INFO=$(curl -s -H "$AUTH_HEADER" http://supervisor/services/mqtt)
  if [ "$DEBUG_MODE" == "true" ]; then
    echo "MQTT Info from Supervisor:"
    echo "$MQTT_INFO"
  fi
  MQTT_HOST=$(echo "$MQTT_INFO" | jq -r '.data.host')
  MQTT_PORT=$(echo "$MQTT_INFO" | jq -r '.data.port')
  MQTT_USER=$(echo "$MQTT_INFO" | jq -r '.data.username')
  MQTT_PASS=$(echo "$MQTT_INFO" | jq -r '.data.password')
fi

echo "MQTT Host: $MQTT_HOST"
echo "MQTT Port: $MQTT_PORT"
echo "MQTT User: $MQTT_USER"

if [ -z "$MQTT_HOST" ] || [ -z "$MQTT_PORT" ] || [ -z "$MQTT_USER" ] || [ -z "$MQTT_PASS" ]; then
  echo "Error: Missing MQTT configuration"
  echo "Ensure that the MQTT integration is installed and running. https://www.home-assistant.io/integrations/mqtt/"
  exit 1
fi

if [ "$MQTT_HOST" == "null" ] || [ "$MQTT_PORT" == "null" ] || [ "$MQTT_USER" == "null" ] || [ "$MQTT_PASS" == "null" ]; then
  echo "Error: Missing MQTT configuration"
  echo "Ensure that the MQTT integration is installed and running. https://www.home-assistant.io/integrations/mqtt/"
  exit 1
fi

DISCOVERY_TOPIC_PREFIX="homeassistant/sensor"
STATE_TOPIC="orb_homeassistant/status"

# Publish MQTT Discovery message once (retained)
mapping="
Score|orb_score.display|%
Bandwidth Score|orb_score.components.bandwidth_score.display|%
Bandwidth Upload|orb_score.components.bandwidth_score.components.upload_bandwidth_kbps.value|kbps
Bandwidth Download|orb_score.components.bandwidth_score.components.download_bandwidth_kbps.value|kbps
Reliability Score|orb_score.components.reliability_score.display|%
Lag|orb_score.components.responsiveness_score.components.internet_lag_us.value|us
Responsiveness Score|orb_score.components.responsiveness_score.display|%
"

echo "$mapping" | while IFS='|' read name field unit; do
  # Skip empty lines
  [ -z "$name" ] && continue

  unique_id=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/ /_/g')
  DISCOVERY_TOPIC="${DISCOVERY_TOPIC_PREFIX}/orb_${unique_id}/config"


  payload=$(cat <<EOF
{
  "name": "${name}",
  "state_class": "measurement",
  "state_topic": "${STATE_TOPIC}",
  "unit_of_measurement": "${unit}",
  "value_template": "{{ (value_json.${field}) | round(0) }}",
  "unique_id": "${unique_id}",
  "device": {
    "identifiers": ["orb"],
    "name": "Orb Sensor",
    "manufacturer": "Orb Forge",
    "model": "Orb Agent"
  }
}
EOF
)

  mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" \
    -t "$DISCOVERY_TOPIC" -m "$payload" -r 
done

CLEANUP_ENTITIES="high_packet_loss_proportion packet_loss"
for entity in $CLEANUP_ENTITIES; do
  DISCOVERY_TOPIC="${DISCOVERY_TOPIC_PREFIX}/orb_${entity}/config"
  mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" \
    -t "$DISCOVERY_TOPIC" -n -r
done

# Periodic state updates
while true; do
  # Replace this with your real data source
  ORB_OUTPUT="$(/app/orb summary || echo '{}')"
  #echo "ORB_OUTPUT: $ORB_OUTPUT"

  # Publish Orb Summary to MQTT
  mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASS" \
    -t "$STATE_TOPIC" -m "$ORB_OUTPUT" -r

  sleep "$MQTT_PAUSE"
done
