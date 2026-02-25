# Grocery Pickup-to-Delivery Marketplace App
## Use Case Descriptions (Mockoon Proof of Concept)

---

# Table of Contents

1. Customer Use Cases
   1.1 [C1 – Browse Mock Products and Build Cart](#c1--browse-mock-products-and-build-cart)
   1.2 [C2 – Simulate Retailer Account Linking](#c2--simulate-retailer-account-linking)
   1.3 [C3 – Place Mock Pickup Order](#c3--place-mock-pickup-order)
   1.4 [C4 – Track Simulated Order Status](#c4--track-simulated-order-status)
   1.5 [C5 – Submit Mock Support Requests](#c5--submit-mock-support-requests)

2. Driver Use Cases
   2.1 [D1 – Driver Login](#d1--driver-login)
   2.2 [D2 – Fetch Available Mock Deliveries](#d2--fetch-available-mock-deliveries)
   2.3 [D3 – Accept Mock Delivery](#d3--accept-mock-delivery)
   2.4 [D4 – Confirm Pickup](#d4--confirm-pickup)
   2.5 [D5 – Complete Delivery with Proof (Photo)](#d5--complete-delivery-with-proof-photo)

3. Admin Use Cases
   3.1 [A1 – View All Orders](#a1--view-all-orders)
   3.2 [A2 – Manually Update Order Status](#a2--manually-update-order-status)
   3.3 [A3 – Issue Mock Refund](#a3--issue-mock-refund)
   3.4 [A4 – View Drivers](#a4--view-drivers)
   3.5 [A5 – Simulate API Failure](#a5--simulate-api-failure)

---

# Customer Use Cases

---

## C1 – Browse Mock Products and Build Cart

### Use Case Description
- **Use Case ID:** C1
- **Primary Actor:** Customer
- **Goal:** Browse mock retailer products and add/remove items to a cart.
- **Scope:** Customer App (Flutter) + Mockoon
- **Level:** User Goal

### Preconditions
- Mockoon server is running.
- Customer application is launched.
- Network connectivity is available.

### Trigger
Customer selects a retailer and navigates to the product browsing screen.

### Main Success Scenario
1. Customer selects a mock retailer (Walmart or Target).
2. System sends a request to Mockoon to retrieve product data.
3. Mockoon returns a list of mock products.
4. System displays products in the UI.
5. Customer selects one or more products and adds them to the cart.
6. System updates cart contents and recalculates totals locally.
7. Updated cart state is displayed to the customer.

### Alternate Flows
- **A1: No Products Returned**
  - Mockoon returns an empty array.
  - System displays “No products available.”

### Exception Flows
- **E1: API Error or Timeout**
  - Mockoon returns an error or fails to respond.
  - System displays an error message.
  - Customer may retry the request.

### Postconditions (Success)
- Cart contains selected items.
- Cart totals are updated correctly.
- Product list is visible.

### Postconditions (Failure)
- Cart remains unchanged.
- Error state is displayed to the customer.

### Mockoon Endpoint
`GET /products?retailer={retailerId}`

### Special Requirements
- Cart data is stored locally for POC (no backend persistence).
- Pricing and availability are mock values only.

---

## C2 – Simulate Retailer Account Linking

### Use Case Description
- **Use Case ID:** C2
- **Primary Actor:** Customer
- **Goal:** Simulate connecting a retailer account using Mockoon (no real OAuth).
- **Scope:** Customer App (Flutter) + Mockoon
- **Level:** User Goal

### Preconditions
- Mockoon server is running.
- Customer is logged in or at least has an active app session.
- Customer is on the retailer connection/settings screen.

### Trigger
Customer taps “Connect Walmart” or “Connect Target.”

### Main Success Scenario
1. Customer chooses a retailer to connect.
2. System sends a connection request to Mockoon.
3. Mockoon returns a mock access token and a connected status.
4. System stores the token locally (secure storage or local storage for POC).
5. System updates UI to show the retailer as connected.

### Alternate Flows
- **A1: Retailer Already Connected**
  - System detects existing stored token for that retailer.
  - System displays “Connected” without calling Mockoon.

### Exception Flows
- **E1: API Error or Timeout**
  - Mockoon returns an error or fails to respond.
  - System displays error and keeps retailer disconnected.
  - Customer may retry.

### Postconditions (Success)
- Retailer connection state is set to connected.
- Mock token is stored locally.

### Postconditions (Failure)
- Retailer remains disconnected.
- No token stored/updated.

### Mockoon Endpoint
`POST /connect-retailer`

### Special Requirements
- Token expiry can be simulated to test reconnect flows.
- Connection is for demonstration only, not real retailer authentication.

---

## C3 – Place Mock Pickup Order

### Use Case Description
- **Use Case ID:** C3
- **Primary Actor:** Customer
- **Goal:** Submit an order payload to Mockoon and receive an orderId and initial status.
- **Scope:** Customer App (Flutter) + Mockoon
- **Level:** User Goal

### Preconditions
- Customer has items in cart.
- Retailer is connected (mock connection state true).
- Mockoon server is running.

### Trigger
Customer taps “Place Order” on the checkout screen.

### Main Success Scenario
1. Customer reviews checkout (address, delivery notes, items).
2. System validates cart and checkout fields locally.
3. System sends an order creation request to Mockoon containing cart and checkout details.
4. Mockoon returns an `orderId` and status `SUBMITTED`.
5. System stores the order locally and adds it to order history.
6. System displays confirmation screen with the orderId.
7. Customer can navigate to tracking for the new order.

### Alternate Flows
- **A1: Retailer Not Connected**
  - System detects no token/connection for selected retailer.
  - System blocks checkout and prompts customer to connect retailer.

- **A2: Cart Empty**
  - System detects cart has no items.
  - System blocks checkout and prompts customer to add items.

### Exception Flows
- **E1: API Error or Timeout**
  - Mockoon returns an error or fails to respond.
  - System displays an error message and does not create an order.
  - Customer remains on checkout and may retry.

### Postconditions (Success)
- Order exists locally with assigned `orderId`.
- Order status set to `SUBMITTED`.
- Confirmation displayed.

### Postconditions (Failure)
- No new order created.
- Customer sees error and remains in checkout flow.

### Mockoon Endpoint
`POST /orders`

### Special Requirements
- Payment is simulated only (no real payment provider).
- Order creation should work deterministically for demo.

---

## C4 – Track Simulated Order Status

### Use Case Description
- **Use Case ID:** C4
- **Primary Actor:** Customer
- **Goal:** Display changing order statuses by polling Mockoon status endpoint.
- **Scope:** Customer App (Flutter) + Mockoon
- **Level:** User Goal

### Preconditions
- Customer has an existing orderId.
- Mockoon server is running.
- Tracking screen can poll an endpoint on a timer.

### Trigger
Customer opens the tracking screen for a specific order.

### Main Success Scenario
1. Customer opens “Track Order” for an existing orderId.
2. System requests current status from Mockoon.
3. Mockoon returns a status value (e.g., SUBMITTED, PICKING, READY_FOR_PICKUP, OUT_FOR_DELIVERY, DELIVERED).
4. System updates timeline UI to reflect returned status.
5. System continues polling the status endpoint at a set interval.
6. System updates timeline each time a new status is returned.

### Alternate Flows
- **A1: Status Skips Forward**
  - Mockoon returns a newer status than previously displayed (e.g., SUBMITTED → READY_FOR_PICKUP).
  - System updates directly to newest status without error.

- **A2: Status Unchanged**
  - Mockoon returns same status as last poll.
  - System keeps UI unchanged.

### Exception Flows
- **E1: API Error or Timeout**
  - Mockoon returns an error or fails to respond.
  - System displays warning (“Reconnecting…”) and retains last known status.
  - System continues polling and updates if API recovers.

### Postconditions (Success)
- Latest simulated status is displayed in tracking timeline.

### Postconditions (Failure)
- UI displays last known status plus error state.
- No crash or broken tracking screen.

### Mockoon Endpoint
`GET /orders/{orderId}/status`

### Special Requirements
- Do not use `{}` braces in Mermaid node labels (parser issue).
- Mockoon should be configured to rotate or scenario-drive statuses for demo.

---

## C5 – Submit Mock Support Requests

### Use Case Description
- **Use Case ID:** C5
- **Primary Actor:** Customer
- **Goal:** Submit a support ticket to Mockoon and receive a ticket confirmation.
- **Scope:** Customer App (Flutter) + Mockoon
- **Level:** User Goal

### Preconditions
- Customer app is running.
- Mockoon server is running.
- Customer can access support form.
- OrderId optional (can attach to ticket if available).

### Trigger
Customer submits a support form.

### Main Success Scenario
1. Customer selects issue type (missing item, late delivery, damaged item, etc.).
2. Customer enters details and optionally attaches an orderId.
3. System sends ticket creation request to Mockoon.
4. Mockoon returns `ticketId` and status `OPEN`.
5. System displays confirmation and ticketId to customer.

### Alternate Flows
- **A1: No OrderId Provided**
  - System submits ticket without orderId.
  - Ticket still created for demo.

### Exception Flows
- **E1: API Error or Timeout**
  - Mockoon returns error or fails to respond.
  - System displays error and allows retry.
  - No ticket confirmation shown.

### Postconditions (Success)
- Customer sees ticketId confirmation.

### Postconditions (Failure)
- Ticket not created.
- Error displayed.

### Mockoon Endpoint
`POST /support/tickets`

### Special Requirements
- Support ticket storage can be mock-only.
- Keep request schema simple for demo (type, message, orderId optional).

---

# Driver Use Cases

---

## D1 – Driver Login

### Use Case Description
- **Use Case ID:** D1
- **Primary Actor:** Driver
- **Goal:** Authenticate driver and load the driver dashboard using mock auth.
- **Scope:** Driver App (Flutter) + Mockoon
- **Level:** User Goal

### Preconditions
- Mockoon server is running.
- Driver app is launched.
- Network connectivity available.

### Trigger
Driver submits login credentials.

### Main Success Scenario
1. Driver enters username/password (mock).
2. System sends login request to Mockoon.
3. Mockoon returns mock driver token and driver profile.
4. System stores token locally.
5. System loads the driver dashboard.

### Alternate Flows
- **A1: Already Logged In**
  - Token exists locally.
  - System loads dashboard without login call.

### Exception Flows
- **E1: Invalid Credentials (401)**
  - Mockoon returns 401.
  - System shows login failure message.

- **E2: API Error or Timeout**
  - System shows error and retry option.

### Postconditions (Success)
- Driver session active.
- Dashboard displayed.

### Postconditions (Failure)
- No session created.
- Driver remains on login screen.

### Mockoon Endpoint
`POST /auth/driver/login`

### Special Requirements
- POC can use hardcoded driver credentials.
- Token persistence is local-only.

---

## D2 – Fetch Available Mock Deliveries

### Use Case Description
- **Use Case ID:** D2
- **Primary Actor:** Driver
- **Goal:** View a list of available deliveries from Mockoon.
- **Scope:** Driver App (Flutter) + Mockoon
- **Level:** User Goal

### Preconditions
- Driver is logged in (token exists).
- Mockoon server is running.

### Trigger
Driver opens “Available Deliveries.”

### Main Success Scenario
1. Driver navigates to Available Deliveries screen.
2. System sends request to Mockoon for job list.
3. Mockoon returns a list of available delivery jobs.
4. System displays job cards (pickup location, dropoff, pay estimate, status).

### Alternate Flows
- **A1: No Jobs Available**
  - Mockoon returns empty list.
  - System displays “No deliveries available.”

### Exception Flows
- **E1: API Error or Timeout**
  - Error message displayed.
  - Retry allowed.

### Postconditions (Success)
- Driver sees list of jobs.

### Postconditions (Failure)
- No list shown; error displayed.

### Mockoon Endpoint
`GET /deliveries/available`

### Special Requirements
- Jobs can be static JSON or scenario-driven.

---

## D3 – Accept Mock Delivery

### Use Case Description
- **Use Case ID:** D3
- **Primary Actor:** Driver
- **Goal:** Accept a delivery job and move it into an assigned/active state.
- **Scope:** Driver App (Flutter) + Mockoon
- **Level:** User Goal

### Preconditions
- Driver logged in.
- At least one available delivery exists.
- Mockoon server running.

### Trigger
Driver taps “Accept” on a delivery.

### Main Success Scenario
1. Driver selects a job and taps Accept.
2. System sends accept request to Mockoon with driverId and deliveryId.
3. Mockoon returns confirmation with status `ASSIGNED`.
4. System updates UI to show the active delivery screen.

### Alternate Flows
- **A1: Driver Cancels Accept**
  - Driver backs out before confirming.
  - No request sent; job remains available.

### Exception Flows
- **E1: Job No Longer Available (404/409)**
  - System shows “Job no longer available.”
  - Returns to job list.

- **E2: API Error or Timeout**
  - Error shown and retry allowed.

### Postconditions (Success)
- Delivery marked assigned in UI.
- Active job displayed.

### Postconditions (Failure)
- Delivery remains unassigned.
- Driver stays on job list.

### Mockoon Endpoint
`POST /deliveries/{deliveryId}/accept`

### Special Requirements
- For POC, driverId can be pulled from mock profile.

---

## D4 – Confirm Pickup

### Use Case Description
- **Use Case ID:** D4
- **Primary Actor:** Driver
- **Goal:** Confirm pickup to move delivery into “out for delivery.”
- **Scope:** Driver App (Flutter) + Mockoon
- **Level:** User Goal

### Preconditions
- Driver has an assigned delivery.
- Delivery is marked READY_FOR_PICKUP (simulated).
- Mockoon running.

### Trigger
Driver taps “Confirm Pickup.”

### Main Success Scenario
1. Driver opens active delivery details.
2. Driver taps Confirm Pickup.
3. System sends pickup confirmation request to Mockoon.
4. Mockoon returns updated status `OUT_FOR_DELIVERY`.
5. System updates UI to show delivery phase and navigation.

### Alternate Flows
- **A1: Confirm Pickup Requires Code**
  - Driver enters mock pickup code.
  - System includes code in request.

### Exception Flows
- **E1: Not Ready Yet**
  - Mockoon returns status mismatch error.
  - UI shows “Order not ready.”

- **E2: API Error or Timeout**
  - Error shown; retry allowed.

### Postconditions (Success)
- Delivery status moves to OUT_FOR_DELIVERY.

### Postconditions (Failure)
- Delivery status unchanged.
- Error shown.

### Mockoon Endpoint
`POST /deliveries/{deliveryId}/pickup`

### Special Requirements
- Pickup readiness can be driven by Admin status update in POC.

---

## D5 – Complete Delivery with Proof (Photo)

### Use Case Description
- **Use Case ID:** D5
- **Primary Actor:** Driver
- **Goal:** Complete delivery and submit proof of delivery (mock).
- **Scope:** Driver App (Flutter) + Mockoon
- **Level:** User Goal

### Preconditions
- Delivery is active and out for delivery.
- Driver has camera access or mock proof available.
- Mockoon running.

### Trigger
Driver taps “Complete Delivery.”

### Main Success Scenario
1. Driver taps Complete Delivery.
2. System captures photo or selects mock proof.
3. System sends completion request to Mockoon.
4. Mockoon returns status `DELIVERED` and mock earnings amount.
5. System displays success confirmation and earnings update.

### Alternate Flows
- **A1: No Camera Available**
  - System allows a placeholder proof for POC.
  - Completion request still sent.

### Exception Flows
- **E1: API Error or Timeout**
  - Completion not confirmed.
  - UI shows error and allows retry.

### Postconditions (Success)
- Delivery marked as DELIVERED.
- Earnings shown.

### Postconditions (Failure)
- Delivery remains active.
- Error shown.

### Mockoon Endpoint
`POST /deliveries/{deliveryId}/complete`

### Special Requirements
- Proof can be metadata only for demo (filename, timestamp, GPS stub).

---

# Admin Use Cases

---

## A1 – View All Orders

### Use Case Description
- **Use Case ID:** A1
- **Primary Actor:** Admin
- **Goal:** View all orders and their statuses in a dashboard for monitoring.
- **Scope:** Admin Dashboard + Mockoon
- **Level:** User Goal

### Preconditions
- Mockoon server is running.
- Admin dashboard is accessible.

### Trigger
Admin opens the Orders page.

### Main Success Scenario
1. Admin navigates to Orders list.
2. System requests orders from Mockoon.
3. Mockoon returns order list.
4. System displays orders with key fields (orderId, customer, status, timestamps).

### Alternate Flows
- **A1: No Orders**
  - Mockoon returns empty list.
  - UI shows empty state.

### Exception Flows
- **E1: API Error or Timeout**
  - UI shows error banner and retry option.

### Postconditions (Success)
- Orders visible to admin.

### Postconditions (Failure)
- Orders not displayed; error shown.

### Mockoon Endpoint
`GET /admin/orders`

### Special Requirements
- Order list should include statuses that match customer/driver flows.

---

## A2 – Manually Update Order Status

### Use Case Description
- **Use Case ID:** A2
- **Primary Actor:** Admin
- **Goal:** Manually change an order status to drive the POC workflow.
- **Scope:** Admin Dashboard + Mockoon
- **Level:** User Goal

### Preconditions
- Order exists.
- Mockoon running.

### Trigger
Admin selects an order and changes status.

### Main Success Scenario
1. Admin opens order details.
2. Admin selects a new status from allowed list.
3. System sends status update request to Mockoon.
4. Mockoon returns updated order object.
5. UI refreshes and shows updated status.

### Alternate Flows
- **A1: Same Status Selected**
  - System detects no change.
  - No request sent.

### Exception Flows
- **E1: API Error or Timeout**
  - UI shows error.
  - Status remains unchanged.

### Postconditions (Success)
- Order status updated in dashboard.

### Postconditions (Failure)
- Status unchanged; error shown.

### Mockoon Endpoint
`POST /admin/orders/{orderId}/status`

### Special Requirements
- Status update should influence C4 and driver readiness logic.

---

## A3 – Issue Mock Refund

### Use Case Description
- **Use Case ID:** A3
- **Primary Actor:** Admin
- **Goal:** Simulate a refund flow for demo (no real payment).
- **Scope:** Admin Dashboard + Mockoon
- **Level:** User Goal

### Preconditions
- Order exists.
- Mockoon running.

### Trigger
Admin submits a refund action.

### Main Success Scenario
1. Admin opens an order.
2. Admin enters refund amount and reason.
3. System sends refund request to Mockoon.
4. Mockoon returns refund confirmation (refundId, status).
5. UI displays refund success and logs event.

### Alternate Flows
- **A1: Invalid Amount**
  - UI blocks submission and prompts correction.

### Exception Flows
- **E1: API Error or Timeout**
  - Refund not confirmed.
  - UI shows error.

### Postconditions (Success)
- Refund confirmation visible.

### Postconditions (Failure)
- Refund not confirmed; error shown.

### Mockoon Endpoint
`POST /admin/orders/{orderId}/refund`

### Special Requirements
- No real payment provider logic is included in POC.

---

## A4 – View Drivers

### Use Case Description
- **Use Case ID:** A4
- **Primary Actor:** Admin
- **Goal:** View driver list and statuses for monitoring.
- **Scope:** Admin Dashboard + Mockoon
- **Level:** User Goal

### Preconditions
- Mockoon running.

### Trigger
Admin opens Drivers page.

### Main Success Scenario
1. Admin navigates to Drivers list.
2. System requests drivers from Mockoon.
3. Mockoon returns driver list.
4. UI displays driver data (driverId, name, status, last seen).

### Alternate Flows
- **A1: No Drivers**
  - Empty state displayed.

### Exception Flows
- **E1: API Error or Timeout**
  - Error banner shown with retry.

### Postconditions (Success)
- Drivers visible.

### Postconditions (Failure)
- Drivers not displayed; error shown.

### Mockoon Endpoint
`GET /admin/drivers`

### Special Requirements
- Driver statuses can be static for demo.

---

## A5 – Simulate API Failure

### Use Case Description
- **Use Case ID:** A5
- **Primary Actor:** Admin
- **Goal:** Demonstrate that the apps handle API failures gracefully.
- **Scope:** Admin Dashboard + Mockoon
- **Level:** User Goal

### Preconditions
- Mockoon has a failing route or scenario configured (500/timeout).
- Admin can trigger a request that hits the failing route.

### Trigger
Admin triggers “Simulate Failure” or visits a page that calls a failing endpoint.

### Main Success Scenario
1. Admin triggers failure mode.
2. System calls endpoint configured to fail.
3. Mockoon returns 500 or times out.
4. UI displays error state and retains last valid data if available.
5. Admin can retry and recover if endpoint is restored.

### Alternate Flows
- **A1: Slow Response**
  - Mockoon delays response.
  - UI shows loading then error.

### Exception Flows
- **E1: Failure Persists**
  - UI remains in error state.
  - Retry continues to be offered.

### Postconditions (Success)
- Error handled gracefully.
- No crash.
- Retry path exists.

### Postconditions (Failure)
- If not handled, UI could freeze/crash (this is what the use case is proving should not happen).

### Mockoon Endpoint
Any endpoint configured to fail (e.g., `GET /admin/orders?mode=fail`).

### Special Requirements
- Include visible error messaging for demo credibility.
