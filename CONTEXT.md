# Context

Domain language for this codebase. Update it as terms get resolved.

## Glossary

### User
A person with an account. Curators (`has_role?(:guide)`) publish places,
collections and articles; admins run the back office. A user has a public
profile at `/u/:slug`, with `full_name`, `bio`, `city`, `country`, `interests`
and an avatar.

`slug` is generated from `full_name` on create, with a numeric suffix on
collision. `to_param` returns the slug, so URLs are readable.

### Place
A single venue: `title`, `url`, a rich-text `description`, an optional photo,
and an owner (`user`). Places belong to one curator but can appear in several
collections.

### GooglePlace
Google Places metadata attached to a `Place`, fetched asynchronously after
create (`FetchGooglePlaceIdJob`, then `FetchGooglePlaceMetadataJob`). Holds the
external id and a `metadata` JSON blob — coordinates, opening hours, photos.

The coordinates already in this table are what a map view would be built on.

### Collection
An ordered group of places published by one curator — the "guide" a reader
buys. Status is `draft`, `public` or `paid`.

A `paid` collection has a `Collection::Price` and is only readable through a
purchased `CollectionLink`.

### Collection::Price
The Stripe side of a paid collection: `price` in cents, `currency`, and the
`stripe_id` of a Stripe Price. Prices are pushed to Stripe by
`Collections::Prices::SyncToProviderJob`, not created by hand in the dashboard.

### CollectionLink
A short, shareable token (`/c/:link`) pointing at a collection, with a
`views_count` and a QR code. Two kinds matter:

- a `paid` link, created with every collection, which is what a buyer receives
  after checkout — the purchased tokens are held in the reader's session
- ordinary share links

This is the existing access-control mechanism: the reader does not log in to
read a purchased collection, they hold a link.

### PaymentInfo
A curator's Stripe product, one row per `charge_type` (`donation_purchase`,
`collection_purchase`). Holds `stripe_product_id`. Payments and prices hang off
it.

Stripe is set up as a **single platform account**, not Connect. Money lands in
the platform account; paying curators out is a manual, off-platform step.

### Payment / Payment::Status
A completed charge, with a status history (`Payment::Status`, one row per
transition, `last: true` on the current one).

### BlogPost
An article: `title`, `slug`, `content`, `locale`, `published`, `published_at`,
SEO `meta_description` and `meta_keywords`, and — for now — a plain-string
`author_name`.

`author_name` is a string, not an association. That is a known gap.

### Waitlist
Someone who asked to be let in before they have an account: `email`, `city`,
`country`, `reason`, `status`. Approving or rejecting one sends mail through
`WaitlistMailer` via `WaitlistStatusProcessorJob`.

## Conventions

- **Services** are single-purpose classes named for the action —
  `Collections::UpsertService`, `Stripe::ProductPriceService`. Controllers stay
  thin and call one.
- **ViewComponents** carry most of the UI. A component owns its own logic; views
  mostly compose components.
- **Jobs** wrap anything that talks to a third party, so a slow or failing
  provider never blocks a request.
- **Administrate dashboards** in `app/dashboards/` configure the back office. A
  non-technical editor uses it daily — new fields should show up there.
- **Tests** are RSpec with FactoryBot factories. Request specs for controllers,
  plain specs for services and components.

## Not in this codebase

Tours, bookings, availability, refunds of bookings, tipping, payouts, agencies,
invites and events exist in the production application but have been removed
here. Do not try to reintroduce them.
