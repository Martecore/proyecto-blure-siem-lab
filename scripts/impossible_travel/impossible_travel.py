import math
import json
from datetime import datetime

EARTH_RADIUS_KM = 6371.0

def haversine_distance(lat1, lon1, lat2, lon2):
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)

    a = (math.sin(delta_phi / 2.0) ** 2 +
         math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2.0) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return EARTH_RADIUS_KM * c

def evaluate_impossible_travel(tx1, tx2, max_speed_kmh=800.0):
    fmt = "%Y-%m-%dT%H:%M:%SZ"
    t1 = datetime.strptime(tx1['timestamp'], fmt)
    t2 = datetime.strptime(tx2['timestamp'], fmt)

    time_diff_seconds = abs((t2 - t1).total_seconds())
    if time_diff_seconds == 0:
        time_diff_seconds = 1
    time_diff_hours = time_diff_seconds / 3600.0

    distance = haversine_distance(tx1['lat'], tx1['lon'], tx2['lat'], tx2['lon'])
    required_speed = distance / time_diff_hours
    is_alert = required_speed > max_speed_kmh

    return {
        "user_id": tx1['user_id'],
        "distance_km": round(distance, 2),
        "time_diff_minutes": round(time_diff_seconds / 60.0, 2),
        "required_speed_kmh": round(required_speed, 2),
        "impossible_travel_alert": is_alert
    }

if __name__ == "__main__":
    tx_A = {"user_id": "USR_89412", "timestamp": "2026-10-15T10:00:00Z", "lat": 40.4168, "lon": -3.7038}
    tx_B = {"user_id": "USR_89412", "timestamp": "2026-10-15T10:15:00Z", "lat": 35.6762, "lon": 139.6503}

    resultado = evaluate_impossible_travel(tx_A, tx_B)
    print(json.dumps(resultado, indent=4))
