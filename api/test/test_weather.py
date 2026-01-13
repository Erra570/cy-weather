from fastapi.testclient import TestClient
from main import app

client = TestClient(app)
def test_debug_routes():
    paths = sorted([r.path for r in app.routes])
    print(paths)
    assert True

def test_get_current_weather_valid_city():
    response = client.get(
        "/weather/current",
        params={"city": "Paris"},
    )

    assert response.status_code == 200


def test_get_current_weather_invalid_city():
    response = client.get(
        "/weather/current",
        params={"city": "Bourg Palette"},
    )

    assert response.status_code == 404
