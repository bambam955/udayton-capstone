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

export const adminResourceDefinitions = [
  resource({
    name: 'admin_roles',
    path: 'admin-roles',
    table: 'admin_roles',
    idColumn: 'role_id',
    fields: {
      role_id: stringField({ filterable: true }),
      name: stringField({ filterable: true, createable: true, updateable: true }),
      description: stringField({ createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: adminOnly(),
    getAccess: adminOnly(),
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'admins',
    path: 'admins',
    table: 'admins',
    idColumn: 'admin_id',
    fields: {
      admin_id: stringField({ filterable: true }),
      email: stringField({ filterable: true, createable: true, updateable: true }),
      full_name: stringField({ createable: true, updateable: true }),
      password_hash: stringField({ readable: false, createable: true, updateable: true }),
      is_active: booleanField({ filterable: true, createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true }),
      updated_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: adminOnly(),
    getAccess: adminOnly(),
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'admin_profiles',
    path: 'admin-profiles',
    table: 'admin_profiles',
    idColumn: 'admin_profile_id',
    fields: {
      admin_profile_id: stringField({ filterable: true }),
      admin_id: stringField({ filterable: true, createable: true, requiredOnCreate: true }),
      role_id: stringField({ filterable: true, createable: true, updateable: true }),
      title: stringField({ createable: true, updateable: true }),
      phone: stringField({ createable: true, updateable: true }),
      last_login_at: timestampField({ createable: true, updateable: true }),
      updated_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: adminOnly(),
    getAccess: adminOnly(),
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'admin_sessions',
    path: 'admin-sessions',
    table: 'admin_sessions',
    idColumn: 'session_id',
    fields: {
      ...sessionFields,
      admin_id: stringField({ filterable: true, createable: true })
    },
    listAccess: adminOnly(),
    getAccess: adminOnly(),
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'integration_health',
    path: 'integration-health',
    table: 'integration_health',
    idColumn: 'health_id',
    fields: {
      health_id: stringField({ filterable: true }),
      integration: stringField({ filterable: true, createable: true, updateable: true }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
      last_checked_at: timestampField({ createable: true, updateable: true }),
      error: stringField({ createable: true, updateable: true }),
      details_json: stringField({ createable: true, updateable: true })
    },
    // Admins use this surface to monitor Mockoon/retailer integration readiness.
    listAccess: adminOnly(),
    getAccess: adminOnly(),
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  })
];
