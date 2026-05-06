# BillAPP v0.1 MVP Design

Date: 2026-05-06
Status: Draft for user review

## 1. Product Direction

BillAPP v0.1 is a local-first, minimal mobile bookkeeping app. The product goal is to let a user record a normal expense in about 3 seconds.

The MVP focuses on one core habit: open the app, enter an amount, choose a category, and save. It avoids account login, cloud sync, custom categories, budget management, and AI classification in the first version.

## 2. Target Experience

The main screen is the primary workspace. When the user opens the app, the amount input is immediately ready. The default transaction type is expense. The user enters an amount, selects a fixed category, and saves the transaction.

After saving, the app clears the input and refreshes the recent transaction list. The user should be able to confirm the record without leaving the main screen.

## 3. MVP Scope

### Included

- Fast transaction creation
- Expense and income transaction types
- Fixed system categories
- Recent transaction list
- Transaction detail, edit, and delete
- Monthly income, expense, and balance summary
- Expense category ranking
- Recent 7-day spending trend
- Local SQLite storage
- Manual CSV export
- Manual JSON export
- Default account stored in the data model but not emphasized in the UI

### Excluded From v0.1

- Account registration and login
- Cloud sync
- Budget management
- Asset and account management UI
- Custom category creation or editing
- AI classification
- Receipt image recognition
- Multi-person or family ledger

## 4. Navigation And Pages

The app uses a lightweight bottom navigation with three tabs:

- Record
- Statistics
- Settings

The bill list appears on the Record screen as a recent transactions section instead of becoming a separate tab. This keeps the first version focused and light.

### Record Screen

The Record screen contains:

- Amount input
- Expense/income switch, defaulting to expense
- Fixed category grid
- Optional note entry
- Save action
- Recent 10 transactions

### Statistics Screen

The Statistics screen contains:

- Current month income
- Current month expense
- Current month balance
- Expense category ranking
- Recent 7-day spending trend
- Empty state when no transaction data exists

### Settings Screen

The Settings screen contains:

- Export CSV
- Export JSON
- Privacy/data storage explanation
- Basic app information

## 5. Functional Requirements

### Fast Transaction Creation

The user can create a transaction with:

- Type: expense or income
- Amount: required, greater than zero
- Category: required
- Note: optional
- Occurred time: defaults to current time
- Account: stored as the default account in v0.1

Saving a transaction must:

- Persist it locally
- Clear the amount input
- Reset the note input
- Refresh the recent transaction list
- Keep the user on the Record screen

### Fixed Categories

Expense categories use stable internal IDs and Simplified Chinese display names:

- `food`: 餐饮
- `transport`: 交通
- `shopping`: 购物
- `entertainment`: 娱乐
- `housing`: 住房
- `medical`: 医疗
- `education`: 学习
- `other_expense`: 其他

Income categories use stable internal IDs and Simplified Chinese display names:

- `salary`: 工资
- `part_time`: 兼职
- `investment`: 理财
- `gift`: 礼金
- `other_income`: 其他

The first version does not support category creation, deletion, editing, or sorting.

### Transaction Records

The app shows the latest 10 transactions on the Record screen. A user can open a transaction detail view and edit:

- Amount
- Type
- Category
- Note
- Occurred time

The user can delete a transaction after a confirmation prompt.

### Statistics

The app calculates statistics from local transaction records:

- Monthly income
- Monthly expense
- Monthly balance
- Expense total by category
- Recent 7-day expense trend

Statistics must be consistent with the underlying transactions.

### Export Backup

The app supports manual export in CSV and JSON formats.

Exported fields:

- id
- type
- amount
- amountMinor
- categoryId
- categoryName
- accountId
- note
- occurredAt
- createdAt
- updatedAt

The exported data must be parseable and complete enough for future restore/import support, although import is not part of v0.1.

## 6. Non-Functional Requirements

- Core features must work offline.
- Data must persist after app restart.
- Money calculations must avoid floating-point precision errors.
- The first version defaults to CNY and stores amounts as integer fen.
- The first version uses Simplified Chinese UI text.
- Database IDs and enum values use stable English keys; UI display names use Simplified Chinese.
- Local data should remain on the device unless the user explicitly exports it.
- Main record creation should feel immediate on ordinary mobile devices.
- Empty and error states should be understandable without lengthy explanations.

## 7. Acceptance Criteria

- A user can create a no-note expense from app launch in about 3 seconds.
- The app prevents saving empty, zero, or negative amounts.
- The app prevents saving without a category.
- The recent transaction list updates after creation, editing, and deletion.
- Deleting a transaction requires confirmation.
- The app remains usable without network access.
- Transactions remain after the app restarts.
- Monthly statistics match the transaction data.
- CSV and JSON exports include all required fields.

## 8. Recommended Technical Stack

The recommended stack is Flutter with Drift and SQLite.

Reasons:

- Flutter provides stable cross-platform mobile development for iOS and Android.
- SQLite is reliable for local-first bookkeeping data.
- Drift provides typed queries, migrations, and testable database access.
- The first version does not need a backend service.

React Native with Expo and SQLite is a viable alternative if the project later prioritizes a JavaScript/React ecosystem, but Flutter is the preferred option for this MVP.

## 9. Architecture

The app should use a simple layered architecture.

### Presentation

Responsible for UI and user interactions:

- Record screen
- Statistics screen
- Settings screen
- Transaction detail/edit view

### Application

Responsible for use cases:

- CreateTransactionUseCase
- UpdateTransactionUseCase
- DeleteTransactionUseCase
- GetRecentTransactionsUseCase
- GetMonthlyStatsUseCase
- ExportBackupUseCase

### Domain

Responsible for business concepts and validation:

- Transaction
- Category
- Account
- Money
- TransactionType

Rules:

- Amount must be greater than zero.
- Category must exist and match the transaction type.
- Occurred time is required.
- Money is stored as minor units.

### Data

Responsible for persistence and export:

- SQLite database
- Drift tables and DAOs
- Repositories
- Seed data
- Database migrations
- CSV exporter
- JSON exporter

## 10. Data Model

### transactions

- id: string
- type: expense or income
- amountMinor: integer
- categoryId: string
- accountId: string
- note: nullable string
- occurredAt: datetime
- createdAt: datetime
- updatedAt: datetime
- deletedAt: nullable datetime

### categories

- id: string
- type: expense or income
- name: string
- icon: string
- sortOrder: integer
- isSystem: boolean

### accounts

- id: string
- name: string
- type: string
- isDefault: boolean
- createdAt: datetime
- updatedAt: datetime

v0.1 initializes one default account. The UI does not need account selection yet.

## 11. Suggested Repository Structure

```text
lib/
  app/
  features/
    transactions/
      presentation/
      application/
      domain/
      data/
    statistics/
    settings/
    backup/
  shared/
    database/
    money/
    time/
test/
docs/
  research/
  prd/
  technical-design/
  ai-agents/
  iterations/
```

## 12. Testing Strategy

### Unit Tests

- Money validation and formatting
- Transaction validation
- Category matching by transaction type
- Monthly statistics calculations
- Export data mapping

### Repository Tests

- Create transaction
- Update transaction
- Delete transaction
- Query latest transactions
- Query monthly transactions

### UI Tests

- Enter amount
- Select category
- Save transaction
- See recent transaction update
- Block invalid amount save

### Export Tests

- CSV contains required headers and rows
- JSON contains required fields
- Exported amount values are consistent with stored minor units

## 13. AI Agent Workflow

The project should use specialized AI agents with clear responsibilities.

### Research Agent

Produces:

- User pain points
- Competitor notes
- MVP opportunities
- Product risks and assumptions

### Product Agent

Produces:

- PRD
- User stories
- Functional scope
- Page flows
- Acceptance criteria

### UX Agent

Produces:

- Information architecture
- Main user flows
- Empty states
- Error states
- Component list

### Architecture Agent

Produces:

- Technical design
- Module boundaries
- Data model
- Testing strategy
- Risk mitigation

### Implementation Agent

Produces:

- Code changes
- Tests
- Local verification notes
- Known limitations

### Review Agent

Produces:

- Blocking issues
- Non-blocking suggestions
- Missing tests
- Regression risks
- Merge recommendation

## 14. Iteration Plan

### Sprint 001

- Initialize Flutter project
- Add database foundation
- Add fixed category seed data
- Add default account
- Implement transaction creation
- Implement recent transaction list
- Add basic validation and tests

### Sprint 002

- Implement transaction editing
- Implement transaction deletion
- Implement statistics screen
- Implement CSV export
- Implement JSON export
- Implement settings screen
- Add broader tests

## 15. Open Decisions

All decisions needed for v0.1 are resolved:

- Product direction: minimal fast bookkeeping
- Main input: amount keypad first
- Account strategy: reserved in model, hidden in UI
- Category strategy: fixed system categories
- Storage strategy: local-first with manual export backup
- Recommended stack: Flutter, Drift, SQLite
