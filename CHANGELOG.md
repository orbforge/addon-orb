# Changelog

# 1.3.9
- Protection against missing values, for example if the speed tests are turned off.

# 1.3.6
- Optimization: start up time to measurement
- Bug fixes and optimizations
- Support manually configuring the MQTT push to HA via environment variables or optional configuration options

# 1.3.3
- Add state_class: measurement to have long term statistics. Thanks @tronikos
- Remove high packet loss proportion from MQTT script, since it's no longer available in the orb summary and was causing errors inside Home Assistant
- Improved Router Lag measurement
- Bug fixes and optimizations

# 1.3.1
- Fix potential disconnected startup failure cases
- Fix rare latency measurement beyond timeout
- Bug fixes and optimizations
- Local Analytics: https://orb.net/blog/introducing-local-api

# 1.3.0
- Bug fixes and optimizations
- Support for Orb app 1.3 features: https://orb.net/blog/whats-new-in-orb-1.3

# 1.2.2
- Bug fixes and optimizations

# 1.2.1
- Bug: Fixed a bug where lag would spike incorrectly at launch in some edge cases
- Minor bug fixes and optimizations

# 1.2.0
- Scoring improvements: Reliability and Speed will affect your overall Orb Score a bit differently than before.
    - Reliability will only impact your score in cases of outages or disruptions, and we now include the most recent speed test even if it happened before the time period you are viewing. You may notice your score is a bit lower than before, but it is more representative of your actual Internet experience.
- Support for configurable speed testing
- Support reporting time-to-first-byte and dns resolve time in apps
- Enhancement: improved accuracy of responsiveness measurements
- Bug fixes and optimizations (as always).

# 1.1.1
- Pinger/Packet loss bug fixes

# 1.1.0
- Cross-Verified Responsiveness measurement - uses multiple independent sources to improve accuracy and catch inconsistencies
- New Responsiveness measurement protocol support enables more accurate and robust measurement that is more aligned with real internet experience
- Refined packet loss detection reduces noise and more accurately indicates connection issues

# 1.0.9
- Redefine orb_score in orb summary response as the most recent populated timeframe of each component (Responsiveness, Reliability, and Speed)

# 1.0.8
- Nothing Home Assistant specific

# 1.0.7
- Bug: fixed a bug causing a potential crash edge case

# 1.0.6
- Nothing Home Assistant specific

# 1.0.5
- Nothing Home Assistant specific

## 1.0.4
- Nothing Home Assistant specific

## 1.0.3
- Nothing Home Assistant specific

## 1.0.2
- Improves core roundtrip measurement to improve measurement quality in diverse network conditions, for example, in-flight Wi-Fi.
- Optimizations and bug fixes
- DNS query optimization

## 1.0.1
- Improved MQTT functionality

## 1.0.0
- Service discovery improvements (override host name)
- Change for failed ping resends

## 0.12.38
- Port 5353 bug fix
- Device discovery improvement
- Orb link error message improvement

## 0.12.24
- Initial release
