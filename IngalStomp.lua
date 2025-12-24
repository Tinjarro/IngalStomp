-- IngalStomp v1.6 CLEAN (Turtle 1.12)
-- Counts YOUR successful War Stomps, persists, manual reset only, yells a random line each stomp.
-- Detection: UseAction attempt window + War Stomp spellbook cooldown transition, success only.
-- Note: By design, it only counts War Stomp activated via an action bar button, not macros or spellbook clicks.

------------------------------------------------
-- SavedVariables bootstrap (TOP OF FILE)
------------------------------------------------
if not INGALSTOMP_DB then INGALSTOMP_DB = {} end
if type(INGALSTOMP_DB.count) ~= "number" then INGALSTOMP_DB.count = 0 end
if type(INGALSTOMP_DB.debug) ~= "boolean" then INGALSTOMP_DB.debug = false end

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

local function DebugPrint(msg)
  if INGALSTOMP_DB.debug then
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd100IngalStomp-DEBUG|r: " .. msg)
  end
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

  INGALSTOMP_DB.count = INGALSTOMP_DB.count + 1

  local name = UnitName("player") or "Me"
  local line = fmt(pickLine(), INGALSTOMP_DB.count, name)

  -- Hard normalize any stray smart quotes if they ever sneak in again
  line = string.gsub(line, "’", "'")
  line = string.gsub(line, "“", '"')
  line = string.gsub(line, "”", '"')

  if line and line ~= "" then
    SendChatMessage(line, "YELL")
  else
    DebugPrint("empty yell string, skipped")
  end

  if INGALSTOMP_DB.debug then
    Print("Stomp counted " .. INGALSTOMP_DB.count .. " (" .. (source or "?") .. ")")
  end
end

------------------------------------------------
-- Slash commands
------------------------------------------------
SLASH_INGALSTOMP1 = "/stomp"
SLASH_INGALSTOMP2 = "/ingalstomp"
SlashCmdList["INGALSTOMP"] = function(msg)
  msg = string.lower(msg or "")

  if msg == "reset" or msg == "clear" then
    INGALSTOMP_DB.count = 0
    Print("count reset to 0")
    return
  end

  if msg == "debug" then
    INGALSTOMP_DB.debug = not INGALSTOMP_DB.debug
    Print("debug " .. (INGALSTOMP_DB.debug and "ON" or "OFF"))
    return
  end

  Print("current count: " .. INGALSTOMP_DB.count .. " ; /stomp reset ; /stomp debug")
end

------------------------------------------------
-- War Stomp spellbook index, cooldown polling
------------------------------------------------
local STOMP_INDEX = nil

local function FindWarStompIndex()
  STOMP_INDEX = nil
  local i = 1
  while true do
    local name = GetSpellName(i, BOOKTYPE_SPELL)
    if not name then break end
    if name == "War Stomp" then
      STOMP_INDEX = i
      break
    end
    i = i + 1
  end
  DebugPrint("War Stomp index=" .. tostring(STOMP_INDEX))
end

local function GetStompCooldown()
  if not STOMP_INDEX then return 0, 0, 0 end
  local start, duration, enabled = GetSpellCooldown(STOMP_INDEX, BOOKTYPE_SPELL)
  if not start then start = 0 end
  if not duration then duration = 0 end
  if not enabled then enabled = 0 end
  return start, duration, enabled
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

f:SetScript("OnEvent", function()
  FindWarStompIndex()
  local s = GetStompCooldown()
  lastCDStart = s or 0

  Print("loaded. Count: " .. INGALSTOMP_DB.count .. " | /stomp reset | /stomp debug")

  if not STOMP_INDEX then
    Print("War Stomp not found in spellbook, addon will not count stomps")
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
