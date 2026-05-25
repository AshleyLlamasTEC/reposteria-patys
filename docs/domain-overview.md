# Bakery Ecommerce Platform — Domain Overview

## Project Overview

This project is a custom bakery ecommerce and production management platform built with:

* Laravel 12
* MySQL 8
* React
* Inertia.js

The platform supports:

* ecommerce sales
* customizable cake orders
* production workflows
* operational tracking
* auditing
* admin management

The architecture follows domain-driven and modular principles.

---

# Core Business Domains

The platform is divided into several business domains.

---

# 1. Users Domain

Represents authenticated users of the platform.

Responsibilities:

* authentication
* customer accounts
* order ownership
* cart ownership

Main table:

* users

Relationships:

* users → carts
* users → orders

Business rules:

* a user may have multiple historical orders
* a user may have one active cart
* orders belong permanently to the user

---

# 2. Products Domain

Represents products available in the bakery catalog.

Main tables:

* products
* categories

Features:

* product catalog
* stock management
* ratings
* tags
* ingredients
* product visibility
* customizable products

Relationships:

* category → products
* product → cart_items
* product → order_items

Business rules:

* products may be active/inactive
* products may support customization
* stock can never become negative
* deleted products should preserve historical order integrity

Important:
Order history must preserve original pricing even if the product changes later.

---

# 3. Cart Domain

Represents temporary shopping sessions.

Main tables:

* carts
* cart_items
* audit_carts

Responsibilities:

* temporary item storage
* subtotal calculation
* cart lifecycle
* cart audit trail

Cart states:

* active
* converted
* abandoned

Relationships:

* cart → cart_items
* cart belongs to user

Business rules:

* carts are mutable
* active carts can be modified
* converted carts become immutable
* stock validation occurs before order creation

Important:
Cart is NOT a historical entity.
It represents temporary transactional state.

---

# 4. Orders Domain

Represents finalized ecommerce transactions.

Main tables:

* orders
* order_items
* audit_orders

Responsibilities:

* historical order records
* order lifecycle
* operational status tracking
* financial consistency

Order states:

* pending
* approved
* in_production
* ready
* delivered
* cancelled

Relationships:

* order → order_items
* order → production_stage
* order → audit_orders

Business rules:

* orders are immutable historical records
* orders preserve original prices
* delivered orders cannot be cancelled
* cancelled orders restore stock when applicable

Important:
Orders represent finalized business transactions.
They must maintain historical integrity permanently.

---

# 5. Custom Orders Domain

Represents personalized cakes.

Main table:

* custom_orders

Customization entities:

* sizes
* flavors
* fillings
* frostings
* decorations

Responsibilities:

* custom cake configuration
* dynamic pricing
* production customization

Relationships:

* custom_order belongs to order
* custom_order references customization entities

Business rules:

* custom orders calculate prices dynamically
* customization entities may affect total price
* custom orders are linked to finalized orders

Important:
Custom orders are NOT independent orders.
They extend the main order entity.

---

# 6. Production Domain

Represents bakery production workflow.

Main table:

* production_stages

Production states:

* queued
* ingredients_prepared
* baking
* decorating
* packaging
* completed

Responsibilities:

* operational production tracking
* bakery workflow visibility
* production status progression

Business rules:

* production follows ordered workflow stages
* completed production implies operational readiness
* production stages should remain auditable

Important:
Production is an operational workflow domain,
not a sales domain.

---

# 7. Audit Domain

Represents system traceability and historical accountability.

Main tables:

* audit_orders
* audit_carts

Responsibilities:

* track critical changes
* preserve operational history
* provide accountability
* support debugging and analytics

Business rules:

* audit records are immutable
* audit records should never be edited manually
* all critical transitions must generate audit entries

Audit events include:

* cart modifications
* order state changes
* cancellations
* operational transitions

---

# Transactional Rules

The system must guarantee:

* ACID transactions
* rollback on failures
* stock consistency
* order integrity
* audit traceability

Critical operations:

* order creation
* stock updates
* cart conversion
* cancellations

---

# Stock Rules

Stock management rules:

* stock cannot become negative
* stock decreases only during order creation
* stock restoration occurs only on valid cancellation
* cart operations do NOT reserve stock permanently
* stock validation must occur before conversion to order

Concurrency protection:

* critical stock operations should use row locking
* avoid overselling scenarios

---

# Order Lifecycle

Valid transitions:

pending → approved

approved → in_production

in_production → ready

ready → delivered

Cancellation allowed only from:

* pending
* approved

Invalid transitions must be rejected.

---

# SQL Architecture

The SQL layer is divided into:

* Stored Procedures
* SQL Functions
* Triggers

Goals:

* business rule enforcement
* transactional integrity
* automatic auditing
* operational consistency
* centralized database logic

---

# Admin Panel Domains

Admin panel modules include:

* dashboard
* products
* categories
* orders
* custom orders
* production tracking
* users
* reports
* auditing

UI philosophy:

* enterprise-grade
* operational clarity
* minimalistic design
* reusable components
* scalable architecture

---

# Engineering Standards

The project follows:

* modular architecture
* reusable components
* service-oriented frontend
* transactional SQL patterns
* audit-first mentality
* domain separation
* scalable ecommerce principles

The objective is long-term maintainability and production-grade reliability.
