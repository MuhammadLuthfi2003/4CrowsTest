# Domain Rules Implementation Plan

## Analysis & Architectural Decisions

Before writing code, I need to clarify what belongs in the **Domain Layer** vs what belongs in the **Service Layer**.

Per the *Decision vs Execution* principle:
- **Domain decides** → "What is the new score?", "Is the match over?", "Is the crystal count at max?"
- **Service executes** → Actually removing the Roblox Part, calling `RemoteEvent`, updating DataStore

Some of the requirements the user listed (e.g., "be able to spawn to the main area", "destroyed/removed on pickup") are **engine execution concerns** — these belong in an **Adapter/Service**, NOT in the Domain. The Domain only provides the *decision logic* (the rules & policies).

---

## 1. Player Domain

**Category:** Behavior (has runtime state: `CurrentPoint`)  
**Files to change:** `PlayerRules.lua`, `PlayerTypes.lua`

### Rules to add in `PlayerRules.lua`:
| Function | Signature | Description |
|---|---|---|
| `AddScore` | `(player, crystal: CrystalDefinitionTypes) -> Player` | Returns a new Player with updated `CurrentPoint` |
| `ResetScore` | `(player) -> Player` | Returns a new Player with `CurrentPoint = 0` |

### Cross-domain note:
`AddScore` needs `CrystalDefinitionTypes` from the Crystal domain. Per the skill rules: **requires a function/type → `require` directly**. The type is injected as an argument (not state), so this is clean.

---

## 2. Match Domain

**Category:** Behavior (has runtime state: `RemainingTime`, `State`)  
**Files to change:** `MatchRules.lua`, `MatchPolicy.lua`

### Rules to add in `MatchRules.lua`:
| Function | Signature | Description |
|---|---|---|
| `Tick` | `(match, config, deltaTime) -> MatchTypes` | Reduces `RemainingTime` by `deltaTime`; when it hits 0, flips `State` (Intermission ↔ Game) and resets `RemainingTime` to the appropriate duration |

### Policies to add in `MatchPolicy.lua`:
| Function | Signature | Description |
|---|---|---|
| `CanSpawnCrystal` | `(match, config, currentSpawnedCount) -> boolean` | Returns true only if `State == "Game"` AND `currentSpawnedCount < config.MaxSpawnedCrystals` |

### Note on `SpawnInterval`:
The **interval timer** is a runtime counter — it changes each tick. This is state that the **Service** must track (e.g., `session.SpawnTimer`). The Domain only decides *whether* to spawn, not *when* to trigger the timer. The Service decrements its own timer and calls `MatchPolicy.CanSpawnCrystal` when the interval fires.

---

## 3. Crystal Domain

**Category:** Entity Object (Blueprint/Identity) — `CrystalTypes`, `CrystalDefinition` are already good.  
**Engine concerns (skip):** "Spawn to main area" and "destroyed on pickup" → handled by an Adapter/Service.  
**Only Domain concern:** Provide the definition data (Score, Rarity) → `CrystalDefinition` already does this.

> **No new Rules/Policy needed for Crystal.** The behavior of "pickup" is a Player concern (AddScore) orchestrated by the Service. The "spawn" and "destroy" are engine-side Adapter concerns.

> [!NOTE]
> `CrystalPolicy.lua` is empty and should remain empty or be deleted. There is no Domain-level business rule that governs *whether* a crystal can be spawned from the crystal's own perspective — that is a Match concern (`MatchPolicy.CanSpawnCrystal`).

---

## Proposed Changes

### Player Domain

#### [MODIFY] [PlayerRules.lua](file:///d:/GitHub%20Projects/4CrowsTest/4CrowsTest%20-%20Crystal%20Collection/src/shared/Domain/Player/PlayerRules.lua)
- Add `AddScore(player, crystalDef) -> Player` (immutable, uses `table.clone`)
- Add `ResetScore(player) -> Player` (immutable, uses `table.clone`)

---

### Match Domain

#### [MODIFY] [MatchRules.lua](file:///d:/GitHub%20Projects/4CrowsTest/4CrowsTest%20-%20Crystal%20Collection/src/shared/Domain/Match/MatchRules.lua)
- Add `Tick(match, config, deltaTime) -> MatchTypes`

#### [MODIFY] [MatchPolicy.lua](file:///d:/GitHub%20Projects/4CrowsTest/4CrowsTest%20-%20Crystal%20Collection/src/shared/Domain/Match/MatchPolicy.lua)
- Add `CanSpawnCrystal(match, config, currentSpawnedCount) -> boolean`

---

### Crystal Domain

> No changes needed. Crystal is a pure Entity Object domain. Spawn/destroy are Service/Adapter concerns.

---

## Open Question

> [!IMPORTANT]
> **Regarding `CrystalDefinition.lua`**: The user reverted the `Definitions/` folder refactor and kept everything in one monolithic file. Should I:
> 1. Leave it as-is (accept the monolith for now)
> 2. Re-apply the folder split as it was intended by the skill rules

The current `CrystalDefinition.lua` also has **no `return` statement**, which means it currently returns nothing. This needs to be fixed regardless.

## Verification Plan
- All `Rules` functions must use `table.clone` — no direct mutation.
- `Policy` functions must only start with `Can...`.
- No Roblox engine API calls inside any Domain file.
- `deltaTime` is always injected as a parameter — no `os.clock()` calls.
