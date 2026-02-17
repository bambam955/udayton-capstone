# Entity–Relationship (E-R) Diagram  
## Customer Application Database Design

The Entity–Relationship (E-R) Diagram represents the logical data model for the Customer Application of the Grocery Pickup-to-Delivery Marketplace platform. This diagram defines the core entities, attributes, primary keys, foreign keys, and relationships required to support customer account management, retailer integration, cart management, order processing, delivery tracking, payments, support, and notifications.

The database is designed using a normalized relational structure to ensure data integrity, reduce redundancy, and maintain scalability as the system evolves from a Mockoon proof-of-concept environment to a production-ready implementation. Referential integrity is enforced through primary key and foreign key constraints, while unique constraints ensure data consistency for critical fields such as email addresses, retailer account links, and access tokens.

The model is organized into functional domains to improve clarity and maintainability:

- **Customer Core** – identity, authentication, sessions, devices, and addresses  
- **Retail & Catalog** – retailer records, linked retailer accounts, product categories, and product catalog cache  
- **Cart & Ordering** – carts, cart items, orders, order items, and order status tracking  
- **Delivery & Payments** – delivery assignments, proof of delivery, payment processing, and refunds  
- **Support & Engagement** – support tickets, attachments, notifications, and customer ratings  

This structure ensures the application supports:

- Secure customer authentication and device tracking  
- Retailer account linking (mock and future OAuth integrations)  
- Accurate cart and order state management  
- Full order lifecycle tracking with status history  
- Delivery confirmation and proof storage  
- Payment authorization and refund processing  
- Customer support workflows and engagement features  

The following diagrams illustrates all entities and their relationships in detail.


![Customer E-R Diagram](<../../assets/E-Rimages/BizRush-Customer E-R.drawio.png>)