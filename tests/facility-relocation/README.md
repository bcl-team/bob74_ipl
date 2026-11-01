# Facility relocation regression test

Run this directory as a separate local FiveM resource, with `bob74_ipl` available under that
resource name. For example, junction `resources/facility-relocation-test` to this directory,
then run `refresh` and `ensure facility-relocation-test` in the local server console.

The test compiles the actual Facility source with the FiveM Lua parser (including model-hash
literals). All game-native calls are mocked: it does not move players, load IPLs, or change
live interior settings. No client connection is required.

It checks dynamic interior resolution, the new/retired IPL identities, all 23 default
decoration calls targeting the resolved ID, translated privacy-control lookups, re-resolution
when IDs change, explicit rejection of a missing MLO, and the bounded initialization timeout.

Expected output: `[SHELTER-LUA-TEST] PASS`. Stop the test resource after running it. This is not
a substitute for checking the actual streamed mapping and transitions with a game client.
