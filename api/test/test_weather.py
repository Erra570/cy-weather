from fastapi.testclient import TestClient
from main import app
import pytest
from src.resources.weather_resource import router
import asyncio
from fastapi import FastAPI
from unittest.mock import AsyncMock, patch
import httpx


app = FastAPI()
app.include_router(router)
client = TestClient(app)
def test_debug_routes():
    paths = sorted([r.path for r in app.routes])
    print(paths)
    assert True

@pytest.mark.asyncio
@patch("src.resources.weather_resource.weather_service")
async def test_get_current_weather_success(mock_weather_service):
    mock_response = {
        "city": "Paris",
        "country": "FR",
        "timestamp": "2026-01-14T12:00:00",
        "weather": {
            "temperature": 20.0,
            "feels_like": 20.0,
            "humidity": 65,
            "pressure": 10.0,
            "wind_speed": 10.0,
            "description": "Ciel dégagé",
            "icon":"icon"
        }
    }
    mock_weather_service.get_current_weather = AsyncMock(return_value=mock_response)

    response = client.get("/weather/current", params={"city":"Paris"})

    assert response.status_code == 200
    assert response.json() == mock_response


@pytest.mark.asyncio
@patch("src.resources.weather_resource.weather_service")
async def test_get_current_weather_city_not_found(mock_weather_service):
    mock_weather_service.get_current_weather = AsyncMock(
        side_effect=httpx.HTTPStatusError(
            message="Ville non trouvée",
            request=httpx.Request("GET", "https://api.example.com/weather"),
            response=httpx.Response(404, request=httpx.Request("GET", "https://api.example.com/weather")),
        )
    )

    response = client.get("/weather/current?city=VilleInconnue")

    assert response.status_code == 404
    assert "Ville 'VilleInconnue' non trouvée" in response.json()["detail"]
