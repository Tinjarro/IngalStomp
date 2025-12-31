# IngalStomp

IngalStomp tracks **successful War Stomp activations**, not button presses.  
The addon is designed to avoid inflated or incorrect counts caused by UI quirks, reload behavior, or cooldown ambiguity, and only records a stomp when there is both a clear attempt signal and confirmation that the ability actually fired.

---

## Counters

IngalStomp maintains two counters:

- **Current**: stomps since the last reset  
- **Lifetime**: stomps across all sessions  

Both counters persist through reloads and logouts.

---

## How IngalStomp Detects War Stomp

IngalStomp relies on two pieces of information:

1. **Attempt signal** – the addon must know that War Stomp was attempted  
2. **Success confirmation** – the addon confirms the stomp by observing the War Stomp cooldown transition  

This approach prioritizes correctness over guesswork.

---

## War Stomp and Macros (Important)

### Why macros can behave differently

In the vanilla WoW client, some macro patterns do not reliably expose an attempt signal to addons. When this happens:

- War Stomp may fire successfully  
- The cooldown may start  
- **IngalStomp may not record the stomp**

This is a limitation of the client, not a bug in IngalStomp.

---

### Required Macro Format

If you cast War Stomp using a macro, include the following line so IngalStomp receives an explicit attempt signal:

```
#showtooltip War Stomp
/cast War Stomp
/run if IngalStomp_MacroAttempt then IngalStomp_MacroAttempt() end
```

The `/run` line only signals that an attempt occurred. IngalStomp still independently confirms that the stomp actually fired.

---

### If the `/run` Line Is Missing

- War Stomp may still fire in game  
- The cooldown may still start  
- **IngalStomp may not count it**

This behavior is expected.

---

## Announcements

Announcements are optional and fully configurable. Disabling announcements does not stop the counter.

### Milestones

Supported milestone announcements:

- **1**
- **5**
- **10**
- **20**
- **50**
- **100**

Milestones can apply to the Current counter, the Lifetime counter, or both.

---

### Announcement Commands

```
/stomp announce on
/stomp announce off
```

Enable or disable all announcements.

```
/stomp announce current on
/stomp announce current off
```

Enable or disable announcements for the **Current** counter only.

```
/stomp announce lifetime on
/stomp announce lifetime off
```

Enable or disable announcements for the **Lifetime** counter only.

---

## Reset Behavior

IngalStomp supports **manual** and **automatic** reset modes for the Current counter.  
The Lifetime counter is never reset automatically.

```
/stomp resetmode manual
/stomp resetmode auto
/stomp resetmode
```

---

### Manual Reset Commands

```
/stomp reset
```

Resets the **Current** counter only.

```
/stomp lifetimereset
```

Resets the **Lifetime** counter.

This command is intentionally explicit to prevent accidental data loss.

---

## Persistence

The following values are saved between sessions:

- Current stomp count  
- Lifetime stomp count  
- Announcement settings (current, lifetime)  
- Milestone configuration  
- Reset mode  


## Notes

If a stomp did not count, the most likely cause is that the addon never received an attempt signal, or the stomp did not successfully complete.

