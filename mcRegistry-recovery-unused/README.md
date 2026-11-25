# Stock mcRegistry files NOT shipped in recovery (size budget)

`vendor_boot_a` is exactly 64 MiB, and the full stock mcRegistry (~34 MiB,
mostly `faceauth_ta` + trustlet `.tlbin`/`.drbin` pairs) overflowed it
(R3: 79.4 MiB image). Recovery ships only the 7 small `.tabin` registry
entries; the vienna donor (same TEE stack, working decrypt) ships an
equivalent tabin-only set with no `.tlbin`/`.drbin` at all.

- `6661...tabin` = `faceauth_ta` (20 MiB): face unlock never runs in recovery.
- `*.tlbin` / `*.drbin`: loadable trustlets for full-Android features; donor
  decrypt works without them.
- Kept (safety): `05060000....tabin` (12 MiB, unknown UUID) + the 5 tabins
  shared with the donor set + `09010203....tabin`.

If FBE decrypt fails in bring-up, restoring files from here is the first
thing to try (image has ~6 MiB of headroom).
