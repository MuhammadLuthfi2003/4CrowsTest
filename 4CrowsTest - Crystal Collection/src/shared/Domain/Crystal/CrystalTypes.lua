export type CrystalRarity = "Common" | "Rare" | "Epic"

export type CrystalTypes = {
    CrystalId: string,
    Rarity: CrystalRarity,
}

export type CrystalConfigTypes = {
    SpawnInterval: number,
    MaxActiveAmount: number
}

export type CrystalDefinitionTypes = {
    Rarity: CrystalRarity,
    Score: number,
}

return nil