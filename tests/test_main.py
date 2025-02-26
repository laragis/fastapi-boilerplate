from starlette.testclient import TestClient


def test_index(testclient: TestClient):
    r = testclient.get("/")
    assert r.status_code == 200