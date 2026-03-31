import {
  adminOnly,
  booleanField,
  decimalField,
  integerField,
  resource,
  stringField,
  timestampField
} from '../shared/resource-core/definition-helpers.js';

export const retailerResourceDefinitions = [
  resource({
    name: 'retailers',
    path: 'retailers',
    table: 'retailers',
    idColumn: 'retailer_id',
    fields: {
      retailer_id: stringField({ filterable: true }),
      name: stringField({ filterable: true, createable: true, updateable: true }),
      website: stringField({ createable: true, updateable: true }),
      is_enabled: booleanField({ filterable: true, createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      customer: {},
      driver: {}
    },
    getAccess: {
      admin: {},
      customer: {},
      driver: {}
    },
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'retailer_accounts',
    path: 'retailer-accounts',
    table: 'retailer_accounts',
    idColumn: 'retailer_account_id',
    fields: {
      retailer_account_id: stringField({ filterable: true }),
      customer_id: stringField({ filterable: true, createable: true, requiredOnCreate: true }),
      retailer_id: stringField({ filterable: true, createable: true, requiredOnCreate: true }),
      is_connected: booleanField({ filterable: true, createable: true, updateable: true }),
      access_token: stringField({ readable: false, createable: true, updateable: true }),
      refresh_token: stringField({ readable: false, createable: true, updateable: true }),
      token_expires_at: timestampField({ createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true }),
      updated_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'direct',
          column: 'customer_id'
        }
      }
    },
    getAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'direct',
          column: 'customer_id'
        }
      }
    },
    createAccess: {
      admin: {},
      customer: {
        // Customers may only create connection rows for themselves and only for
        // the fields involved in connection state.
        injectPrincipalColumn: 'customer_id',
        writeColumns: ['retailer_id', 'is_connected']
      }
    },
    updateAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'direct',
          column: 'customer_id'
        },
        writeColumns: ['is_connected']
      }
    },
    deleteAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'direct',
          column: 'customer_id'
        }
      }
    }
  }),
  resource({
    name: 'product_categories',
    path: 'product-categories',
    table: 'product_categories',
    idColumn: 'category_id',
    fields: {
      category_id: stringField({ filterable: true }),
      retailer_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      name: stringField({ filterable: true, createable: true, updateable: true }),
      external_category_id: stringField({ createable: true, updateable: true }),
      updated_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      // Product taxonomy is read by both mobile apps when building browse and
      // delivery context, while writes stay admin-only.
      admin: {},
      customer: {},
      driver: {}
    },
    getAccess: {
      admin: {},
      customer: {},
      driver: {}
    },
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'retailer_locations',
    path: 'retailer-locations',
    table: 'retailer_locations',
    idColumn: 'retailer_location_id',
    fields: {
      retailer_location_id: stringField({ filterable: true }),
      retailer_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      external_store_id: stringField({ filterable: true, createable: true, updateable: true }),
      name: stringField({ filterable: true, createable: true, updateable: true }),
      address_line1: stringField({ createable: true, updateable: true }),
      address_line2: stringField({ createable: true, updateable: true }),
      city: stringField({ filterable: true, createable: true, updateable: true }),
      state: stringField({ filterable: true, createable: true, updateable: true }),
      postal_code: stringField({ createable: true, updateable: true }),
      country: stringField({ createable: true, updateable: true }),
      lat: decimalField({ createable: true, updateable: true }),
      lng: decimalField({ createable: true, updateable: true }),
      is_active: booleanField({ filterable: true, createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true }),
      updated_at: timestampField({ createable: true, updateable: true })
    },
    // Both mobile apps read from the partner-location catalog, while admin owns edits.
    listAccess: {
      admin: {},
      customer: {},
      driver: {}
    },
    getAccess: {
      admin: {},
      customer: {},
      driver: {}
    },
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'products',
    path: 'products',
    table: 'products',
    idColumn: 'product_id',
    fields: {
      product_id: stringField({ filterable: true }),
      retailer_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      category_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      external_sku: stringField({ filterable: true, createable: true, updateable: true }),
      name: stringField({ filterable: true, createable: true, updateable: true }),
      description: stringField({ createable: true, updateable: true }),
      image_url: stringField({ createable: true, updateable: true }),
      unit_price_cents: integerField({ filterable: true, createable: true, updateable: true }),
      currency: stringField({ filterable: true, createable: true, updateable: true }),
      is_available: booleanField({ filterable: true, createable: true, updateable: true }),
      updated_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      customer: {},
      driver: {}
    },
    getAccess: {
      admin: {},
      customer: {},
      driver: {}
    },
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'service_regions',
    path: 'service-regions',
    table: 'service_regions',
    idColumn: 'region_id',
    fields: {
      region_id: stringField({ filterable: true }),
      name: stringField({ filterable: true, createable: true, updateable: true }),
      state: stringField({ filterable: true, createable: true, updateable: true }),
      geofence_json: stringField({ createable: true, updateable: true }),
      is_active: booleanField({ filterable: true, createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true })
    },
    // Region lookup supports the customer location-selection step in the MVP flow.
    listAccess: {
      admin: {},
      customer: {},
      driver: {}
    },
    getAccess: {
      admin: {},
      customer: {},
      driver: {}
    },
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  })
];
