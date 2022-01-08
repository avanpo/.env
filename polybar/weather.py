#!/usr/bin/env python3
#
# Outputs an icon with the weather and temperature in Celsius.
#
# Since it is designed for a status bar, it fails silently without output. This
# way the bar is not populated with an ugly error message.

import json
import os
import sys
import urllib.request

city = os.getenv('OPENWEATHERMAP_LOCATION', '')
api_key = os.getenv('OPENWEATHERMAP_API_KEY', '')

try:
    weather = eval(
        str(
            urllib.request.urlopen(
                'https://api.openweathermap.org/data/2.5/weather?q={}&APPID={}'
                .format(city, api_key)).read())[2:-1])
except Exception:
    sys.exit(0)

currWeather = weather['weather'][0]

main = currWeather['main']

icons = {
    'bars': '',
    'bolt': '',
    'cloud': '',
    'droplet': '',
    'snowflake': '',
    'sun': '',
}

weather_to_icon_map = {
    'Clear': 'sun',
    'Clouds': 'cloud',
    'Snow': 'snowflake',
    'Drizzle': 'droplet',
    'Rain': 'droplet',
    'Mist': 'bars',
    'Haze': 'bars',
    'Thunderstorm': 'bolt',
}

icon = icons[weather_to_icon_map.get(main, 'cloud')]
temp = int(float(weather['main']['temp']) - 272.15)

print('%s %s, %i°C' % (icon, main, temp))
