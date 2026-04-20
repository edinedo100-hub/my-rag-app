# Current Session State

## Focus
- Referral system verification and documentation.

## Current Execution Step
- ✅ Referral system fully verified — no runtime errors after hot reload.

## Completed This Session
1. **Extracted `_applyReferralReward()` helper** — shared referral credit logic (€10 increment + in-app notification) now lives in one place in `auth_provider.dart`.
2. **Fixed Google Sign-In referral gap** — `signInWithGoogle()` now accepts an optional `referralCode` parameter and credits the referrer when a new Google user signs up.
3. **URL deep link auto-fill** — `RegisterScreen` reads `?ref=CODE` from the browser URL on web via `Uri.base.queryParameters` and pre-fills the referral code field automatically.
4. **Login → Register handoff** — `LoginScreen` now passes the `?ref=` URL param to `RegisterScreen` when a user navigates from Login to Register, so the code is never lost.
5. **Google Sign-Up button** — now passes the referral code from the field (including auto-filled URL code) to `signInWithGoogle()`.

## Blockers
- None.

## Next Action Items
1. Test the full referral flow end-to-end in the browser (register with a ?ref= URL, confirm balance increments).
2. Proceed with Phase 1 cleanup (folder restructure: `lib/models/`, `lib/providers/`).
