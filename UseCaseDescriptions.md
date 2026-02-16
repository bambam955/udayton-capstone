# Use Case Descriptions (Mockoon POC)
All use cases below follow the same fields and are aligned to a proof-of-concept using Mockoon mock APIs.

---

## C1 — Browse Mock Products and Build Cart
- **Use Case ID:** C1  
- **Use Case Name:** Browse Mock Products and Build Cart  
- **Primary Actor:** Customer  
- **Goal:** Browse mock retailer products and add/remove items to a cart.  
- **Scope:** Customer App (Flutter) + Mockoon  
- **Level:** User goal  
- **Preconditions:** Mockoon is running; customer app is open; network access available.  
- **Trigger:** Customer selects a retailer and opens the product browsing screen.  
- **Main Success Scenario:**
  1. Customer selects a retailer (Mock Walmart/Target).
  2. System requests product list from Mockoon.
  3. System displays product list.
  4. Customer adds one or more items to cart.
  5. System updates cart totals locally and displays updated cart state.
- **Alternate / Exception Flows:**
  - **A1:** Product list is empty → System displays “No products available.”
  - **E1:** Mockoon endpoint fails/timeouts → System displays error and provides retry.
- **Postconditions (Success):** Cart contains selected items with correct quantities and totals.  
- **Postconditions (Failure):** Cart is unchanged; error state displayed if applicable.  
- **Mockoon Endpoints / Data:** `GET /products?retailer={retailerId}`  
- **Notes / Special Requirements:** Cart is local-only for POC (in-memory or local storage).

---

## C2 — Simulate Retailer Account Linking
- **Use Case ID:** C2  
- **Use Case Name:** Simulate Retailer Account Linking  
- **Primary Actor:** Customer  
- **Goal:** Simulate connecting a retailer account (no real OAuth).  
- **Scope:** Customer App (Flutter) + Mockoon  
- **Level:** User goal  
- **Preconditions:** Mockoon is running; customer app is open.  
- **Trigger:** Customer taps “Connect Walmart” or “Connect Target.”  
- **Main Success Scenario:**
  1. Customer taps connect for a retailer.
  2. System sends a link request to Mockoon.
  3. Mockoon returns a mock token and connection status.
  4. System stores token locally.
  5. System updates UI to show retailer as connected.
- **Alternate / Exception Flows:**
  - **E1:** Mockoon returns error (401/500) → System shows failure and keeps retailer disconnected.
- **Postconditions (Success):** Retailer connection marked as connected; token stored locally.  
- **Postconditions (Failure):** Retailer remains disconnected; token not stored.  
- **Mockoon Endpoints / Data:** `POST /connect-retailer`  
- **Notes / Special Requirements:** Token expiry can be mocked to test reconnect UI.

---

## C3 — Place Mock Pickup Order
- **Use Case ID:** C3  
- **Use Case Name:** Place Mock Pickup Order  
- **Primary Actor:** Customer  
- **Goal:** Create a mock pickup order and receive an order ID for tracking.  
- **Scope:** Customer App (Flutter) + Mockoon  
- **Level:** User goal  
- **Preconditions:** Cart has items; retailer is connected (mock); Mockoon running.  
- **Trigger:** Customer taps “Place Order” at checkout.  
- **Main Success Scenario:**
  1. Customer reviews cart and checkout details.
  2. System submits order payload to Mockoon.
  3. Mockoon returns `orderId` and status `SUBMITTED`.
  4. System stores order locally and displays confirmation.
  5. Customer can open tracking for the new order.
- **Alternate / Exception Flows:**
  - **A1:** Retailer not connected → System prompts customer to connect retailer before ordering.
  - **E1:** Mockoon returns error/timeout → System shows error and does not create order.
- **Postconditions (Success):** Order created with orderId; visible in order history; status initialized.  
- **Postconditions (Failure):** No order created; customer remains on checkout with error shown.  
- **Mockoon Endpoints / Data:** `POST /orders`  
- **Notes / Special Requirements:** Payment is simulated for POC (no real charge/capture).

---

## C4 — Track Simulated Order Status
- **Use Case ID:** C4  
- **Use Case Name:** Track Simulated Order Status  
- **Primary Actor:** Customer  
- **Goal:** View order status changes over time using simulated responses.  
- **Scope:** Customer App (Flutter) + Mockoon  
- **Level:** User goal  
- **Preconditions:** An order exists; Mockoon running; app can poll status endpoint.  
- **Trigger:** Customer opens “Track Order” for a selected order.  
- **Main Success Scenario:**
  1. Customer opens tracking screen for an order.
  2. System requests current status from Mockoon.
  3. System displays status timeline.
  4. System polls status endpoint at intervals.
  5. Timeline updates as Mockoon returns new statuses.
- **Alternate / Exception Flows:**
  - **E1:** Mockoon returns error/timeout → System displays warning and keeps last known status.
  - **A1:** Status skips forward (scripted) → System updates to newest status without breaking UI.
- **Postconditions (Success):** Latest simulated status displayed with history/timeline.  
- **Postconditions (Failure):** Last known status displayed with error indicator.  
- **Mockoon Endpoints / Data:** `GET /orders/{orderId}/status`  
- **Notes / Special Requirements:** Mockoon can rotate statuses per request or scenario state.

---

## C5 — Submit Mock Support Requests
- **Use Case ID:** C5  
- **Use Case Name:** Submit Mock Support Requests  
- **Primary Actor:** Customer  
- **Goal:** Create a mock support ticket and receive confirmation.  
- **Scope:** Customer App (Flutter) + Mockoon  
- **Level:** User goal  
- **Preconditions:** Customer app open; Mockoon running; orderId optional.  
- **Trigger:** Customer selects “Support” and submits an issue form.  
- **Main Success Scenario:**
  1. Customer selects issue type and enters details.
  2. System submits ticket request to Mockoon.
  3. Mockoon returns `ticketId` and status `OPEN`.
  4. System displays ticket confirmation to customer.
- **Alternate / Exception Flows:**
  - **E1:** Mockoon returns error/timeout → System shows error and provides retry.
- **Postconditions (Success):** Ticket confirmation displayed; ticketId available for reference.  
- **Postconditions (Failure):** Ticket not created; error displayed.  
- **Mockoon Endpoints / Data:** `POST /support/tickets`  
- **Notes / Special Requirements:** Store tickets locally only if needed for demo.

---

## D1 — Driver Login
- **Use Case ID:** D1  
- **Use Case Name:** Driver Login  
- **Primary Actor:** Driver  
- **Goal:** Log in as a driver and load a driver dashboard using mock auth.  
- **Scope:** Driver App (Flutter) + Mockoon  
- **Level:** User goal  
- **Preconditions:** Mockoon running; driver app open; network access.  
- **Trigger:** Driver submits login credentials.  
- **Main Success Scenario:**
  1. Driver enters credentials and taps Login.
  2. System submits login request to Mockoon.
  3. Mockoon returns mock token and driver profile.
  4. System stores token locally.
  5. System loads driver dashboard.
- **Alternate / Exception Flows:**
  - **E1:** Invalid credentials (401) → System shows login failure.
  - **E2:** API error/timeout → System shows error and retry option.
- **Postconditions (Success):** Driver session active; dashboard visible.  
- **Postconditions (Failure):** No session created; login error displayed.  
- **Mockoon Endpoints / Data:** `POST /auth/driver/login`  
- **Notes / Special Requirements:** Token persistence local-only for POC.

---

## D2 — Fetch Available Mock Deliveries
- **Use Case ID:** D2  
- **Use Case Name:** Fetch Available Mock Deliveries  
- **Primary Actor:** Driver  
- **Goal:** View a list of available deliveries from mock dispatch feed.  
- **Scope:** Driver App (Flutter) + Mockoon  
- **Level:** User goal  
- **Preconditions:** Driver logged in (mock token present); Mockoon running.  
- **Trigger:** Driver opens “Available Deliveries.”  
- **Main Success Scenario:**
  1. Driver opens available deliveries screen.
  2. System requests delivery list from Mockoon.
  3. System displays available delivery cards with key info.
- **Alternate / Exception Flows:**
  - **E1:** API error/timeout → System displays error and retry option.
  - **A1:** Empty list → System displays “No deliveries available.”
- **Postconditions (Success):** Delivery list displayed.  
- **Postconditions (Failure):** No list displayed; error shown.  
- **Mockoon Endpoints / Data:** `GET /deliveries/available`  
- **Notes / Special Requirements:** Jobs can be static or scenario-based in Mockoon.

---

## D3 — Accept Mock Delivery
- **Use Case ID:** D3  
- **Use Case Name:** Accept Mock Delivery  
- **Primary Actor:** Driver  
- **Goal:** Accept a mock delivery and move it into “assigned/active” state.  
- **Scope:** Driver App (Flutter) + Mockoon  
- **Level:** User goal  
- **Preconditions:** Driver logged in; at least one delivery available.  
- **Trigger:** Driver taps “Accept” on a delivery job.  
- **Main Success Scenario:**
  1. Driver selects a delivery job.
  2. System sends accept request to Mockoon.
  3. Mockoon returns confirmation with updated status `ASSIGNED`.
  4. System displays active delivery screen for that job.
- **Alternate / Exception Flows:**
  - **E1:** Delivery no longer available (409/404) → System shows “Job no longer available.”
  - **E2:** API error/timeout → System shows error and retry.
- **Postconditions (Success):** Delivery assigned to driver; active job shown.  
- **Postconditions (Failure):** Delivery remains unassigned; error displayed.  
- **Mockoon Endpoints / Data:** `POST /deliveries/{deliveryId}/accept`  
- **Notes / Special Requirements:** For POC, driverId can be fixed or read from mock profile.

---

## D4 — Confirm Pickup
- **Use Case ID:** D4  
- **Use Case Name:** Confirm Pickup  
- **Primary Actor:** Driver  
- **Goal:** Mark a delivery as picked up and begin delivery phase.  
- **Scope:** Driver App (Flutter) + Mockoon  
- **Level:** User goal  
- **Preconditions:** Driver has an assigned job; order is ready for pickup (simulated).  
- **Trigger:** Driver taps “Confirm Pickup.”  
- **Main Success Scenario:**
  1. Driver opens active delivery.
  2. Driver taps confirm pickup.
  3. System sends pickup confirmation to Mockoon.
  4. Mockoon returns updated status `OUT_FOR_DELIVERY`.
  5. System updates UI to show delivery phase.
- **Alternate / Exception Flows:**
  - **A1:** Order not ready (status mismatch) → System shows “Not ready yet.”
  - **E1:** API error/timeout → System shows error and retry.
- **Postconditions (Success):** Delivery state changes to out-for-delivery in UI.  
- **Postconditions (Failure):** Delivery state unchanged; error displayed.  
- **Mockoon Endpoints / Data:** `POST /deliveries/{deliveryId}/pickup`  
- **Notes / Special Requirements:** Readiness can be simulated by admin updates or Mockoon scenario.

---

## D5 — Complete Delivery with Proof (Photo)
- **Use Case ID:** D5  
- **Use Case Name:** Complete Delivery with Proof (Photo)  
- **Primary Actor:** Driver  
- **Goal:** Complete delivery and submit proof for demo purposes.  
- **Scope:** Driver App (Flutter) + Mockoon  
- **Level:** User goal  
- **Preconditions:** Delivery is active; driver has access to camera (or mock photo).  
- **Trigger:** Driver taps “Complete Delivery.”  
- **Main Success Scenario:**
  1. Driver taps complete delivery.
  2. System captures photo (or selects mock proof).
  3. System submits completion request to Mockoon.
  4. Mockoon returns status `DELIVERED` and mock earnings.
  5. System displays completion confirmation and earnings update.
- **Alternate / Exception Flows:**
  - **E1:** Camera not available → System allows placeholder proof or blocks completion (POC decision).
  - **E2:** API error/timeout → System shows error and retry.
- **Postconditions (Success):** Delivery marked delivered; earnings updated in UI.  
- **Postconditions (Failure):** Delivery not completed; error displayed.  
- **Mockoon Endpoints / Data:** `POST /deliveries/{deliveryId}/complete`  
- **Notes / Special Requirements:** Photo upload can be simulated with metadata or base64 stub.

---

## A1 — View All Orders
- **Use Case ID:** A1  
- **Use Case Name:** View All Orders  
- **Primary Actor:** Admin  
- **Goal:** View all orders and their statuses for monitoring.  
- **Scope:** Admin Dashboard + Mockoon  
- **Level:** User goal  
- **Preconditions:** Admin dashboard accessible; Mockoon running.  
- **Trigger:** Admin opens orders page.  
- **Main Success Scenario:**
  1. Admin navigates to orders list.
  2. System requests all orders from Mockoon.
  3. System displays orders table with status and key fields.
- **Alternate / Exception Flows:**
  - **E1:** API error/timeout → System shows error banner and retry.
  - **A1:** No orders → System shows empty state.
- **Postconditions (Success):** Orders displayed to admin.  
- **Postconditions (Failure):** Orders not displayed; error shown.  
- **Mockoon Endpoints / Data:** `GET /admin/orders`  
- **Notes / Special Requirements:** Include order filtering/sorting if needed for demo.

---

## A2 — Manually Update Order Status
- **Use Case ID:** A2  
- **Use Case Name:** Manually Update Order Status  
- **Primary Actor:** Admin  
- **Goal:** Simulate operational control by manually changing an order’s status.  
- **Scope:** Admin Dashboard + Mockoon  
- **Level:** User goal  
- **Preconditions:** Orders exist; admin can select an order; Mockoon running.  
- **Trigger:** Admin selects an order and chooses a new status.  
- **Main Success Scenario:**
  1. Admin opens order details.
  2. Admin selects a new status from dropdown.
  3. System submits update to Mockoon.
  4. Mockoon returns updated order object.
  5. System refreshes UI with new status.
- **Alternate / Exception Flows:**
  - **E1:** API error/timeout → System shows error and keeps old status.
- **Postconditions (Success):** Order status updated and visible in UI.  
- **Postconditions (Failure):** Order status unchanged; error shown.  
- **Mockoon Endpoints / Data:** `POST /admin/orders/{orderId}/status`  
- **Notes / Special Requirements:** This drives customer tracking and driver pickup readiness in POC.

---

## A3 — Issue Mock Refund
- **Use Case ID:** A3  
- **Use Case Name:** Issue Mock Refund  
- **Primary Actor:** Admin  
- **Goal:** Simulate refund/adjustment workflow for POC demonstration.  
- **Scope:** Admin Dashboard + Mockoon  
- **Level:** User goal  
- **Preconditions:** Order exists; refund UI available; Mockoon running.  
- **Trigger:** Admin clicks refund action and submits an amount/reason.  
- **Main Success Scenario:**
  1. Admin opens an order.
  2. Admin enters refund amount and reason.
  3. System submits refund request to Mockoon.
  4. Mockoon returns refund confirmation (refundId, status).
  5. System updates order view to reflect refund event.
- **Alternate / Exception Flows:**
  - **A1:** Invalid amount → System blocks submission and prompts correction.
  - **E1:** API error/timeout → System shows error and does not confirm refund.
- **Postconditions (Success):** Refund confirmation shown; order reflects refund status.  
- **Postconditions (Failure):** No refund confirmation; error shown.  
- **Mockoon Endpoints / Data:** `POST /admin/orders/{orderId}/refund`  
- **Notes / Special Requirements:** No real payment provider integration in POC.

---

## A4 — View Drivers
- **Use Case ID:** A4  
- **Use Case Name:** View Drivers  
- **Primary Actor:** Admin  
- **Goal:** View driver list and statuses for POC monitoring.  
- **Scope:** Admin Dashboard + Mockoon  
- **Level:** User goal  
- **Preconditions:** Mockoon running.  
- **Trigger:** Admin opens drivers page.  
- **Main Success Scenario:**
  1. Admin navigates to drivers list.
  2. System requests driver list from Mockoon.
  3. System displays driver table with status and basic metrics.
- **Alternate / Exception Flows:**
  - **E1:** API error/timeout → System shows error banner and retry.
  - **A1:** No drivers → System shows empty state.
- **Postconditions (Success):** Drivers displayed to admin.  
- **Postconditions (Failure):** Drivers not displayed; error shown.  
- **Mockoon Endpoints / Data:** `GET /admin/drivers`  
- **Notes / Special Requirements:** Driver status can be static (active/inactive) for POC.

---

## A5 — Simulate API Failure
- **Use Case ID:** A5  
- **Use Case Name:** Simulate API Failure  
- **Primary Actor:** Admin  
- **Goal:** Demonstrate error handling and recovery in the UI.  
- **Scope:** Admin Dashboard + Mockoon  
- **Level:** User goal  
- **Preconditions:** Mockoon has a configured failing route or delayed response scenario.  
- **Trigger:** Admin clicks “Simulate Failure” or selects a failure mode.  
- **Main Success Scenario:**
  1. Admin triggers failure simulation.
  2. System calls an endpoint configured to fail.
  3. Mockoon returns 500 or times out.
  4. System shows error state and retains last valid data (if available).
  5. Admin can retry and recover when endpoint returns to normal.
- **Alternate / Exception Flows:**
  - **A1:** Failure persists → System continues to show error and allows retry/backoff.
  - **A2:** Partial failure (slow response) → System shows loading state then error.
- **Postconditions (Success):** Error displayed gracefully; app remains usable; retry path available.  
- **Postconditions (Failure):** If not handled, UI may freeze/crash (this is what you’re proving does NOT happen).  
- **Mockoon Endpoints / Data:** Any endpoint configured as `500`, `timeout`, or delayed response (e.g., `GET /admin/orders?mode=fail`)  
- **Notes / Special Requirements:** Include visible logging/diagnostics banner for demo credibility.

---
