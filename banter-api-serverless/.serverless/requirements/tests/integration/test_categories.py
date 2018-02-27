from tests.integration.util import (
    create_client,
)


def test_get():
    client = create_client()
    response = client.Categories.get()
    assert response['categories'] is not None
