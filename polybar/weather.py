#!/usr/bin/env python3
#
# Outputs a weather icon and temperature in Celsius.

import json
import os
import sys
import urllib.request

_OPENWEATHERMAP_KEY = os.getenv('OPENWEATHERMAP_API_KEY', '')
_MOZILLA_KEY = 'geoclue'

_ICONS = {
    'bars': '',
    'bolt': '',
    'cloud': '',
    'droplet': '',
    'smoke': '',
    'snowflake': '',
    'sun': '',
    'tornado': '',
    'unknown': '',
}
_WEATHER_TO_ICONS = {
    'Clear': 'sun',
    'Clouds': 'cloud',
    'Drizzle': 'droplet',
    'Dust': 'bars',
    'Fog': 'bars',
    'Haze': 'bars',
    'Mist': 'bars',
    'Rain': 'droplet',
    'Smoke': 'smoke',
    'Snow': 'snowflake',
    'Thunderstorm': 'bolt',
    'Tornado': 'tornado',
}


def fetch_lat_lon():
    raw = urllib.request.urlopen(
        f'https://location.services.mozilla.com/v1/geolocate?key={_MOZILLA_KEY}'
    ).read().decode()
    loc = json.loads(raw)['location']
    return loc['lat'], loc['lng']


def fetch_weather_and_temp(lat, lon):
    raw = urllib.request.urlopen(
        f'https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&APPID={_OPENWEATHERMAP_KEY}'
    ).read().decode()
    response = json.loads(raw)
    weather = response['weather'][0]['main']  # first (only) element is current
    temp_in_kelvin = response['main']['temp']
    temp = round(float(temp_in_kelvin) - 272.15)
    return weather, temp


try:
    lat, lon = fetch_lat_lon()
    weather, temp = fetch_weather_and_temp(lat, lon)
except Exception:
    # Don't print anything on failure, we don't want to mess up the status bar.
    sys.exit(0)

icon = _ICONS[_WEATHER_TO_ICONS.get(weather, 'unknown')]

print('%s %s, %i°C' % (icon, weather, temp))
