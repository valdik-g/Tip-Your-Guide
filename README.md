# tip_your_guide_sandbox

A trimmed copy of a working Rails application, used as the codebase for a hiring
exercise. It is a real app with real conventions — not a scaffold — but the
deploy setup, secrets and about half the domain have been removed.

The task itself is in [`ASSIGNMENT.md`](ASSIGNMENT.md).

---

## What the app does

People publish curated recommendations of places — restaurants, bars, wine shops —
and short articles about food and wine. Today a curator can:

- keep a public profile at `/u/:slug`
- add **places** (enriched from Google Places)
- group places into **collections**, which can be free or paid
- sell a paid collection through a one-off Stripe Checkout, and share it as a
  short link or QR code
- publish **articles** (`BlogPost`), which are localised and indexed for search

Admin work happens in an Administrate back office at `/admin`, used by a
non-technical editor.

---

## Setup

Requires Ruby 3.4.9 and PostgreSQL 16+.

```bash
bundle install
bin/rails db:prepare      # loads db/schema.rb — there are no migrations yet
bin/rails db:seed
bin/dev                   # Rails + Tailwind watcher
```

Then open http://localhost:3000.

### Seeded logins

| Email | Password | Role |
|---|---|---|
| `admin@example.com` | `password` | admin, sees `/admin` |
| `clara@example.com` | `password` | curator, chef in Paris |
| `tomasz@example.com` | `password` | curator, sommelier in Warsaw |

The seeds also create places, two paid collections, one free collection and five
articles. Two of the articles are deliberately written in two halves — an open
half about what to look for, and a half carrying the exact numbers.

### Tests

```bash
bundle exec rspec
```

### Linting

```bash
bundle exec standardrb --fix-unsafely
bundle exec erb_lint --lint-all --autocorrect
```

---

## Stripe

This app reads Stripe config from the environment (see
`config/initializers/stripe.rb`) — there are no encrypted credentials and no
master key in this repo, on purpose.

```bash
export STRIPE_SECRET_KEY=sk_test_...
export STRIPE_WEBHOOK_SIGNING_SECRET=whsec_...
```

Use **test keys only**.

To receive webhooks locally, install the Stripe CLI and run:

```bash
stripe listen --forward-to localhost:3000/stripe-webhooks
```

It prints the `whsec_...` signing secret to use above.

There is an existing, working example of a Stripe one-off purchase in this
codebase — start at `app/services/collections/purchases/` and
`app/controllers/collections/purchases_controller.rb`, and follow it through
`config/initializers/stripe.rb`. Whatever you build should look like it
belongs next to that code.

---

## Where to start reading

| Path | What lives there |
|---|---|
| `CONTEXT.md` | Domain glossary. Read this first |
| `app/models/` | `User`, `Place`, `Collection`, `BlogPost`, `PaymentInfo` |
| `app/services/` | Business operations, one class per action |
| `app/components/` | ViewComponents — most of the UI is here, not in views |
| `app/dashboards/` | Administrate config for the back office |
| `db/schema.rb` | The whole schema |
| `spec/` | RSpec, FactoryBot, `spec/support` for helpers |

Conventions worth matching: services are verbs (`Collections::UpsertService`),
components are nouns, and controllers stay thin. Tests use FactoryBot factories
rather than fixtures.

---

## What was removed, and why

This is a copy, not a fork. The git history is fresh and starts at one commit.

Removed because it is infrastructure you do not need: Kamal deploy configs,
Dockerfile, encrypted credentials and master key, Sentry, production database
dumps, uploaded files.

Removed because it is domain you do not need: tours, bookings, availability,
refunds, tipping, payouts, agencies and invites, events and registrations, and
the curator's back-office dashboard.

The result boots, seeds and passes its tests. If something does not work on a
clean clone, that is a bug on our side — say so and we will fix it.


---

## How to set up Stripe for Blog Subscriptions

1. Go to: https://dashboard.stripe.com
2. Sign in/Sign up
3. Go to test mode
4. Go to "Product Catalog" (left menu)
5. Click on "Create Product"
6. Fill Name, Set pricing as recuring, set amount to 7 euros, billing period as: monthly
7. Go to "Product Catalog" and click on your product
8. In price menu click on "...", and "Copy price ID"
9. Add it to your env/env file as SUBSCRIPTION_STRIPE_PRICE_ID
10. Go to "Setting->Billing->Subscriptions and emails"
11. Click "Manage" in "Card Payment" in "Manage Failed Payments"
12. Set Smart Retries to "Retry up to 8 times within 1 week"
13. Click on "Developers"
14. Copy Secret key
15. Save it to your env as STRIPE_SECRET_KEY=(only for local development)
16. To check stripe webhooks localy install stripe-cli and use: stripe listen --forward-to localhost:3000/stripe-webhooks
17. You will see a webhook signing secret key, copy it and save it to your env as STRIPE_WEBHOOK_SIGNING_SECRET