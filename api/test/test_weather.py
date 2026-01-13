from fastapi.testclient import TestClient
import sys
sys.path.append("/home/cytech/Desktop/DevMLOps/cy-weather/api") 
from main import app
client = TestClient(app)


def test_get_current_weather_valid_city():
    response = client.get(
        "/weather/current",
        params={"city": "Paris", "country_code": "FR"}
    )

    assert response.status_code == 200
    body = response.json()
    assert "temperature" in body
    assert "humidity" in body


def test_get_current_weather_invalid_city():
    response = client.get(
        "/weather/current",
        params={"city": "VilleQuiNExistePas123"}
    )

    assert response.status_code == 404
