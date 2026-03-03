# Retailer Mock APIs (Mockoon)

This directory contains two retailer mock environments powered by Mockoon:

- Walmart mock at `http://localhost:4010`
- Target mock at `http://localhost:4020`

Source files are organized by retailer and API domain:

- `mocks/src/walmart/items.mockoon.json`
- `mocks/src/walmart/orders.mockoon.json`
- `mocks/src/walmart/price.mockoon.json`
- `mocks/src/target/target.mockoon.json`

Runtime services are defined in `mocks/docker-compose.yml` and imported by the root `docker-compose.yml`.

Both mocks require API key headers.

## Auth Headers

- Walmart: `x-walmart-api-key: wmrt-dev-key`
- Target: `x-target-api-key: tgt-dev-key`

If the header is missing or invalid, endpoints return `401`.

## Endpoints

### Walmart

- `GET /v3/items/feeds`
- `POST /v3/items/feeds`
- `GET /v3/items/feeds/{feedId}`
- `GET /v3/orders`
- `GET /v3/orders/released`
- `GET /v3/orders/released:nextCursor`
- `GET /v3/orders/{purchaseOrderId}`
- `POST /v3/orders/{purchaseOrderId}/acknowledge`
- `POST /v3/orders/{purchaseOrderId}/cancel`
- `POST /v3/orders/{purchaseOrderId}/refund`
- `POST /v3/orders/{purchaseOrderId}/shipping`
- `GET /v3/orders:nextCursor`
- `POST /v3/price/cppreference`
- `POST /v3/price/feeds`
- `PUT /v3/price`

### Target

- `GET /partner/v1/inventory?tcin=<optional>&store_id=<optional>`
- `POST /partner/v1/orders`
- `GET /partner/v1/orders/{orderNumber}/status`

## Behavior Notes

- Contracts intentionally differ between Walmart and Target to support adapter development.
- Walmart routes are merged from official Mockoon Walmart Item, Order, and Price sample APIs.

## Curl Smoke Tests

```bash
# Walmart item feeds (authorized)
curl -s -H 'x-walmart-api-key: wmrt-dev-key' \
  'http://localhost:4010/v3/items/feeds'

# Walmart unauthorized
curl -i -s 'http://localhost:4010/v3/orders'

# Walmart pricing feed update
curl -s -X POST \
  -H 'Content-Type: application/json' \
  -H 'x-walmart-api-key: wmrt-dev-key' \
  -d '{}' \
  'http://localhost:4010/v3/price/feeds'

# Target order create
curl -s -X POST \
  -H 'Content-Type: application/json' \
  -H 'x-target-api-key: tgt-dev-key' \
  -d '{"buyer":{"name":"BizRush"},"items":[{"tcin":"10000001","qty":2}]}' \
  'http://localhost:4020/partner/v1/orders'

# Target order status
curl -s -H 'x-target-api-key: tgt-dev-key' \
  'http://localhost:4020/partner/v1/orders/TGT-1234/status'
```
