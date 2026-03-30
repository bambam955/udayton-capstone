import {
  adminOnly,
  integerField,
  resource,
  stringField,
  timestampField
} from '../shared/resource-core/definition-helpers.js';

export const paymentResourceDefinitions = [
  resource({
    name: 'payments',
    path: 'payments',
    table: 'payments',
    idColumn: 'payment_id',
    fields: {
      payment_id: stringField({ filterable: true }),
      order_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      customer_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      provider: stringField({ filterable: true, createable: true, updateable: true }),
      provider_ref: stringField({ createable: true, updateable: true }),
      amount_cents: integerField({ createable: true, updateable: true }),
      currency: stringField({ createable: true, updateable: true }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
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
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'refunds',
    path: 'refunds',
    table: 'refunds',
    idColumn: 'refund_id',
    fields: {
      refund_id: stringField({ filterable: true }),
      payment_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      order_id: stringField({
        filterable: true,
        createable: true,
        updateable: true,
        requiredOnCreate: true
      }),
      amount_cents: integerField({ createable: true, updateable: true }),
      reason: stringField({ createable: true, updateable: true }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
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
      }
    },
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  })
];
