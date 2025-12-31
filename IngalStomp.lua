-- IngalStomp v1.7 (Turtle 1.12)
-- Counts YOUR successful War Stomps, persists, manual reset only, yells a random line each stomp.
-- Detection: UseAction attempt window + War Stomp spellbook cooldown transition, success only.
-- Note: By design, it only counts War Stomp activated via an action bar button, not macros or spellbook clicks.

------------------------------------------------
-- SavedVariables bootstrap (TOP OF FILE)
------------------------------------------------
if not INGALSTOMP_DB then INGALSTOMP_DB = {} end
-- IMPORTANT: Back-compat
-- Older versions stored the only counter as INGALSTOMP_DB.count.
-- We keep that exact field as the Lifetime counter so nobody loses progress.
if type(INGALSTOMP_DB.count) ~= "number" then
  -- If a newer experimental build used INGALSTOMP_DB.lifetime, migrate it once.
  if type(INGALSTOMP_DB.lifetime) == "number" then
    INGALSTOMP_DB.count = INGALSTOMP_DB.lifetime
  else
    INGALSTOMP_DB.count = 0
  end
end
-- Optional mirror for readability, kept in sync with .count
if type(INGALSTOMP_DB.lifetime) ~= "number" then INGALSTOMP_DB.lifetime = INGALSTOMP_DB.count end
-- New: resettable "Current" counter persists in DB as well, so it survives reloads even if RUN does not.
-- Back-compat: if DB.current is missing but RUN.count exists, adopt RUN.count once.
if type(INGALSTOMP_DB.current) ~= "number" then
  if INGALSTOMP_RUN and type(INGALSTOMP_RUN.count) == "number" then
    INGALSTOMP_DB.current = INGALSTOMP_RUN.count
  else
    INGALSTOMP_DB.current = 0
  end
end

-- New: reset mode applies to Current only. manual (default) never auto-resets; auto resets on zone change.
if type(INGALSTOMP_DB.resetMode) ~= "string" then INGALSTOMP_DB.resetMode = "manual" end
if type(INGALSTOMP_DB.placeKey) ~= "string" then INGALSTOMP_DB.placeKey = "" end

-- Persist settings in DB as the source of truth (RUN may not persist on some installs)
if type(INGALSTOMP_DB.debug) ~= "boolean" then INGALSTOMP_DB.debug = false end
if type(INGALSTOMP_DB.announceMode) ~= "string" then INGALSTOMP_DB.announceMode = "current" end
if type(INGALSTOMP_DB.announceEvery) ~= "number" or INGALSTOMP_DB.announceEvery < 1 then INGALSTOMP_DB.announceEvery = 1 end

-- Resettable counter + settings live in a second SavedVariable table
if not INGALSTOMP_RUN then INGALSTOMP_RUN = {} end
if type(INGALSTOMP_RUN.count) ~= "number" then INGALSTOMP_RUN.count = 0 end
if type(INGALSTOMP_RUN.debug) ~= "boolean" then INGALSTOMP_RUN.debug = false end
if type(INGALSTOMP_RUN.announce) ~= "boolean" then INGALSTOMP_RUN.announce = true end
-- Announcement mode + frequency (back-compat with older boolean announce)
if type(INGALSTOMP_RUN.announceMode) ~= "string" then
  if type(INGALSTOMP_RUN.announce) == "boolean" then
    INGALSTOMP_RUN.announceMode = INGALSTOMP_RUN.announce and "current" or "off"
  else
    INGALSTOMP_RUN.announceMode = "current"
  end
end
if type(INGALSTOMP_RUN.announceEvery) ~= "number" or INGALSTOMP_RUN.announceEvery < 1 then
  INGALSTOMP_RUN.announceEvery = 1
end

-- Sync runtime settings from DB (DB is authoritative)
INGALSTOMP_RUN.debug = (INGALSTOMP_DB.debug and true) or false
INGALSTOMP_RUN.announceMode = tostring(INGALSTOMP_DB.announceMode or "current")
INGALSTOMP_RUN.announceEvery = tonumber(INGALSTOMP_DB.announceEvery) or 1
if INGALSTOMP_RUN.announceEvery < 1 then INGALSTOMP_RUN.announceEvery = 1 end
INGALSTOMP_RUN.announce = (string.lower(tostring(INGALSTOMP_RUN.announceMode)) ~= "off")


local ADDON = "IngalStomp"

------------------------------------------------
-- Yells (ASCII only, ordinal token $O, name token $N)
------------------------------------------------
local YELLS = {
  "With this $O stomp, I make the floor my problem",
  "This $O stomp has opinions",
  "With this $O stomp, gravity files a complaint",
  "This $O stomp was unnecessary but satisfying",
  "With this $O stomp, subtlety is canceled",
  "This $O stomp asks nicely, then louder",
  "With this $O stomp, the ground learns my schedule",
  "This $O stomp arrives uninvited",
  "With this $O stomp, patience takes damage",
  "This $O stomp settles it, whatever it was",
  "With this $O stomp, the floor remembers $N",
  "This $O stomp solves nothing, confidently",
  "With this $O stomp, I test the structural integrity",
  "This $O stomp is why we cannot have nice things",
  "With this $O stomp, silence panics",
  "This $O stomp brings closure to the moment",
  "With this $O stomp, the earth sighs",
  "This $O stomp was foreseen",
  "With this $O stomp, we do it the loud way",
  "This $O stomp establishes dominance over dirt",
  "With this $O stomp, the floor gets feedback",
  "This $O stomp counts as communication",
  "With this $O stomp, the room understands",
  "This $O stomp was a warning shot",
  "With this $O stomp, physics nods politely",
  "This $O stomp did not ask permission",
  "With this $O stomp, the vibe shifts",
  "This $O stomp interrupts whatever you were doing",
  "With this $O stomp, I press the big button",
  "This $O stomp lands with intent",
  "With this $O stomp, dust is promoted",
  "This $O stomp carries authority it did not earn",
  "With this $O stomp, I announce my foot",
  "This $O stomp was not a suggestion",
  "With this $O stomp, the ground listens harder",
  "This $O stomp escalates the situation",
  "With this $O stomp, momentum files paperwork",
  "This $O stomp makes a strong point",
  "With this $O stomp, we skip the explanation",
  "This $O stomp is my final answer",
  "With this $O stomp, calm is enforced",
  "This $O stomp has main character energy",
  "With this $O stomp, the floor flinches",
  "This $O stomp declares a brief meeting",
  "With this $O stomp, I win the argument with terrain",
  "This $O stomp adds emphasis",
  "With this $O stomp, silence is applied liberally",
  "This $O stomp carries emotional weight",
  "With this $O stomp, the echo clocks in",
  "This $O stomp was legally distinct",
  "With this $O stomp, attention is redirected",
  "This $O stomp hits different",
  "With this $O stomp, the ground reconsiders",
  "This $O stomp was a lifestyle choice",
  "With this $O stomp, the air goes quiet",
  "This $O stomp settles the dust and my nerves",
  "With this $O stomp, I underline the moment",
  "This $O stomp is a punctuation mark",
  "With this $O stomp, drama is reduced to rubble",
  "This $O stomp establishes a baseline",
  "With this $O stomp, the floor cooperates",
  "This $O stomp was overdue",
  "With this $O stomp, I choose violence against silence",
  "This $O stomp lands exactly where intended",
  "With this $O stomp, chaos takes a knee",
  "This $O stomp clarifies priorities",
  "With this $O stomp, the ground takes notes",
  "This $O stomp answers questions no one asked",
  "With this $O stomp, I assert foot-based authority",
  "This $O stomp is louder than necessary",
  "With this $O stomp, tension exits the chat",
  "This $O stomp sends a message to geology",
  "With this $O stomp, the moment pauses",
  "This $O stomp marks my location aggressively",
  "With this $O stomp, I remind the floor who is boss",
  "This $O stomp is a public service",
  "With this $O stomp, everything calms down or else",
  "This $O stomp delivers emphasis in bulk",
  "With this $O stomp, the ground agrees reluctantly",
  "This $O stomp feels correct",
  "With this $O stomp, I skip the warning label",
  "This $O stomp is why we stomp",
  "With this $O stomp, the echo clocks overtime",
  "This $O stomp puts a pin in it",
  "With this $O stomp, attention is forcibly acquired",
  "This $O stomp resolves the situation audibly",
  "With this $O stomp, I commit to the bit",
  "This $O stomp lands like punctuation",
  "With this $O stomp, silence is achieved",
  "This $O stomp stands as testimony",
  "With this $O stomp, the floor has learned enough",
  "This $O stomp was extremely on purpose",
  "With this $O stomp, the floor regrets its choices",
  "This $O stomp was improvised",
  "With this $O stomp, I press the emergency foot",
  "This $O stomp arrives with confidence",
  "With this $O stomp, physics sighs deeply",
  "This $O stomp is louder in person",
  "With this $O stomp, the ground is notified",
  "This $O stomp did not read the room",
  "With this $O stomp, the echo earns hazard pay",
  "This $O stomp was a group decision",
  "With this $O stomp, the floor updates its expectations",
  "This $O stomp is sponsored by gravity",
  "With this $O stomp, subtlety leaves the area",
  "This $O stomp did its own research",
  "With this $O stomp, dirt takes emotional damage",
  "This $O stomp escalates politely",
  "With this $O stomp, I choose the loud option",
  "This $O stomp refuses to be ignored",
  "With this $O stomp, silence files a bug report",
  "This $O stomp hits like a meeting invite",
  "With this $O stomp, the vibe is adjusted",
  "This $O stomp activates floor awareness",
  "With this $O stomp, I solve it with feet",
  "This $O stomp has strong opinions",
  "With this $O stomp, the moment gets framed",
  "This $O stomp cannot be unsounded",
  "With this $O stomp, I commit fully",
  "This $O stomp lands emotionally",
  "With this $O stomp, the ground remembers today",
  "This $O stomp is a teaching moment",
  "With this $O stomp, I assert local dominance",
  "This $O stomp interrupts the soundtrack",
  "With this $O stomp, I add emphasis manually",
  "This $O stomp was avoidable but chosen",
  "With this $O stomp, attention snaps to grid",
  "This $O stomp is the loud solution",
  "With this $O stomp, the floor clocks in",
  "This $O stomp counts as feedback",
  "With this $O stomp, patience times out",
  "This $O stomp is working as intended",
  "With this $O stomp, I underline reality",
  "This $O stomp brings the noise briefly",
  "With this $O stomp, the room flinches",
  "This $O stomp is why the ground is nervous",
  "With this $O stomp, I choose impact",
  "This $O stomp recalibrates the moment",
  "With this $O stomp, the echo needs a break",
  "This $O stomp is a lifestyle update",
  "With this $O stomp, the floor pays attention",
  "This $O stomp carries authority somehow",
  "With this $O stomp, I skip the disclaimer",
  "This $O stomp feels earned",
  "With this $O stomp, the silence is enforced",
  "This $O stomp has entered the chat",
  "With this $O stomp, I mark my territory loudly",
  "This $O stomp is surprisingly effective",
  "With this $O stomp, the ground learns humility",
  "This $O stomp closes the discussion",
  "With this $O stomp, I add dramatic pause",
  "This $O stomp was extremely deliberate"
}


------------------------------------------------
-- Helpers
------------------------------------------------
local function Print(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cff00ff7f" .. ADDON .. "|r: " .. msg)
end

------------------------------------------------
-- War Stomp spellbook lookup + cooldown helper
------------------------------------------------
local STOMP_INDEX = nil
local BOOKTYPE = BOOKTYPE_SPELL or "spell"

local function FindWarStompIndex()
  STOMP_INDEX = nil
  for i = 1, 300 do
    local name = GetSpellName(i, BOOKTYPE)
    if not name then break end
    if name == "War Stomp" then
      STOMP_INDEX = i
      return
    end
  end
end

local function GetStompCooldown()
  if not STOMP_INDEX then
    return 0, 0, 0
  end
  return GetSpellCooldown(STOMP_INDEX, BOOKTYPE)
end


local function DebugPrint(msg)
  if INGALSTOMP_RUN.debug then
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd100IngalStomp-DEBUG|r: " .. msg)
  end
end

-- WoW 1.12 uses Lua 5.0, the % operator is not available, use mod() / math.mod() instead
local function SafeMod(a, b)
  a = tonumber(a) or 0
  b = tonumber(b) or 1
  if b == 0 then return 0 end
  if type(mod) == "function" then return mod(a, b) end
  if math and type(math.mod) == "function" then return math.mod(a, b) end
  if math and type(math.fmod) == "function" then return math.fmod(a, b) end
  return a - math.floor(a / b) * b
end


-- Turtle 1.12 in your environment is choking on the % operator, so use a safe integer mod
local function imod(a, b)
  return a - math.floor(a / b) * b
end

local function ordinal(n)
  n = tonumber(n) or 0

  local mod100 = imod(n, 100)
  if mod100 >= 11 and mod100 <= 13 then
    return n .. "th"
  end

  local mod10 = imod(n, 10)
  if mod10 == 1 then return n .. "st" end
  if mod10 == 2 then return n .. "nd" end
  if mod10 == 3 then return n .. "rd" end
  return n .. "th"
end

local function fmt(s, c, n)
  s = string.gsub(s, "%$O", ordinal(c or 0))
  s = string.gsub(s, "%$N", n or "Me")
  return s
end

local function pickLine()
  local n = table.getn(YELLS)
  if n < 1 then return "With this $O stomp, I count" end
  local i = math.random(1, n)
  return YELLS[i]
end

------------------------------------------------
-- Core counting, dedupe, announce
------------------------------------------------
local lastCountTime = 0
local DEDUPE_WINDOW = 0.7

local function CountAndYell(source)
  local now = GetTime()
  if (now - lastCountTime) < DEDUPE_WINDOW then
    DebugPrint("deduped")
    return
  end
  lastCountTime = now

  INGALSTOMP_RUN.count = (tonumber(INGALSTOMP_RUN.count) or 0) + 1
  INGALSTOMP_DB.current = (tonumber(INGALSTOMP_DB.current) or 0) + 1
  INGALSTOMP_DB.count = (tonumber(INGALSTOMP_DB.count) or 0) + 1
  INGALSTOMP_DB.lifetime = INGALSTOMP_DB.count

  local name = UnitName("player") or "Me"

  -- Decide what number drives announcements
  local mode = string.lower(tostring(INGALSTOMP_RUN.announceMode or "current"))
  local every = tonumber(INGALSTOMP_RUN.announceEvery) or 1
  if every < 1 then every = 1 end

  local announceCount = nil
  if mode == "off" then
    announceCount = nil
  elseif mode == "lifetime" then
    announceCount = INGALSTOMP_DB.count
  else
    -- default to current
    announceCount = INGALSTOMP_RUN.count
  end

  if announceCount and INGALSTOMP_RUN.announce and (SafeMod(announceCount, every) == 0) then
    local line = fmt(pickLine(), announceCount, name)

    -- Hard normalize any stray smart quotes if they ever sneak in again
    line = string.gsub(line, "’", "'")
    line = string.gsub(line, "“", '"')
    line = string.gsub(line, "”", '"')

    if line and line ~= "" then
      SendChatMessage(line, "YELL")
    else
      DebugPrint("empty yell string, skipped")
    end
  else
    DebugPrint("announce skipped (mode/cadence)")
  end

  if INGALSTOMP_RUN.debug then
    Print("Stomp counted " .. INGALSTOMP_RUN.count .. " (" .. (source or "?") .. ")")
  end
end

------------------------------------------------
-- Slash commands
------------------------------------------------
SLASH_INGALSTOMP1 = "/stomp"
SLASH_INGALSTOMP2 = "/ingalstomp"
SlashCmdList["INGALSTOMP"] = function(msg)
  msg = string.lower(msg or "")

  local function Status()
    local cur = tonumber(INGALSTOMP_RUN.count) or 0
    local life = tonumber(INGALSTOMP_DB.count) or 0
    local mode = string.upper(tostring(INGALSTOMP_RUN.announceMode or "current"))
    local every = tonumber(INGALSTOMP_RUN.announceEvery) or 1
    local rm = string.upper(tostring(INGALSTOMP_DB.resetMode or "manual"))
    Print("Current count: " .. cur .. " ; Lifetime count: " .. life .. " ; Announce: " .. mode .. " every " .. every .. " ; ResetMode: " .. rm)
  end

  if msg == "" or msg == "count" or msg == "counts" or msg == "report" then
    Status()
    Print("/stomp reset ; /stomp debug ; /stomp resetmode manual|auto ; /stomp announce off|current|lifetime ; /stomp announce 1|5|10|20|50|100")
    return
  end

  if msg == "reset" or msg == "clear" then
    INGALSTOMP_RUN.count = 0
    INGALSTOMP_DB.current = 0
    Print("current count reset to 0")
    Status()
    return
  end

  if msg == "debug" then
    INGALSTOMP_RUN.debug = not INGALSTOMP_RUN.debug
    INGALSTOMP_DB.debug = INGALSTOMP_RUN.debug
    Print("debug " .. (INGALSTOMP_RUN.debug and "ON" or "OFF"))
    return
  end

  if string.sub(msg, 1, 9) == "resetmode" then
    local arg = string.sub(msg, 10) or ""
    arg = string.gsub(arg, "^%s+", "")
    arg = string.lower(tostring(arg))

    if arg == "" then
      Print("resetmode " .. string.upper(tostring(INGALSTOMP_DB.resetMode or "manual")))
      return
    end

    if arg == "manual" or arg == "auto" then
      INGALSTOMP_DB.resetMode = arg
      Print("resetmode set to " .. string.upper(arg))
      Status()
      return
    end

    Print("usage: /stomp resetmode manual|auto")
    return
  end

  -- announce controls
  --   /stomp announce                (toggle off/current)
  --   /stomp announce off|current|lifetime
  --   /stomp announce on|off         (on maps to current, kept for older habits)
  --   /stomp announce 1|5|10|20|50|100  (set cadence)
  if msg == "announce" or msg == "yell" then
    local cur = string.lower(tostring(INGALSTOMP_RUN.announceMode or "current"))
    if cur == "off" then
      INGALSTOMP_RUN.announceMode = "current"
    else
      INGALSTOMP_RUN.announceMode = "off"
    end
    INGALSTOMP_RUN.announce = (INGALSTOMP_RUN.announceMode ~= "off")
    INGALSTOMP_DB.announceMode = INGALSTOMP_RUN.announceMode
    Print("announce mode " .. string.upper(INGALSTOMP_RUN.announceMode))
    Status()
    return
  end

  if string.sub(msg, 1, 9) == "announce " or string.sub(msg, 1, 5) == "yell " then
    local arg = msg
    if string.sub(msg, 1, 9) == "announce " then
      arg = string.sub(msg, 10)
    else
      arg = string.sub(msg, 6)
    end
    arg = string.lower(tostring(arg or ""))

    local n = tonumber(arg)
    if n then
      if n == 1 or n == 5 or n == 10 or n == 20 or n == 50 or n == 100 then
        INGALSTOMP_RUN.announceEvery = n
        INGALSTOMP_DB.announceEvery = n
        Print("announce cadence set to every " .. n)
        Status()
      else
        Print("invalid cadence. Use 1, 5, 10, 20, 50, or 100.")
      end
      return
    end

    if arg == "on" then arg = "current" end
    if arg == "off" or arg == "current" or arg == "lifetime" then
      INGALSTOMP_RUN.announceMode = arg
      INGALSTOMP_RUN.announce = (arg ~= "off")
      INGALSTOMP_DB.announceMode = arg
      Print("announce mode " .. string.upper(arg))
      Status()
      return
    end

    Print("usage: /stomp announce off|current|lifetime ; /stomp announce 1|5|10|20|50|100")
    return
  end

  Print("unknown command. Try /stomp")
end

------------------------------------------------
-- Attempt window (UseAction only, by design)
------------------------------------------------
local pendingUntil = 0

local function MarkAttempt()
  local now = GetTime()
  if pendingUntil <= 0 or now > pendingUntil then
    DebugPrint("attempt marked")
  end
  pendingUntil = now + 0.8
end

-- Macro support: if you cast War Stomp via a macro that bypasses UseAction,
-- call this so the addon opens its short "attempt window" and then confirms success
-- by watching the War Stomp cooldown transition.
function IngalStomp_MacroAttempt()
  MarkAttempt()
end

-- Backwards-friendly alias name
IngalStomp_MacroPing = IngalStomp_MacroAttempt

-- Hook UseAction, mark an attempt for any action press
local oldUseAction = UseAction
UseAction = function(slot, checkCursor, onSelf)
  MarkAttempt()
  return oldUseAction(slot, checkCursor, onSelf)
end

------------------------------------------------
-- Frame, events, update loop
------------------------------------------------
local lastCDStart = 0
local ticker = 0

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")

f:SetScript("OnEvent", function()
  -- In Vanilla 1.12, the current event name is in the global 'event' variable.
  if event == "PLAYER_LOGIN" then
    -- Sync Current into RUN so the existing counting/announce logic keeps working.
    -- Sync settings from DB (authoritative) into RUN
    INGALSTOMP_RUN.debug = (INGALSTOMP_DB.debug and true) or false
    INGALSTOMP_RUN.announceMode = tostring(INGALSTOMP_DB.announceMode or (INGALSTOMP_RUN.announceMode or "current"))
    INGALSTOMP_RUN.announceEvery = tonumber(INGALSTOMP_DB.announceEvery) or (tonumber(INGALSTOMP_RUN.announceEvery) or 1)
    if INGALSTOMP_RUN.announceEvery < 1 then INGALSTOMP_RUN.announceEvery = 1 end
    INGALSTOMP_RUN.announce = (string.lower(tostring(INGALSTOMP_RUN.announceMode)) ~= "off")

    if type(INGALSTOMP_DB.current) ~= "number" then INGALSTOMP_DB.current = 0 end
    INGALSTOMP_RUN.count = tonumber(INGALSTOMP_DB.current) or 0

    FindWarStompIndex()
    local s = GetStompCooldown()
    lastCDStart = s or 0

    -- Initialize place key
    local z = GetRealZoneText() or GetZoneText() or ""
    INGALSTOMP_DB.placeKey = tostring(z)

    -- Show status
    local cur = tonumber(INGALSTOMP_RUN.count) or 0
    local life = tonumber(INGALSTOMP_DB.count) or 0
    local mode = string.upper(tostring(INGALSTOMP_RUN.announceMode or "current"))
    local every = tonumber(INGALSTOMP_RUN.announceEvery) or 1
    local rm = string.upper(tostring(INGALSTOMP_DB.resetMode or "manual"))
    Print("Current count: " .. cur .. " ; Lifetime count: " .. life .. " ; Announce: " .. mode .. " every " .. every .. " ; ResetMode: " .. rm)
    Print("/stomp reset ; /stomp debug ; /stomp resetmode manual|auto ; /stomp announce off|current|lifetime ; /stomp announce 1|5|10|20|50|100")

    if not STOMP_INDEX then
      Print("War Stomp not found in spellbook, addon will not count stomps")
    end
    return
  end

  if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
    if string.lower(tostring(INGALSTOMP_DB.resetMode or "manual")) == "auto" then
      local z = GetRealZoneText() or GetZoneText() or ""
      local key = tostring(z)
      if key ~= tostring(INGALSTOMP_DB.placeKey or "") then
        INGALSTOMP_DB.placeKey = key
        INGALSTOMP_DB.current = 0
        INGALSTOMP_RUN.count = 0
        Print("current count auto-reset (zone change)")
      end
    else
      -- manual: ensure we stay in sync on reload / zoning
      INGALSTOMP_RUN.count = tonumber(INGALSTOMP_DB.current) or 0
    end
    return
  end
end)

f:SetScript("OnUpdate", function()
  ticker = ticker + arg1
  if ticker < 0.05 then return end
  ticker = 0

  if pendingUntil <= 0 then return end

  local now = GetTime()
  if now > pendingUntil then
    pendingUntil = 0
    return
  end

  local start, duration, enabled = GetStompCooldown()
  if enabled == 1 and duration > 0 and start > 0 and start ~= lastCDStart then
    lastCDStart = start
    pendingUntil = 0
    DebugPrint("War Stomp cooldown started")
    CountAndYell("UseAction+SpellCD")
  end
end)

------------------------------------------------
-- Seed RNG once
------------------------------------------------
math.randomseed(math.floor(GetTime() * 100000))
