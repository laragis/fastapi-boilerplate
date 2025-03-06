
from shapely import Geometry, Polygon
from app.models import geofencing_models
from app.services import geofencing_services

def test_create_area_from_radius():
    # Given
    lon = 105.7488398
    lat = 9.8643837
    radius = 15

    # When
    result = geofencing_services.create_area_from_radius(lon, lat, radius)

    # Then
    assert isinstance(result, Geometry)
    assert result.is_valid
    assert result.area > 0


def test_create_area_from_geom():
    # Given
    coordinates = [
        [
            [105.7489745472926, 9.8643837],
            [105.74897195816115, 9.864357800746198],
            [105.7489642902657, 9.864332896784274],
            [105.74895183827914, 9.864309945159855],
            [105.74893508072434, 9.864289827891483],
            [105.74891466158475, 9.86427331807508],
            [105.74889136555642, 9.86426105017422],
            [105.74886608789271, 9.864253495637943],
            [105.74883979999998, 9.864250944783173],
            [105.74881351210726, 9.864253495637943],
            [105.74878823444355, 9.86426105017422],
            [105.74876493841522, 9.86427331807508],
            [105.74874451927563, 9.864289827891483],
            [105.74872776172083, 9.864309945159855],
            [105.74871530973427, 9.864332896784274],
            [105.74870764183882, 9.864357800746198],
            [105.74870505270736, 9.8643837],
            [105.74870764183882, 9.864409599251765],
            [105.74871530973427, 9.864434503207889],
            [105.74872776172083, 9.864457454823633],
            [105.74874451927563, 9.864477572081773],
            [105.74876493841522, 9.864494081887939],
            [105.74878823444355, 9.864506349780124],
            [105.74881351210726, 9.864513904310602],
            [105.74883979999998, 9.864516455163338],
            [105.74886608789271, 9.864513904310602],
            [105.74889136555642, 9.864506349780124],
            [105.74891466158475, 9.864494081887939],
            [105.74893508072434, 9.864477572081773],
            [105.74895183827914, 9.864457454823633],
            [105.7489642902657, 9.864434503207889],
            [105.74897195816115, 9.864409599251765],
            [105.7489745472926, 9.8643837]
        ]
    ]
    polygon = Polygon(coordinates[0])
    geom = geofencing_models.PolygonFeatureModel.model_construct(geometry=polygon)

    # When
    result = geofencing_services.create_area_from_geom(geom)

    # Then
    assert isinstance(result, Geometry)
    assert result.is_valid
    assert result.area > 0


def test_check_points_inside_area_boundary():
    # Given
    points = [
        geofencing_models.GeofencePoint(id="1", lon=105.7487405, lat=9.8644254),
        geofencing_models.GeofencePoint(id="2", lon=105.7491342, lat=9.8642686),
        geofencing_models.GeofencePoint(id="3", lon=105.7489267, lat=9.8645398)
    ]
    area = geofencing_services.create_area_from_radius(105.7488398, 9.8643837, 15)

    # When
    result = geofencing_services.check_points_inside_area(points, area)

    # Then
    assert result == [
        {"id": "1", "is_inside": True},
        {"id": "2", "is_inside": False},
        {"id": "3", "is_inside": False},
    ]