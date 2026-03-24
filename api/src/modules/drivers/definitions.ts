import type { ResourceFieldDefinition } from '../shared/resource-core/types.js';
import {
  adminOnly,
  booleanField,
  decimalField,
  integerField,
  resource,
  stringField,
  timestampField
} from '../shared/resource-core/definition-helpers.js';

const sessionFields = {
  session_id: stringField({ filterable: true }),
  access_token: stringField({ readable: false, createable: true, updateable: true }),
  expires_at: timestampField({ createable: true, updateable: true }),
  created_at: timestampField({ createable: true, updateable: true })
} satisfies Record<string, ResourceFieldDefinition>;

export const driverResourceDefinitions = [
  resource({
    name: 'drivers',
    path: 'drivers',
    table: 'drivers',
    idColumn: 'driver_id',
    fields: {
      driver_id: stringField({ filterable: true }),
      email: stringField({ filterable: true, createable: true, updateable: true }),
      phone: stringField({ createable: true, updateable: true }),
      full_name: stringField({ createable: true, updateable: true }),
      password_hash: stringField({ readable: false, createable: true, updateable: true }),
      is_active: booleanField({ filterable: true, createable: true, updateable: true }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true }),
      updated_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: adminOnly(),
    getAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'direct',
          column: 'driver_id'
        }
      }
    },
    createAccess: adminOnly(),
    updateAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'direct',
          column: 'driver_id'
        },
        writeColumns: ['phone', 'full_name', 'status']
      }
    },
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'driver_sessions',
    path: 'driver-sessions',
    table: 'driver_sessions',
    idColumn: 'session_id',
    fields: {
      ...sessionFields,
      driver_id: stringField({ filterable: true, createable: true })
    },
    listAccess: adminOnly(),
    getAccess: adminOnly(),
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'driver_locations',
    path: 'driver-locations',
    table: 'driver_locations',
    idColumn: 'location_id',
    fields: {
      location_id: stringField({ filterable: true }),
      driver_id: stringField({ filterable: true, createable: true }),
      lat: decimalField({ createable: true, updateable: true }),
      lng: decimalField({ createable: true, updateable: true }),
      accuracy_m: decimalField({ createable: true, updateable: true }),
      heading: decimalField({ createable: true, updateable: true }),
      speed_mps: decimalField({ createable: true, updateable: true }),
      recorded_at: timestampField({ createable: true, updateable: true }),
      source: stringField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'direct',
          column: 'driver_id'
        }
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'direct',
          column: 'driver_id'
        }
      }
    },
    createAccess: {
      admin: {},
      driver: {
        injectPrincipalColumn: 'driver_id',
        writeColumns: ['lat', 'lng', 'accuracy_m', 'heading', 'speed_mps', 'recorded_at', 'source']
      }
    },
    updateAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'direct',
          column: 'driver_id'
        },
        writeColumns: ['lat', 'lng', 'accuracy_m', 'heading', 'speed_mps', 'recorded_at', 'source']
      }
    },
    deleteAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'direct',
          column: 'driver_id'
        }
      }
    }
  }),
  resource({
    name: 'driver_earnings',
    path: 'driver-earnings',
    table: 'driver_earnings',
    idColumn: 'earning_id',
    fields: {
      earning_id: stringField({ filterable: true }),
      driver_id: stringField({ filterable: true, createable: true, updateable: true }),
      delivery_id: stringField({ filterable: true, createable: true, updateable: true }),
      base_pay_cents: integerField({ createable: true, updateable: true }),
      bonus_cents: integerField({ createable: true, updateable: true }),
      tip_cents: integerField({ createable: true, updateable: true }),
      adjustments_cents: integerField({ createable: true, updateable: true }),
      total_pay_cents: integerField({ createable: true, updateable: true }),
      currency: stringField({ createable: true, updateable: true }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'direct',
          column: 'driver_id'
        }
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'direct',
          column: 'driver_id'
        }
      }
    },
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'driver_payouts',
    path: 'driver-payouts',
    table: 'driver_payouts',
    idColumn: 'payout_id',
    fields: {
      payout_id: stringField({ filterable: true }),
      driver_id: stringField({ filterable: true, createable: true, updateable: true }),
      amount_cents: integerField({ createable: true, updateable: true }),
      currency: stringField({ createable: true, updateable: true }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
      provider: stringField({ createable: true, updateable: true }),
      provider_ref: stringField({ createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'direct',
          column: 'driver_id'
        }
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'direct',
          column: 'driver_id'
        }
      }
    },
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  })
];
