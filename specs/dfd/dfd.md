# BizRush Data Flow Diagrams (DFD)

This section documents the **Data Flow Diagrams (DFDs)** for the BizRush system.  
DFDs are used to illustrate how data moves through the system, the processes that transform that data, and the external entities and data stores that interact with the platform.

The diagrams follow a **top-down decomposition approach**, beginning with a high-level system overview and then expanding into more detailed child diagrams for key subsystems.

---

# Context Diagram

The **Context Diagram** provides a high-level view of the entire BizRush platform as a single system. It shows the primary external entities that interact with the system and the major data flows between them.

External entities represented include:

- Customers using the mobile application
- Drivers using the driver mobile application
- Administrators using the web portal
- Retailer backend systems
- External payment processors

This diagram helps define the **system boundary** and the major external integrations.

![BizRush Context Diagram](../assets/dfd/bizrushcontextdfd.png)

---

# Diagram 0 – System Overview

Diagram 0 expands the context diagram by decomposing the BizRush system into its **core functional processes**. These processes represent the major subsystems responsible for handling platform operations.

The primary processes include:

1. Account Management  
2. Catalog and Availability  
3. Order Management  
4. Fulfillment Management  
5. Dispatch and Delivery  
6. Payment and Notifications  

This diagram also introduces the system's main **data stores**, such as user records, orders, fulfillment records, delivery records, and payment ledgers.

Diagram 0 illustrates how data moves between system processes, external entities, and internal data stores.

![BizRush Diagram 0](../assets/dfd/BizRush-Diagram0.drawio.png)

---

# Child Diagram – Order Management (Process 3.0)

The **Order Management child diagram** provides a more detailed breakdown of Process 3.0 from Diagram 0.

This diagram shows the internal processes responsible for handling order creation and lifecycle management, including:

- Order validation
- Order record creation
- Order confirmation
- Communication with fulfillment
- Status updates and notifications

The goal of this decomposition is to show how customer orders move from submission through system processing and preparation for fulfillment.

![BizRush Order Management Child Diagram](../assets/dfd/BizRush-3.0ChildDiagram.drawio.png)

---

# Child Diagram – Dispatch and Delivery (Process 5.0)

The **Dispatch and Delivery child diagram** expands Process 5.0 from Diagram 0. This subsystem manages the logistics of assigning drivers, tracking deliveries, and confirming successful delivery completion.

Key responsibilities illustrated in this diagram include:

- Receiving delivery assignments from fulfillment
- Dispatching drivers
- Tracking driver progress and GPS updates
- Capturing proof of delivery
- Managing dispatch adjustments from administrators
- Updating delivery records and closing deliveries

This diagram highlights the interaction between drivers, administrators, and system delivery records.

![BizRush Dispatch and Delivery Child Diagram](../assets/dfd/BizRush-5.0ChildDiagram.drawio.png)

---

# Diagram Relationships

The diagrams follow a hierarchical structure:

Context Diagram
↓
Diagram 0 (System Decomposition)
↓
Child Diagrams (Detailed Process Breakdowns)


Each child diagram maintains **balanced data flows** with Diagram 0, ensuring that the inputs and outputs of each process remain consistent across levels of abstraction.

---

# Purpose of the DFDs

These diagrams serve several purposes within the BizRush system design:

- Documenting system architecture
- Clarifying subsystem responsibilities
- Identifying data stores and integrations
- Supporting implementation planning
- Providing clear technical documentation for development and system maintenance
