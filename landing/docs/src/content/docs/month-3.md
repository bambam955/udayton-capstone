---
title: Month 3
description: Month 3 progress updates for the BizRush project.
---

## Goals for the Month

> Complete system integration across the mobile apps, admin dashboard, backend API, and database.

> Stabilize the development workflow with CI automation and improved code quality checks.

> Improve end-to-end reliability and app usability by fixing integration bugs and refining UX.

## Work Completed

> Connected the backend API to both mobile apps through a shared Flutter API client and resolved key integration issues discovered during testing.

> Connected the admin dashboard to live backend data, including users and orders.

> Implemented and refined GitHub Actions CI workflows for apps, API, and API mocks.

> Automated SQL mock-data seeding and adjusted seed depth to improve repeatable local and CI testing.

> Continued system integration work in Week 9, including bug fixes and UX-focused improvements across the apps.

> Began SQL linting improvements (SQLfluff) as part of code quality standardization.

## Challenges / Blockers

Month 3 included several integration and environment blockers. The team faced friction connecting mobile apps to the backend, especially around Android emulator localhost networking. Additional effort was required to make SQL seeding temporary, automatic, and CI-friendly. As quality gates were added, bringing older code up to CI and linting standards also took time. In Week 9, long-lived pull requests introduced merge conflicts that slowed some integration tasks.

## Key Learnings

Month 3 reinforced that integration should be treated as a primary development stream, not a final step. Connecting frontend, backend, and infrastructure early exposed workflow and environment issues sooner, which helped prioritize the right Jira follow-ups. The team also learned that automated seeding, CI checks, and linting significantly reduce manual setup overhead and make regression risk easier to manage as the codebase grows.

## Next Steps

Alex:

- Continue improving the public website and project testing coverage.

Tidiane:

- Prioritize and implement one high-impact remaining feature from the Month 3 backlog.

Bennett:

- Finalize reliable localhost passthrough and deployment workflow for Android testing and backend connectivity.
- Continue frontend-backend bug fixes and UX refinements identified during integration.
