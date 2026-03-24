import type { ResourceFieldDefinition } from '../shared/resource-core/types.js';
import {
  adminOnly,
  booleanField,
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

export const customerResourceDefinitions = [
  resource({
    name: 'customers',
    path: 'customers',
    table: 'customers',
    idColumn: 'customer_id',
    fields: {
      customer_id: stringField({ filterable: true }),
      email: stringField({ filterable: true, createable: true, updateable: true }),
      phone: stringField({ createable: true, updateable: true }),
      full_name: stringField({ createable: true, updateable: true }),
      password_hash: stringField({ readable: false, createable: true, updateable: true }),
      is_active: booleanField({ filterable: true, createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true }),
      updated_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: adminOnly(),
    getAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'direct',
          column: 'customer_id'
        }
      }
    },
    createAccess: adminOnly(),
    updateAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'direct',
          column: 'customer_id'
        },
        writeColumns: ['phone', 'full_name']
      }
    },
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'addresses',
    path: 'addresses',
    table: 'addresses',
    idColumn: 'address_id',
    fields: {
      address_id: stringField({ filterable: true }),
      customer_id: stringField({ filterable: true, createable: true }),
      label: stringField({ createable: true, updateable: true }),
      line1: stringField({ createable: true, updateable: true }),
      line2: stringField({ createable: true, updateable: true }),
      city: stringField({ createable: true, updateable: true }),
      state: stringField({ createable: true, updateable: true }),
      postal_code: stringField({ createable: true, updateable: true }),
      country: stringField({ createable: true, updateable: true }),
      instructions: stringField({ createable: true, updateable: true }),
      is_default: booleanField({ filterable: true, createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true })
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
        injectPrincipalColumn: 'customer_id',
        writeColumns: [
          'label',
          'line1',
          'line2',
          'city',
          'state',
          'postal_code',
          'country',
          'instructions',
          'is_default'
        ]
      }
    },
    updateAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'direct',
          column: 'customer_id'
        },
        writeColumns: [
          'label',
          'line1',
          'line2',
          'city',
          'state',
          'postal_code',
          'country',
          'instructions',
          'is_default'
        ]
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
    name: 'customer_sessions',
    path: 'customer-sessions',
    table: 'customer_sessions',
    idColumn: 'session_id',
    fields: {
      ...sessionFields,
      customer_id: stringField({ filterable: true, createable: true })
    },
    listAccess: adminOnly(),
    getAccess: adminOnly(),
    deleteAccess: adminOnly()
  })
];
