import type { ResourceFieldDefinition } from '../shared/resource-core/types.js';
import {
  adminOnly,
  booleanField,
  dateField,
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

const driverDirectScope = {
  kind: 'direct' as const,
  column: 'driver_id'
};

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
        scope: driverDirectScope
      }
    },
    createAccess: adminOnly(),
    updateAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope,
        writeColumns: ['phone', 'full_name', 'status']
      }
    },
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'driver_profiles',
    path: 'driver-profiles',
    table: 'driver_profiles',
    idColumn: 'driver_profile_id',
    fields: {
      driver_profile_id: stringField({ filterable: true }),
      driver_id: stringField({ filterable: true, createable: true }),
      date_of_birth: dateField({ createable: true, updateable: true }),
      license_number: stringField({ createable: true, updateable: true }),
      license_state: stringField({ createable: true, updateable: true }),
      license_expires_at: timestampField({ createable: true, updateable: true }),
      background_check_status: stringField({
        filterable: true,
        createable: true,
        updateable: true
      }),
      background_check_completed_at: timestampField({ createable: true, updateable: true }),
      updated_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    createAccess: {
      admin: {},
      driver: {
        injectPrincipalColumn: 'driver_id',
        writeColumns: ['date_of_birth', 'license_number', 'license_state', 'license_expires_at']
      }
    },
    updateAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope,
        // Background-check state remains admin-managed while drivers maintain profile data.
        writeColumns: ['date_of_birth', 'license_number', 'license_state', 'license_expires_at']
      }
    },
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'driver_vehicles',
    path: 'driver-vehicles',
    table: 'driver_vehicles',
    idColumn: 'vehicle_id',
    fields: {
      vehicle_id: stringField({ filterable: true }),
      driver_id: stringField({ filterable: true, createable: true }),
      make: stringField({ createable: true, updateable: true }),
      model: stringField({ createable: true, updateable: true }),
      year: integerField({ createable: true, updateable: true }),
      color: stringField({ createable: true, updateable: true }),
      plate_number: stringField({ createable: true, updateable: true }),
      plate_state: stringField({ createable: true, updateable: true }),
      is_primary: booleanField({ filterable: true, createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    createAccess: {
      admin: {},
      driver: {
        injectPrincipalColumn: 'driver_id',
        writeColumns: [
          'make',
          'model',
          'year',
          'color',
          'plate_number',
          'plate_state',
          'is_primary'
        ]
      }
    },
    updateAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope,
        writeColumns: [
          'make',
          'model',
          'year',
          'color',
          'plate_number',
          'plate_state',
          'is_primary'
        ]
      }
    },
    deleteAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    }
  }),
  resource({
    name: 'driver_documents',
    path: 'driver-documents',
    table: 'driver_documents',
    idColumn: 'document_id',
    fields: {
      document_id: stringField({ filterable: true }),
      driver_id: stringField({ filterable: true, createable: true }),
      doc_type: stringField({ filterable: true, createable: true, updateable: true }),
      file_url: stringField({ createable: true, updateable: true }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
      reviewer_note: stringField({ createable: true, updateable: true }),
      expires_at: timestampField({ createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    createAccess: {
      admin: {},
      driver: {
        injectPrincipalColumn: 'driver_id',
        writeColumns: ['doc_type', 'file_url', 'expires_at']
      }
    },
    updateAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope,
        writeColumns: ['doc_type', 'file_url', 'expires_at']
      }
    },
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'driver_availability',
    path: 'driver-availability',
    table: 'driver_availability',
    idColumn: 'availability_id',
    fields: {
      availability_id: stringField({ filterable: true }),
      driver_id: stringField({ filterable: true, createable: true }),
      is_available: booleanField({ filterable: true, createable: true, updateable: true }),
      reason: stringField({ createable: true, updateable: true }),
      started_at: timestampField({ createable: true, updateable: true }),
      ended_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    createAccess: {
      admin: {},
      driver: {
        injectPrincipalColumn: 'driver_id',
        writeColumns: ['is_available', 'reason', 'started_at', 'ended_at']
      }
    },
    updateAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope,
        writeColumns: ['is_available', 'reason', 'started_at', 'ended_at']
      }
    },
    deleteAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    }
  }),
  resource({
    name: 'driver_service_areas',
    path: 'driver-service-areas',
    table: 'driver_service_areas',
    idColumn: 'service_area_id',
    fields: {
      service_area_id: stringField({ filterable: true }),
      driver_id: stringField({ filterable: true, createable: true }),
      label: stringField({ createable: true, updateable: true }),
      city: stringField({ createable: true, updateable: true }),
      state: stringField({ createable: true, updateable: true }),
      postal_code: stringField({ createable: true, updateable: true }),
      geofence_json: stringField({ createable: true, updateable: true }),
      is_primary: booleanField({ filterable: true, createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    createAccess: {
      admin: {},
      driver: {
        injectPrincipalColumn: 'driver_id',
        writeColumns: ['label', 'city', 'state', 'postal_code', 'geofence_json', 'is_primary']
      }
    },
    updateAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope,
        writeColumns: ['label', 'city', 'state', 'postal_code', 'geofence_json', 'is_primary']
      }
    },
    deleteAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    }
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
    name: 'driver_devices',
    path: 'driver-devices',
    table: 'driver_devices',
    idColumn: 'device_id',
    fields: {
      device_id: stringField({ filterable: true }),
      driver_id: stringField({ filterable: true, createable: true }),
      platform: stringField({ createable: true, updateable: true }),
      push_token: stringField({ createable: true, updateable: true }),
      app_version: stringField({ createable: true, updateable: true }),
      last_seen_at: timestampField({ createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    createAccess: {
      admin: {},
      driver: {
        injectPrincipalColumn: 'driver_id',
        writeColumns: ['platform', 'push_token', 'app_version', 'last_seen_at']
      }
    },
    updateAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope,
        writeColumns: ['platform', 'push_token', 'app_version', 'last_seen_at']
      }
    },
    deleteAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    }
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
        scope: driverDirectScope
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
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
        scope: driverDirectScope,
        writeColumns: ['lat', 'lng', 'accuracy_m', 'heading', 'speed_mps', 'recorded_at', 'source']
      }
    },
    deleteAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    }
  }),
  resource({
    name: 'driver_notifications',
    path: 'driver-notifications',
    table: 'driver_notifications',
    idColumn: 'notification_id',
    fields: {
      notification_id: stringField({ filterable: true }),
      driver_id: stringField({ filterable: true, createable: true, updateable: true }),
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
      driver: {
        scope: driverDirectScope
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    createAccess: adminOnly(),
    updateAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope,
        writeColumns: ['is_read', 'read_at']
      }
    },
    deleteAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
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
        scope: driverDirectScope
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
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
        scope: driverDirectScope
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    createAccess: adminOnly(),
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'driver_support_tickets',
    path: 'driver-support-tickets',
    table: 'driver_support_tickets',
    idColumn: 'ticket_id',
    fields: {
      ticket_id: stringField({ filterable: true }),
      driver_id: stringField({ filterable: true, createable: true }),
      delivery_id: stringField({ filterable: true, createable: true, updateable: true }),
      order_id: stringField({ filterable: true, createable: true, updateable: true }),
      issue_type: stringField({ filterable: true, createable: true, updateable: true }),
      message: stringField({ createable: true, updateable: true }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
      created_at: timestampField({ createable: true, updateable: true }),
      updated_at: timestampField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    createAccess: {
      admin: {},
      driver: {
        injectPrincipalColumn: 'driver_id',
        writeColumns: ['delivery_id', 'order_id', 'issue_type', 'message']
      }
    },
    updateAccess: adminOnly(),
    deleteAccess: adminOnly()
  }),
  resource({
    name: 'driver_tasks',
    path: 'driver-tasks',
    table: 'driver_tasks',
    idColumn: 'task_id',
    fields: {
      task_id: stringField({ filterable: true }),
      delivery_id: stringField({ filterable: true, createable: true, updateable: true }),
      driver_id: stringField({ filterable: true, createable: true, updateable: true }),
      task_type: stringField({ filterable: true, createable: true, updateable: true }),
      status: stringField({ filterable: true, createable: true, updateable: true }),
      due_at: timestampField({ createable: true, updateable: true }),
      completed_at: timestampField({ createable: true, updateable: true }),
      instructions: stringField({ createable: true, updateable: true })
    },
    listAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    getAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope
      }
    },
    createAccess: adminOnly(),
    updateAccess: {
      admin: {},
      driver: {
        scope: driverDirectScope,
        writeColumns: ['status', 'completed_at']
      }
    },
    deleteAccess: adminOnly()
  })
];
