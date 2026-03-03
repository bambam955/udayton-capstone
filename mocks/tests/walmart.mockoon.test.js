const fs = require('fs')
const path = require('path')

function load(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'))
}

const walmartDir = path.resolve(__dirname, '..', 'src', 'walmart')
const files = {
  items: path.join(walmartDir, 'items.mockoon.json'),
  orders: path.join(walmartDir, 'orders.mockoon.json'),
  price: path.join(walmartDir, 'price.mockoon.json'),
}

const expected = {
  items: [
    ['get', 'v3/items/feeds'],
    ['post', 'v3/items/feeds'],
    ['get', 'v3/items/feeds/:feedId'],
  ],
  orders: [
    ['get', 'v3/orders'],
    ['get', 'v3/orders/released'],
    ['get', 'v3/orders/released:nextCursor'],
    ['get', 'v3/orders/:purchaseOrderId'],
    ['post', 'v3/orders/:purchaseOrderId/acknowledge'],
    ['post', 'v3/orders/:purchaseOrderId/cancel'],
    ['post', 'v3/orders/:purchaseOrderId/refund'],
    ['post', 'v3/orders/:purchaseOrderId/shipping'],
    ['get', 'v3/orders:nextCursor'],
  ],
  price: [
    ['post', 'v3/price/cppreference'],
    ['post', 'v3/price/feeds'],
    ['put', 'v3/price'],
  ],
}

describe('walmart mock definitions', () => {
  test('files exist and are valid json', () => {
    Object.values(files).forEach((f) => {
      expect(fs.existsSync(f)).toBe(true)
      expect(() => load(f)).not.toThrow()
    })
  })

  test('routes match expected method/path contract', () => {
    Object.entries(files).forEach(([domain, file]) => {
      const env = load(file)
      const actual = env.routes.map((r) => [
        String(r.method).toLowerCase(),
        r.endpoint,
      ])
      expect(actual).toEqual(expected[domain])
    })
  })

  test('all walmart routes require x-walmart-api-key', () => {
    Object.values(files).forEach((file) => {
      const env = load(file)
      env.routes.forEach((route) => {
        const first = route.responses[0]
        expect(Array.isArray(first.rules)).toBe(true)
        expect(
          first.rules.some(
            (rule) =>
              rule.target === 'header' &&
              rule.modifier === 'x-walmart-api-key' &&
              rule.value === 'wmrt-dev-key'
          )
        ).toBe(true)
      })
    })
  })
})
