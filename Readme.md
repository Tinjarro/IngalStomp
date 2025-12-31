# IngalStomp

IngalStomp tracks **successful War Stomp activations**, not button presses. It is designed to avoid inflated counts from UI quirks, reload behavior, or cooldown ambiguity, and only records a stomp when it has both an attempt signal and a success confirmation.

## Counters

IngalStomp maintains two counters:

- **Current**: stomps since the last reset  
- **Lifetime**: stomps across all sessions  

Both counters persist through reloads and logouts.

## How detection works

IngalStomp uses two pieces of information:

1. **Attempt signal**, the addon needs to know you tried to War Stomp
2. **Success confirmation**, the addon confirms the stomp by observing the War Stomp cooldown transition

This design prioritizes correctness over counting every edge case.

## War Stomp and macros

### Why macros can fail to count

Some macro patterns in the vanilla client do not reliably expose an attempt signal to addons. When the addon does not see an attempt, it will not count the stomp, even if the ability fired and the cooldown started.

This is a client limitation, not an addon bug.

### Required macro format

If you cast War Stomp using a macro, include this line so IngalStomp receives an explicit attempt signal:




