# Orb

Home Assistant add-on for Orb.

## Overview

This add-on runs an [Orb](https://www.orb.net) sensor in your Home Assistant environment. Doing so allows you to monitor the network responsiveness and reliability of your Home Assistant instance from your mobile device or computer from anywhere in the world. You may choose to receive a push notification on your Android or iOS device any time your Home Assistant instance cannot reach the network or experiences deterioriated connectivity.

## Installation

1. Navigate to the Home Assistant Add-on Store
2. Add this repository URL to your add-on repositories
3. Find the "Orb" add-on in the store
4. Click Install
5. Enable auto-updates.
6. Click Start

## Configuration

The add-on allows configuration of the MQTT push functionality. 
* **Push Scores to MQTT** (default false): Enabling this will have the orb sensor push its status to the Home Assistant MQTT broker
* **MQTT Frequency** (default 5 seconds): This determines how often the orb sensor will push its status, if the functionality is enabled


## Data Storage

The add-on stores its data in `/data/.config/orb` which is the default persistent storage provided by Home Assistant

## Architecture Support

This add-on supports multiple architectures (aarch64, amd64, armv7).

## MQTT Integration
If you have the [MQTT addon](https://www.home-assistant.io/integrations/mqtt/) installed, the Orb addon will automatically detect the endpoint. Configure the Orb sensor device and start pushing the current orb status.

It will expose the following entities under the Orb Sensor device:

- Orb Score (overall)
- Bandwidth Score
- Reliability Score
- Responsiveness Score
- Bandwidth Upload
- Bandwidth Download
- Lag
- Packet Loss
