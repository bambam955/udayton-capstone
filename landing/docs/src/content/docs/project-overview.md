---
title: Project Overview
description: BizRush is a pickup-to-delivery marketplace capstone project that now includes mobile apps, a backend API, an admin dashboard, database infrastructure, CI workflows, and supporting design documentation.
---

## Project Goal

The goal of BizRush is to build a pickup-to-delivery marketplace where store employees handle item selection and staging while drivers focus only on pickup and last-mile delivery. This operating model is intended to reduce the order inaccuracies and fulfillment issues that happen when delivery drivers are also responsible for shopping.

## Problem We Are Solving

Traditional delivery workflows often put shopping and delivery on the same person. That leads to incorrect substitutions, missing items, and inconsistent fulfillment, especially when orders are time-sensitive. BizRush addresses that gap by separating fulfillment responsibilities: retailers prepare the order, BizRush coordinates the workflow, and drivers complete delivery.

## Current Project State

BizRush has moved beyond the initial planning stage and is now an integrated multi-application MVP-in-progress. Based on the Month 1 through Month 3 updates, the project currently includes:

- a public-facing Astro documentation site
- customer and driver Flutter applications with initial and evolving UI
- a shared Flutter package for common client infrastructure
- a backend Express API connected to the apps
- a SQL database schema with migrations and seeded mock data
- a containerized local environment for backend services and admin tooling
- an admin dashboard connected to live backend data
- CI automation and code-quality improvements across major components

## Team Roles

Lead Developer: Bennett Moore 
> Mobile apps and mocked APIs

Associate Developer: Tidiane Dia
> Admin platform and public docs

Associate Developer: Alex Testa
> Backend API/DB

## Timeline

### Month 1: 
Focused on project planning and foundation setup. Key outcomes included the Statement of Work, the core BizRush operating model, the initial Flutter project structure, the public documentation site, and early admin/test platform work.

### Month 2: 
Focused on core system construction. The team built the initial SQL schema, containerized major services, created Walmart and Target mocks, built early mobile UI, added Mapbox to the driver app, created a shared Flutter package, and expanded the formal design artifacts.

### Month 3: 
Focused on integration and stabilization. The team connected the backend to the mobile apps, connected the admin dashboard to live backend data, added CI workflows, improved SQL seeding for local and CI environments, and continued integration bug fixes and UX refinements.

## Current Progress Summary

The project has progressed in three clear phases:

1. Foundation: scope definition, architecture planning, documentation setup, and initial app scaffolding.
2. Build-out: database design, mock integrations, Dockerized services, mobile UI work, and shared application infrastructure.
3. Integration: live API connections, admin dashboard data wiring, CI automation, seeded testing improvements, and reliability work.

That means the project is no longer just a concept with diagrams. It now has working code across documentation, mobile, backend, admin, database, and test/deployment workflows.

## Success Metrics

### Completed Success So Far

Success so far is measured by completed deliverables across all three months:

- a finalized and implemented system direction from the Statement of Work
- a functioning documentation site that tracks project progress
- mobile applications with role-specific UI and shared infrastructure
- a backend API integrated with the mobile clients
- an admin dashboard integrated with backend data
- a working SQL schema, migrations, and repeatable seed workflow
- retailer simulation through Mockoon-based mock APIs
- CI and linting improvements that make the system more repeatable and testable

### Remaining Success Criteria

The remaining measure of success is end-to-end polish and completion of the MVP workflow. That includes:

- stable customer and driver experiences backed by the integrated API
- reliable order, delivery, and admin operations across the full stack
- deployment readiness for backend services, web-hosted frontend targets, and admin tooling
- continued bug fixing, UX refinement, and broader testing coverage
