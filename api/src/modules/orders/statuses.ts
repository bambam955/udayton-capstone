export const orderStatuses = [
  'SUBMITTED',
  'PICKING',
  'READY_FOR_PICKUP',
  'OUT_FOR_DELIVERY',
  'DELIVERED'
] as const;

export type OrderStatus = (typeof orderStatuses)[number];
