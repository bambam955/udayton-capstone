# Driver Application E-R Diagram  
## Grocery Pickup-to-Delivery Marketplace Platform

This Entity–Relationship (E-R) diagram represents the complete data model for the **Driver Application** of the Grocery Pickup-to-Delivery Marketplace system. The driver app is responsible for delivery execution, real-time status tracking, earnings management, and communication between drivers and the platform.

Unlike the customer system, which focuses on ordering and payments, the driver system is operational. It manages authentication, availability, delivery lifecycle events, geolocation tracking, proof-of-delivery validation, task orchestration, and payout processing.

The data model is organized into three major functional domains:

---

## 1. Driver Core

This domain manages driver identity, authentication, compliance, and operational readiness.

It includes:
- Driver account records
- Sessions and device registration
- Driver profile and background verification
- Vehicles and required documents
- Availability tracking
- Service area definitions
- Real-time GPS location logging
- Driver notifications

This ensures the platform can:
- Authenticate drivers securely
- Verify compliance requirements
- Track active delivery readiness
- Route deliveries based on geography
- Send real-time offer and status notifications

---

## 2. Delivery Operations

This domain handles the complete lifecycle of a delivery from assignment to completion.

It includes:
- Delivery assignments tied to orders
- Delivery offers and acceptance workflow
- Delivery status event logging
- Task breakdown for pickup and drop-off
- Proof of delivery records (photo/signature)

This supports:
- Offer → Accept → Pickup → Deliver flows
- Real-time delivery tracking
- Audit logging of status changes
- Evidence capture for completed deliveries
- Clear separation between orders and execution

---

## 3. Earnings and Support

This domain manages driver compensation and operational issue handling.

It includes:
- Earnings per delivery
- Bonuses, tips, and adjustments
- Payout batches
- Driver support tickets linked to deliveries

This allows:
- Transparent earnings calculation
- Payment reconciliation
- Dispute resolution
- Financial reporting

---

## Architectural Intent

The schema is designed using normalized relational principles to:

- Preserve data integrity through primary and foreign key constraints
- Support real-time delivery workflows
- Maintain a full audit trail of delivery events
- Allow scalable expansion to multiple retailers and service regions
- Enable mock API simulation (Mockoon) during proof-of-concept phases

This E-R diagram represents the **operational backbone of the driver ecosystem**, ensuring deliveries are executed reliably, traceably, and securely.


![Driver E-R Diagram](<BizRush-Driver E-R Diagram.drawio.png>)