local CrystalTypes = require(script.Parent.Parent.Crystal.CrystalTypes)

export type MatchState = "Intermission" | "Game"

export type MatchTypes = {
	RemainingTime: number,
	State: MatchState,
	CurrentSpawnedCrystals: number,
}

export type MatchConfigTypes = {
	GameplayTime: number,
	IntermissionTime: number,
	MaxSpawnedCrystals: number,
	CrystalSpawnInterval: number,
}

return nil
