import type { ResourceFieldDefinition } from '../shared/resource-core/types.js';
import {
  adminOnly,
  booleanField,
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

// Reused customer ownership scope for customer-owned resource tables.
const customerDirectScope = {
  kind: 'direct' as const,
  column: 'customer_id'
};

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
        scope: customerDirectScope
      }
    },
    createAccess: adminOnly(),
    updateAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope,
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
      customer_id: stringField({ filterable: true, createable: true, requiredOnCreate: true }),
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
        scope: customerDirectScope
      }
    },
    getAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope
      }
    },
    createAccess: {
      admin: {},
      customer: {
        // Customers create their own address rows, so inject the principal ID
        // and only expose the user-editable address fields.
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
        scope: customerDirectScope,
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
        scope: customerDirectScope
      }
    }
  }),
  resource({
    name: 'customer_devices',
    path: 'customer-devices',
    table: 'customer_devices',
    idColumn: 'device_id',
    fields: {
      device_id: stringField({ filterable: true }),
      customer_id: stringField({ filterable: true, createable: true, requiredOnCreate: true }),
      platform: stringField({ createable: true, updateable: true }),
      push_token: stringField({ createable: true, updateable: true }),
      app_version: stringField({ createable: true, updateable: true }),
      last_seen_at: timestampField({ createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope
      }
    },
    getAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope
      }
    },
    createAccess: {
      admin: {},
      customer: {
        injectPrincipalColumn: 'customer_id',
        writeColumns: ['platform', 'push_token', 'app_version', 'last_seen_at']
      }
    },
    updateAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope,
        writeColumns: ['platform', 'push_token', 'app_version', 'last_seen_at']
      }
    },
    deleteAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope
      }
    }
  }),
  resource({
    name: 'carts',
    path: 'carts',
    table: 'carts',
    idColumn: 'cart_id',
    fields: {
      cart_id: stringField({ filterable: true }),
      customer_id: stringField({ filterable: true, createable: true, requiredOnCreate: true }),
      retailer_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      retailer_location_id: stringField({ filterable: true, createable: true, updateable: true }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true }),
      updated_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope
      }
    },
    getAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope
      }
    },
    createAccess: {
      admin: {},
      customer: {
        // Cart ownership is always derived from the authenticated customer.
        injectPrincipalColumn: 'customer_id',
        writeColumns: ['retailer_id', 'retailer_location_id']
      }
    },
    updateAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope,
        writeColumns: ['retailer_id', 'retailer_location_id']
      }
    },
    deleteAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope
      }
    }
  }),
  resource({
    name: 'cart_items',
    path: 'cart-items',
    table: 'cart_items',
    idColumn: 'cart_item_id',
    fields: {
      cart_item_id: stringField({ filterable: true }),
      cart_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      product_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      external_sku: stringField({ filterable: true, createable: true, updateable: true }),
      name_snapshot: stringField({ createable: true, updateable: true }),
      unit_price_cents: integerField({ createable: true, updateable: true }),
      quantity: integerField({ createable: true, updateable: true }),
      substitution_allowed: booleanField({ createable: true, updateable: true }),
      notes: stringField({ createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'related',
          table: 'carts',
          localColumn: 'cart_id',
          relatedColumn: 'cart_id',
          ownerColumn: 'customer_id'
        }
      }
    },
    getAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'related',
          table: 'carts',
          localColumn: 'cart_id',
          relatedColumn: 'cart_id',
          ownerColumn: 'customer_id'
        }
      }
    },
    // Cart item writes stay customer-owned through the parent cart relation so
    // the mobile app can persist cart contents and substitution preferences.
    createAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'related',
          table: 'carts',
          localColumn: 'cart_id',
          relatedColumn: 'cart_id',
          ownerColumn: 'customer_id'
        },
        writeColumns: ['cart_id', 'product_id', 'quantity', 'substitution_allowed', 'notes']
      }
    },
    updateAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'related',
          table: 'carts',
          localColumn: 'cart_id',
          relatedColumn: 'cart_id',
          ownerColumn: 'customer_id'
        },
        writeColumns: ['quantity', 'substitution_allowed', 'notes']
      }
    },
    deleteAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'related',
          table: 'carts',
          localColumn: 'cart_id',
          relatedColumn: 'cart_id',
          ownerColumn: 'customer_id'
        }
      }
    }
  }),
  resource({
    name: 'notifications',
    path: 'notifications',
    table: 'notifications',
    idColumn: 'notification_id',
    fields: {
      notification_id: stringField({ filterable: true }),
      customer_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      type: stringField({ filterable: true, createable: true, updateable: true }),
      title: stringField({ createable: true, updateable: true }),
      body: stringField({ createable: true, updateable: true }),
      deep_link: stringField({ createable: true, updateable: true }),
      is_read: booleanField({ filterable: true, createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true }),
      read_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope
      }
    },
    getAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope
      }
    },
    createAccess: adminOnly(),
    updateAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope,
        writeColumns: ['is_read', 'read_at']
      }
    },
    deleteAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope
      }
    }
  }),
  resource({
    name: 'support_tickets',
    path: 'support-tickets',
    table: 'support_tickets',
    idColumn: 'ticket_id',
    fields: {
      ticket_id: stringField({ filterable: true }),
      customer_id: stringField({ filterable: true, createable: true, requiredOnCreate: true }),
      order_id: stringField({ filterable: true, createable: true, updateable: true }),
      issue_type: stringField({ filterable: true, createable: true, updateable: true }),
      message: stringField({ createable: true, updateable: true }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true }),
      updated_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope
      }
    },
    getAccess: {
      admin: {},
      customer: {
        scope: customerDirectScope
      }
    },
    createAccess: {
      admin: {},
      customer: {
        // Support tickets may be general account issues, but when an order is
        // attached it must belong to the authenticated customer.
        scope: {
          kind: 'related',
          table: 'orders',
          localColumn: 'order_id',
          relatedColumn: 'order_id',
          ownerColumn: 'customer_id'
        },
        injectPrincipalColumn: 'customer_id',
        writeColumns: ['order_id', 'issue_type', 'message']
      }
    },
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
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
