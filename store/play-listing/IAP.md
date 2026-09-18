# Google Play IAP — MilieuAlert premium

Store listing stays **Free**. Unlock after the 15-day trial is an in-app **subscription**.

## Product to create in Play Console

| Field | Value |
|---|---|
| Product ID | `milieualert_premium_2_99` |
| Type | **Subscription** (preferred, matches Gestione Semplificata monthly billing). One-time unlock at 2.99 EUR is acceptable for a first listing if subscriptions are not ready. |
| Name | MilieuAlert Premium |
| Description | Sblocca milieuzone, autovelox/flitsers, EcoEntry, AI, POI e community. |
| Price | **2.99 EUR / month** |
| Base plan ID (if subscription) | `monthly` |
| Grace period | Play default |
| Package | `com.milieuzone.milieu_alert` |

Until the product exists in Console, the Pay button:

1. Tries Play Billing (`queryProductDetails`).
2. If the product is missing, opens Gestione Semplificata checkout (`https://gestionesemplificata.com/prodotti#milieualert`).
3. Web PWA never uses Play Billing: same GS checkout + redeem code (`POST /api/billing/redeem`).
4. Admin / GS can grant premium with `POST /api/billing/grant` (`x-billing-admin-key`).

## Trial

Day 0 starts at the **earliest** of first account `created_at` / first app open (`trial_started_at` in SharedPreferences + `users.trial_started_at`). After 15 days, unpaid users keep only the basic navigator (map, A–B, heading-up, meters). Complimentary emails (Stefano, Giancarlo Borzi, Roberto Dasso, admin) stay full access (`plan=comp`).
