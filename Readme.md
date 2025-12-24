\# IngalStomp v1.6 (Turtle WoW 1.12)



IngalStomp counts \*\*your successful War Stomp activations\*\* and announces each stomp with a randomized yell.  

Counts persist across reloads and logouts. Reset is manual only.



This addon is intentionally minimal and deterministic.



---



\## What Gets Counted



A War Stomp is counted \*\*only when all of the following occur\*\*:



\- War Stomp is activated from an \*\*action bar button\*\*

\- The cast \*\*successfully completes\*\*

\- The War Stomp \*\*cooldown begins\*\*



The addon does not count attempts.  

It counts \*\*confirmed executions\*\*, using the cooldown transition as the authoritative signal.



This avoids false positives caused by:

\- canceled casts

\- movement interrupts

\- cooldown-locked presses

\- client-side spell attempts that never resolve



---



\## What Does NOT Get Counted (By Design)



The following \*\*will not\*\* increment the counter:



\- `/cast War Stomp` macros

\- Spellbook clicks

\- Any cast that does not pass through `UseAction`



If War Stomp is not bound to an action bar button, it will not be counted.



This limitation is intentional and documented.  

Accuracy is prioritized over coverage.



---



\## Why This Design Exists



Turtle WoW (1.12) does not provide a reliable, universal “spell succeeded” event for War Stomp.



Cooldown state is the only stable, authoritative signal available without:

\- combat log guesswork

\- SuperWoW dependencies

\- cast-completion heuristics

\- double-count risk



Using `UseAction` as the attempt gate ensures:

\- zero duplicate counts

\- zero false positives

\- predictable behavior under latency

\- consistent results across sessions



---



\## Commands



\- `/stomp`  

&nbsp; Displays the current War Stomp count.



\- `/stomp reset`  

&nbsp; Resets the count to zero.



\- `/stomp debug`  

&nbsp; Toggles debug output.



---



\## Saved Variables



\- `INGALSTOMP\_DB.count`  

&nbsp; Persistent stomp count.



\- `INGALSTOMP\_DB.debug`  

&nbsp; Debug output toggle.



---



\## Scope



IngalStomp does one thing:

It counts \*\*your\*\* War Stomps, cleanly and honestly.



If you want broader spell tracking, macro compatibility, or speculative detection, this addon is not trying to be that.



