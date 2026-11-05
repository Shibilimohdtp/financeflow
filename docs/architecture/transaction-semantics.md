# Transaction semantics (ADR)

## Decision

`TransactionType` remains in storage for compatibility and coarse filtering. New
ledger entries additionally carry an explicit `TransactionPurpose`, an account
movement direction, typed links to the domain record they affect, and monetary
components. Business logic uses `effectivePurpose`, never merchant/category text.

The purposes distinguish earned income and consumption expense from internal
transfers, lending/borrowing, personal-debt repayment, loan disbursement and
repayment, investment purchase/redemption, adjustment, and legacy cash.

`FinancialOperationService` is the application boundary for linked operations.
It validates owned-account endpoints and component totals, then writes the
transaction and its EMI/debt allocation in one Isar write transaction. The
transaction is the owner of linked current-period ledger operations. Reversing
it removes its allocations and recalculates the affected loan/debt status.
Deleting a linked allocation from its feature deletes the owning transaction;
historical status-only EMI payments have no transaction link and can be removed
without changing the ledger.

## Invariants

- Internal transfers have two distinct, active owned accounts and no income or
  consumption-expense effect.
- Lending/borrowing and principal repayments move cash and a receivable or
  liability, but do not become income/expense.
- Loan payment components equal the transaction amount within one minor unit.
  The **full** loan repayment (principal + interest + fees) counts as spending
  and as cash outflow (owner decision 2026-11-05). The principal component is
  still reported separately as debt principal paid.
- Investment principal is investing cash flow, not consumption. Fees are
  consumption expense. Redemption proceeds are cash inflow; only an explicitly
  supplied gain component can be reported as income.
- Cash is an account type. The old `cash` transaction value maps to
  `legacyCash` and remains visible for review.
- IDs are stable idempotency keys. EMI and debt allocations carry indexed
  transaction IDs, preventing retries from producing duplicates.
- Money comparisons use `MoneyMath` minor-unit tolerance.
- A scheduled-payment ledger transaction allocates to exactly one installment.
  The UI deliberately rejects multi-installment/prepayment allocation because a
  single transaction-level component split cannot accurately describe several
  amortization rows. Such payments can be recorded as unlinked loan cash flow
  until a first-class allocation-list model is introduced.

## Compatibility and migration

New Isar fields are nullable/defaulted. Old transfers with both endpoints retain
internal-transfer semantics. Old income/expense/investment records receive a
deterministic effective purpose at read time. Old loan/EMI entries remain
unlinked. Old cash entries remain `legacyCash`; totals keep the former outflow
behavior but the UI identifies them as needing review. No matching is attempted
from merchant text. Older backups omit the fields and use the same deterministic
fallbacks. New backups preserve all semantic/link/component fields.

Editing a legacy unlinked EMI exposes the tracked-loan selector, which is the
explicit repair flow. Saving through that flow validates the expected scheduled
amount and creates the typed allocation; the migration never guesses a loan.
