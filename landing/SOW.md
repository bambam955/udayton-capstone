# Scope of Work (SOW)
## Grocery Pickup-to-Delivery Marketplace App

**Framework:** Flutter (iOS + Android)  
**Backend:** API-driven services  
**Admin:** Web dashboard  
**Retailer Model:** Store employees pick orders; drivers deliver

---

## 1. Project Overview

This project is a grocery delivery marketplace similar to Instacart, with a key operational difference:

- Grocery store employees pick and stage orders.
- Drivers only handle pickup and last-mile delivery.
- Customer accounts connect directly to supported retailers (initially Walmart and Target) using APIs.
- Orders are created as **pickup orders** inside retailer systems.

The platform acts as a logistics and orchestration layer between customers, retailers, and drivers.

---

## 2. Objectives

- Enable customers to browse retailer catalogs and place pickup-based grocery orders.
- Submit orders directly to retailer systems for employee fulfillment.
- Track order status from submission through delivery.
- Dispatch drivers only once orders are marked ready for pickup.
- Provide operational visibility and control through an admin dashboard.

---

## 3. Platforms and Applications

- **Customer App:** Flutter (iOS + Android)
- **Driver App:** Flutter (iOS + Android)
- **Admin Dashboard:** Web application
- **Backend Services:** REST
- **Retailer Integration Layer:** Backend-only service

---

## 4. User Roles

- **Customer**
- **Driver**
- **Admin / Support**
- **Retailer Systems (external)**

---

## 5. Functional Scope

### 5.1 Customer App (Flutter)

#### Account Management
- Sign up and login (email/phone)
- Address book
- Payment methods
- Order history

#### Retailer Account Linking
- Connect Mockoon API for proof of concept(mock data)
- Secure token storage and refresh handling
- Disconnect and re-authentication flows

#### Shopping
- Retailer and location selection
- Product browsing and search
- Cart management
- Substitution preferences
- Delivery window selection based on pickup availability

#### Checkout
- Payment authorization
- Order confirmation
- Fee and tax breakdown

#### Order Tracking
- Order lifecycle tracking
- Live driver tracking once assigned
- Push notifications and in-app alerts

---

### 5.2 Driver App (Flutter)

#### Onboarding
- Profile and vehicle setup
- Identity verification
- Payout account setup

#### Delivery Workflow
- Job offers with pay and distance estimates
- Pickup confirmation at retailer
- Navigation to delivery location
- Proof of delivery (photo, GPS, timestamp)

#### Earnings
- Delivery history
- Earnings summaries
- Payout tracking

#### Background Services
- Foreground and background location updates
- Push notifications
- Offline handling and retry logic

---

### 5.3 Retailer Integration Layer

- Create pickup orders in retailer systems
- Sync order status updates (submitted, picking, ready)
- Handle substitutions and partial fulfillment
- Support order cancellation flows
- Retrieve product catalog and pricing data

> Retailer integrations are isolated to backend services and never exposed directly to client apps.

---

### 5.4 Dispatch and Logistics Engine

- Driver matching based on proximity and availability
- ETA estimation
- Order reassignment on failure or cancellation
- Handling retailer delays and pickup readiness

---

### 5.5 Payments and Payouts

- Customer payment processing
- Driver payouts
- Tips and adjustments
- Full and partial refunds
- Chargeback handling

---

### 5.6 Admin Dashboard (Web)

- Live order monitoring
- Customer and driver management
- Manual overrides and refunds
- Retailer integration health monitoring
- Metrics and reporting tools

---

## 6. Technical Scope

### Mobile Architecture
- Flutter single codebase for iOS and Android
- Modular feature-based structure
- State management (Bloc, Riverpod, or equivalent)
- Platform channels for native integrations

### Native Integrations
- Maps (Google Maps or Mapbox)
- Push notifications (Firebase)
- Camera and media access
- Secure storage for credentials

### Backend Architecture
- REST 
- PostgreSQL database
- Background job queues
- Webhooks and polling for retailer updates

---

## 7. Deliverables

1. Flutter Customer App (iOS + Android)
2. Flutter Driver App (iOS + Android)
3. Backend API services
4. Retailer integration service
5. Admin web dashboard
6. CI/CD pipelines for mobile and backend
7. Automated testing suite
8. Technical documentation and runbooks

---

## 8. Phases and Milestones

### Phase 0: Discovery
- Confirm retailer integration strategy
- Define MVP feature set
- Architecture and data modeling
- Risk assessment

### Phase 1: MVP Development
- Core customer and driver flows
- Pickup order integration
- Dispatch and payment services
- Admin dashboard (core features)

### Phase 2: Hardening and Scale
- Performance optimization
- Advanced dispatch logic
- Monitoring and analytics
- Operational tooling improvements

---

## 9. Assumptions and Dependencies

- Retailer APIs are accessible directly or through approved partners.
- Flutter plugins support required background and native features.
- Initial launch is geographically limited.
- Drivers operate as independent contractors or employees (TBD).

---

## 10. Out of Scope

- Alcohol or regulated item delivery
- Warehousing or inventory ownership
- Multi-retailer carts in a single checkout
- Loyalty programs and subscriptions
- Demand forecasting or dynamic pricing

---

## 11. Acceptance Criteria (MVP)

- Customers can place and track pickup-based grocery orders end-to-end.
- Retailer systems receive and process pickup orders successfully.
- Drivers can accept, pick up, and deliver orders with proof of delivery.
- Payments and payouts function correctly.
- Admins can monitor and intervene in active orders.
- Flutter apps perform reliably on both iOS and Android.

---

## 12. Definition of MVP

The MVP (Minimum Viable Product) is defined as the smallest functional version of the platform that enables real customers, real orders, and real deliveries without manual intervention.
