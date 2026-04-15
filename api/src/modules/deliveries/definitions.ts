import {
  adminOnly,
  decimalField,
  integerField,
  resource,
  stringField,
  timestampField
} from '../shared/resource-core/definition-helpers.js';

export const deliveryResourceDefinitions = [
  resource({
    name: 'delivery_assignments',
    path: 'delivery-assignments',
    table: 'delivery_assignments',
    idColumn: 'delivery_id',
    fields: {
      delivery_id: stringField({ filterable: true }),
      order_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      driver_id: stringField({ filterable: true, createable: true, updateable: true }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
      pickup_location: stringField({ createable: true, updateable: true }),
      assigned_at: timestampField({ createable: true, updateable: true }),
      picked_up_at: timestampField({ createable: true, updateable: true }),
      delivered_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      customer: {
        // Customers can read only deliveries tied to their own orders.
        scope: {
          kind: 'related',
          table: 'orders',
          localColumn: 'order_id',
          relatedColumn: 'order_id',
          ownerColumn: 'customer_id'
        }
      },
      driver: {
        // Drivers can read only deliveries explicitly assigned to them.
        scope: {
          kind: 'direct',
          column: 'driver_id'
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
    name: 'delivery_offers',
    path: 'delivery-offers',
    table: 'delivery_offers',
    idColumn: 'offer_id',
    fields: {
      offer_id: stringField({ filterable: true }),
      order_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      delivery_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
      offered_at: timestampField({ createable: true, updateable: true }),
      responded_at: timestampField({ createable: true, updateable: true }),
      expires_in_sec: integerField({ createable: true, updateable: true }),
      decline_reason: stringField({ createable: true, updateable: true })
    },
    // Shared offers are system-owned dispatch records; the driver app reads
    // them through mobile bootstrap instead of raw CRUD routes.
    listAccess: adminOnly(),
    getAccess: adminOnly(),
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'delivery_proof',
    path: 'delivery-proof',
    table: 'delivery_proof',
    idColumn: 'proof_id',
    fields: {
      proof_id: stringField({ filterable: true }),
      delivery_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      proof_type: stringField({ filterable: true, createable: true, updateable: true }),
      proof_url: stringField({ createable: true, updateable: true }),
      metadata_json: stringField({ createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'related',
          table: 'delivery_assignments',
          localColumn: 'delivery_id',
          relatedColumn: 'delivery_id',
          ownerColumn: 'driver_id'
        }
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'related',
          table: 'delivery_assignments',
          localColumn: 'delivery_id',
          relatedColumn: 'delivery_id',
          ownerColumn: 'driver_id'
        }
      }
    },
    createAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'related',
          table: 'delivery_assignments',
          localColumn: 'delivery_id',
          relatedColumn: 'delivery_id',
          ownerColumn: 'driver_id'
        },
        writeColumns: ['delivery_id', 'proof_type', 'proof_url', 'metadata_json']
      }
    },
    updateAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'related',
          table: 'delivery_assignments',
          localColumn: 'delivery_id',
          relatedColumn: 'delivery_id',
          ownerColumn: 'driver_id'
        },
        writeColumns: ['proof_type', 'proof_url', 'metadata_json']
      }
    },
    deleteAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'related',
          table: 'delivery_assignments',
          localColumn: 'delivery_id',
          relatedColumn: 'delivery_id',
          ownerColumn: 'driver_id'
        }
      }
    }
  }),
  resource({
    name: 'delivery_status_events',
    path: 'delivery-status-events',
    table: 'delivery_status_events',
    idColumn: 'event_id',
    fields: {
      event_id: stringField({ filterable: true }),
      delivery_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      driver_id: stringField({ filterable: true, createable: true, updateable: true }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
      event_time: timestampField({ createable: true, updateable: true }),
      note: stringField({ createable: true, updateable: true }),
      lat: decimalField({ createable: true, updateable: true }),
      lng: decimalField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      driver: {
        // Drivers read status events only for deliveries they own through the
        // assignment table.
        scope: {
          kind: 'related',
          table: 'delivery_assignments',
          localColumn: 'delivery_id',
          relatedColumn: 'delivery_id',
          ownerColumn: 'driver_id'
        }
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: {
          kind: 'related',
          table: 'delivery_assignments',
          localColumn: 'delivery_id',
          relatedColumn: 'delivery_id',
          ownerColumn: 'driver_id'
        }
      }
    },
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  })
];
