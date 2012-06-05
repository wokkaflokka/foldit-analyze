#!/usr/bin/env ruby

def count_lines file
  `wc -l #{file} | awk '{print $1}'`
end

def library_rgx
  Regexp.new("library|function", Regexp::IGNORECASE)
end

def long_runtime_rgx
  Regexp.new("long|forever|hours|slow|overnight|complex|advanced", Regexp::IGNORECASE)
end

def short_runtime_rgx
  Regexp.new("short|quick|simple|fast|immediate|speed", Regexp::IGNORECASE)
end

def genetic_regex
  Regexp.new(['genetic', 'train', 'optimize', 'learn', 'herd', 'breed', 'mutate'].join('|'), Regexp::IGNORECASE)
end

def score_rgx
  Regexp.new(['best score', 'bestScore', 'best_score', 'more points', 'improve', 'scoreBefore', 'score_before'].join('|'), Regexp::IGNORECASE)
end

def recursion_rgx
  Regexp.new(['recursive', 'recursion', 'recurse'].join('|'), Regexp::IGNORECASE)
end

def foldit_funcs
["AreConditionsMet", "GetEnergyScore", "GetExplorationMultiplier", "GetScore", "GetSegmentEnergyScore", "GetSegmentEnergySubscore", "Restore", "Add", "AddBetweenSegments", "AddToBandEndpoint", "Delete", "DeleteAll", "Disable", "DisableAll", "Enable", "EnableAll", "GetCount", "GetGoalLength", "GetLength", "GetStrength", "IsEnabled", "SetGoalLength", "SetStrength", "GetClashImportance", "GetShakeAccuracy", "GetWiggleAccuracy", "SetClashImportance", "SetShakeAccuracy", "SetWiggleAccuracy", "GetHeat", "IsContact", "AddButton", "AddCheckbox", "AddLabel", "AddSlider", "AddTextbox", "CreateDialog", "Show", "Freeze", "FreezeAll", "FreezeSelected", "IsFrozen", "Unfreeze", "UnfreezeAll", "GetDescription", "GetExpirationTime", "GetName", "GetPuzzleID", "StartOver", "Save", "CompareNumbers", "GetRandomSeed", "ReportStatus", "SectionEnd", "SectionStart", "SetRotamer", "LoadSecondaryStructure", "Quickload", "Quicksave", "SaveSecondaryStructure", "GetGroupRank", "GetGroupScore", "GetRank", "GetScoreType", "Deselect", "DeselectAll", "IsSelected", "Select", "SelectAll", "SelectRange", "GetAminoAcid", "GetAtomCount", "GetDistance", "GetNote", "GetSecondaryStructure", "IsHydrophobic", "IsMutable", "LocalWiggleAll", "LocalWiggleSelected", "MutateSidechainsAll", "MutateSidechainsSelected", "RebuildSelected", "SetAminoAcid", "SetAminoAcidSelected", "SetNote", "SetSecondaryStructure", "SetSecondaryStructureSelected", "ShakeSidechainsAll", "ShakeSidechainsSelected", "WiggleAll", "WiggleSelected", "AlignGuide", "CenterViewport", "GetTrackName", "GetGroupID", "GetGroupName", "GetPlayerID"]
end

def foldit_check_state
  ['AreConditionsMet','GetEnergyScore','GetScore','GetSegmentEnergyScore','GetSegmentEnergySubscore', "GetClashImportance", "GetShakeAccuracy", "GetWiggleAccuracy", "GetGoalLength", "ReportStatus", "GetHeat", "GetStrength", "GetAtomCount"]
end

def foldit_revert
  ["StartOver", "Restore"]
end

def foldit_anl_protein
  ["IsHydrophobic", "IsMutable", "IsContact", "IsFrozen", "IsSelected"]
end
