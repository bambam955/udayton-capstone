import { adminResourceDefinitions } from '../../admins/definitions.js';
import { customerResourceDefinitions } from '../../customers/definitions.js';
import { deliveryResourceDefinitions } from '../../deliveries/definitions.js';
import { driverResourceDefinitions } from '../../drivers/definitions.js';
import { orderResourceDefinitions } from '../../orders/definitions.js';
import { paymentResourceDefinitions } from '../../payments/definitions.js';
import { retailerResourceDefinitions } from '../../retailers/definitions.js';

export const allResourceDefinitions = [
  ...adminResourceDefinitions,
  ...customerResourceDefinitions,
  ...driverResourceDefinitions,
  ...retailerResourceDefinitions,
  ...orderResourceDefinitions,
  ...deliveryResourceDefinitions,
  ...paymentResourceDefinitions
];
