# IngalStomp

IngalStomp tracks **successful War Stomp usage**, not button presses. The addon intentionally avoids guessing based on combat log noise or global cooldown artifacts, and only records stomps when there is clear confirmation that the ability actually fired.

---

## How IngalStomp Detects War Stomp

IngalStomp works in two stages:

1. **Attempt detection** – the addon detects that War Stomp was attempted.
2. **Success confirmation** – the addon confirms the stomp by observing the War Stomp cooldown transition.

When War Stomp is triggered from a normal **action bar button** (clicked or keybound), the vanilla client reliably exposes the attempt, and IngalStomp works automatically.

---

## War Stomp and Macros (Important)

### Why macros behave differently

In vanilla WoW, a macro using:

```
/cast War Stomp
```

**does not always pass through the action system** (`UseAction`). In some cases, the spell is cast internally without exposing an attempt event to addons.

When this happens:
- War Stomp may fire successfully
- The cooldown may start
- **IngalStomp may not record the stomp**

This is a limitation of the vanilla client, not a bug in IngalStomp.

---

## Required Macro Format

If you cast War Stomp using a macro, you must include the following line so IngalStomp knows an attempt occurred:

```
#showtooltip War Stomp
/cast War Stomp
/run if IngalStomp_MacroAttempt then IngalStomp_MacroAttempt() end
```

This `/run` line simply notifies IngalStomp that a War Stomp attempt just happened. The addon still independently confirms success by checking the cooldown transition.

---

## What Happens If the `/run` Line Is Missing

- The stomp may still fire in game
- The cooldown may still start
- **IngalStomp may not count it**

This behavior is expected and cannot be solved cleanly in vanilla without additional APIs.

---

## Why IngalStomp Does Not Guess from Cooldown Alone

IngalStomp intentionally avoids counting based only on cooldown state. Doing so would introduce false positives caused by:

- Global cooldown reflections
- UI refreshes or reloads
- Entering the world while already on cooldown

Requiring an explicit attempt signal ensures accuracy and prevents inflated counts.

---

## Summary

- Action bar usage works automatically
- Macro usage **requires** the `/run` line
- This is a vanilla limitation, not an addon bug
- IngalStomp favors correctness over guesswork

