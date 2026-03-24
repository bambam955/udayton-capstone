import {
  adminOnly,
  integerField,
  resource,
  stringField,
  timestampField
} from '../shared/resource-core/definition-helpers.js';

export const orderResourceDefinitions = [
  resource({
    name: 'orders',
    path: 'orders',
    table: 'orders',
    idColumn: 'order_id',
    fields: {
      order_id: stringField({ filterable: true }),
      customer_id: stringField({ filterable: true, createable: true }),
      retailer_id: stringField({ filterable: true, createable: true, updateable: true }),
      address_id: stringField({ filterable: true, createable: true, updateable: true }),
      external_order_id: stringField({ filterable: true, createable: true, updateable: true }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
      placed_at: timestampField({ createable: true, updateable: true }),
      subtotal_cents: integerField({ createable: true, updateable: true }),
      fees_cents: integerField({ createable: true, updateable: true }),
      tip_cents: integerField({ createable: true, updateable: true }),
      discount_cents: integerField({ createable: true, updateable: true }),
      total_cents: integerField({ createable: true, updateable: true }),
      currency: stringField({ createable: true, updateable: true }),
      delivery_notes: stringField({ createable: true, updateable: true }),
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
      },
      driver: {
        scope: {
          kind: 'related',
          table: 'delivery_assignments',
          localColumn: 'order_id',
          relatedColumn: 'order_id',
          ownerColumn: 'driver_id'
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
      },
      driver: {
        scope: {
          kind: 'related',
          table: 'delivery_assignments',
          localColumn: 'order_id',
          relatedColumn: 'order_id',
          ownerColumn: 'driver_id'
        }
      }
    },
    createAccess: {
      admin: {},
      customer: {
        injectPrincipalColumn: 'customer_id',
        writeColumns: [
          'retailer_id',
          'address_id',
          'external_order_id',
          'status',
          'placed_at',
          'subtotal_cents',
          'fees_cents',
          'tip_cents',
          'discount_cents',
          'total_cents',
          'currency',
          'delivery_notes'
        ]
      }
    },
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'order_items',
    path: 'order-items',
    table: 'order_items',
    idColumn: 'order_item_id',
    fields: {
      order_item_id: stringField({ filterable: true }),
      order_id: stringField({ filterable: true, createable: true, updateable: true }),
      product_id: stringField({ filterable: true, createable: true, updateable: true }),
      external_sku: stringField({ filterable: true, createable: true, updateable: true }),
      name_snapshot: stringField({ createable: true, updateable: true }),
      unit_price_cents: integerField({ createable: true, updateable: true }),
      quantity: integerField({ createable: true, updateable: true }),
      substituted_for_sku: stringField({ createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'related',
          table: 'orders',
          localColumn: 'order_id',
          relatedColumn: 'order_id',
          ownerColumn: 'customer_id'
        }
      },
      driver: {
        scope: {
          kind: 'related',
          table: 'delivery_assignments',
          localColumn: 'order_id',
          relatedColumn: 'order_id',
          ownerColumn: 'driver_id'
        }
      }
    },
    getAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'related',
          table: 'orders',
          localColumn: 'order_id',
          relatedColumn: 'order_id',
          ownerColumn: 'customer_id'
        }
      },
      driver: {
        scope: {
          kind: 'related',
          table: 'delivery_assignments',
          localColumn: 'order_id',
          relatedColumn: 'order_id',
          ownerColumn: 'driver_id'
        }
      }
    },
    createAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'related',
          table: 'orders',
          localColumn: 'order_id',
          relatedColumn: 'order_id',
          ownerColumn: 'customer_id'
        },
        writeColumns: [
          'order_id',
          'product_id',
          'external_sku',
          'name_snapshot',
          'unit_price_cents',
          'quantity',
          'substituted_for_sku'
        ]
      }
    },
    updateAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'related',
          table: 'orders',
          localColumn: 'order_id',
          relatedColumn: 'order_id',
          ownerColumn: 'customer_id'
        },
        writeColumns: [
          'product_id',
          'external_sku',
          'name_snapshot',
          'unit_price_cents',
          'quantity',
          'substituted_for_sku'
        ]
      }
    },
    deleteAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'related',
          table: 'orders',
          localColumn: 'order_id',
          relatedColumn: 'order_id',
          ownerColumn: 'customer_id'
        }
      }
    }
  }),
  resource({
    name: 'order_status_history',
    path: 'order-status-history',
    table: 'order_status_history',
    idColumn: 'order_status_history_id',
    fields: {
      order_status_history_id: stringField({ filterable: true }),
      order_id: stringField({ filterable: true, createable: true, updateable: true }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
      status_time: timestampField({ createable: true, updateable: true }),
      note: stringField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'related',
          table: 'orders',
          localColumn: 'order_id',
          relatedColumn: 'order_id',
          ownerColumn: 'customer_id'
        }
      },
      driver: {
        scope: {
          kind: 'related',
          table: 'delivery_assignments',
          localColumn: 'order_id',
          relatedColumn: 'order_id',
          ownerColumn: 'driver_id'
        }
      }
    },
    getAccess: {
      admin: {},
      customer: {
        scope: {
          kind: 'related',
          table: 'orders',
          localColumn: 'order_id',
          relatedColumn: 'order_id',
          ownerColumn: 'customer_id'
        }
      },
      driver: {
        scope: {
          kind: 'related',
          table: 'delivery_assignments',
          localColumn: 'order_id',
          relatedColumn: 'order_id',
          ownerColumn: 'driver_id'
        }
      }
    },
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  })
];
