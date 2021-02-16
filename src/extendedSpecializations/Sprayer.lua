---${title}

---@author ${author}
---@version r_version_r
---@date 23/11/2020

ExtendedSprayer = {}
ExtendedSprayer.MOD_NAME = g_currentModName
ExtendedSprayer.SPEC_TABLE_NAME = string.format("spec_%s.extendedSprayer", ExtendedSprayer.MOD_NAME)

function ExtendedSprayer.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(AdvancedStats, specializations)
end

function ExtendedSprayer.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onPreLoad", ExtendedSprayer)
    SpecializationUtil.registerEventListener(vehicleType, "onLoadStats", ExtendedSprayer)
    SpecializationUtil.registerEventListener(vehicleType, "onEndWorkAreaProcessing", ExtendedSprayer)
end

function ExtendedSprayer:onPreLoad()
    local spec = self[ExtendedSprayer.SPEC_TABLE_NAME]
    spec.fillTypeToHectaresStat = {}
    spec.fillTypeToHectaresStat[FillType.HERBICIDE] = "HerbicideHectares"
    spec.fillTypeToHectaresStat[FillType.FERTILIZER] = "FertilizerHectares"
    spec.fillTypeToHectaresStat[FillType.LIQUIDFERTILIZER] = "LiquidFertilizerHectares"
    spec.fillTypeToHectaresStat[FillType.LIME] = "LimeHectares"
    spec.fillTypeToHectaresStat[FillType.MANURE] = "ManureHectares"
    spec.fillTypeToHectaresStat[FillType.LIQUIDMANURE] = "LiquidManureHectares"
    spec.fillTypeToHectaresStat[FillType.DIGESTATE] = "DigestateHectares"

    spec.fillTypeToUsedStat = {}
    spec.fillTypeToUsedStat[FillType.HERBICIDE] = "UsedHerbicide"
    spec.fillTypeToUsedStat[FillType.FERTILIZER] = "UsedFertilizer"
    spec.fillTypeToUsedStat[FillType.LIQUIDFERTILIZER] = "UsedLiquidFertilizer"
    spec.fillTypeToUsedStat[FillType.LIME] = "UsedLime"
    spec.fillTypeToUsedStat[FillType.MANURE] = "UsedManure"
    spec.fillTypeToUsedStat[FillType.LIQUIDMANURE] = "UsedLiquidManure"
    spec.fillTypeToUsedStat[FillType.DIGESTATE] = "UsedDigestate"
end

function ExtendedSprayer:onLoadStats()
    local spec = self[ExtendedSprayer.SPEC_TABLE_NAME]

    spec.hasAdvancedStats = true
    spec.advancedStatisticsPrefix = "Sprayer"

    spec.advancedStatistics =
        self:registerStats(
        spec.advancedStatisticsPrefix,
        {
            {"WorkedHectares", AdvancedStats.UNITS.HECTARE, true},
            {"UsedLitres", AdvancedStats.UNITS.LITRE, true},
            {"UsedHerbicide", AdvancedStats.UNITS.LITRE},
            {"HerbicideHectares", AdvancedStats.UNITS.HECTARE},
            {"UsedFertilizer", AdvancedStats.UNITS.LITRE},
            {"FertilizerHectares", AdvancedStats.UNITS.HECTARE},
            {"UsedLiquidFertilizer", AdvancedStats.UNITS.LITRE},
            {"LiquidFertilizerHectares", AdvancedStats.UNITS.HECTARE},
            {"UsedLime", AdvancedStats.UNITS.LITRE},
            {"LimeHectares", AdvancedStats.UNITS.HECTARE},
            {"UsedManure", AdvancedStats.UNITS.LITRE},
            {"ManureHectares", AdvancedStats.UNITS.HECTARE},
            {"UsedLiquidManure", AdvancedStats.UNITS.LITRE},
            {"LiquidManureHectares", AdvancedStats.UNITS.HECTARE},
            {"UsedDigestate", AdvancedStats.UNITS.LITRE},
            {"DigestateHectares", AdvancedStats.UNITS.HECTARE}
        }
    )
end

function ExtendedSprayer:onEndWorkAreaProcessing(dt)
    if self.isServer then
        local lastStatsArea = self.spec_sprayer.workAreaParameters.lastStatsArea
        local usage = self.spec_sprayer.workAreaParameters.usage
        local fillType = self.spec_sprayer.workAreaParameters.sprayFillType
        if self.spec_sprayer.workAreaParameters.isActive then
            local spec = self[ExtendedSprayer.SPEC_TABLE_NAME]

            local ha = MathUtil.areaToHa(lastStatsArea, g_currentMission:getFruitPixelsToSqm()) -- 4096px are mapped to 2048m
            self:updateStat(spec.advancedStatistics["WorkedHectares"], ha)

            self:updateStat(spec.advancedStatistics["UsedLitres"], usage)

            if spec.fillTypeToHectaresStat[fillType] ~= nil then
                self:updateStat(spec.advancedStatistics[spec.fillTypeToHectaresStat[fillType]], ha)
            end

            if spec.fillTypeToUsedStat[fillType] ~= nil then
                self:updateStat(spec.advancedStatistics[spec.fillTypeToUsedStat[fillType]], usage)
            end
        end
    end
end
