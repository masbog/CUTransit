# This file compresses bus stop data and also sorts bus stops by name.
# Use http://developer.cumtd.com/api/v2.1/json/GetStops?key={APIkey} to get the bus stop data.
# Then save it as stops.txt and run this file.

import json

f = open('stops.txt', 'r')
s = f.read()
f.close()

def rename_key(o, old_key, new_key):
	if old_key in o:
		o[new_key] = o[old_key]
		del o[old_key]

def delete_key(o, key):
	if key in o:
		del o[key]

o = json.loads(s)
o = {'stops': o['stops']} # remove other keys

for stop in o['stops']:
	rename_key(stop, 'stop_id', 'i')
	rename_key(stop, 'stop_name', 'n')
	rename_key(stop, 'code', 'c')
	rename_key(stop, 'stop_points', 'p')
	if 'p' in stop:
		stop_points = stop['p']
		if len(stop_points) > 0:
			stop_point = stop_points[0]
			rename_key(stop_point, 'stop_lat', 'l')
			rename_key(stop_point, 'stop_lon', 'o')
			delete_key(stop_point, 'stop_id')
			delete_key(stop_point, 'stop_name')
			delete_key(stop_point, 'code')
			stop['p'] = [stop_point]

o['stops'].sort(key=lambda stop: stop['n'])

f = open('stops_compressed.txt', 'w')
f.write(json.dumps(o, separators=(',', ':')))
f.close()