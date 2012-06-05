class FolditScript
  attr_accessor :numlines, :hasfuncs, :islong, :isgenetic, :recurses, :checksscore, :checksstate, :checksprotein, :reverts, :usesbuiltins

  def initialize(opts)
    @numlines = opts[:nl]
    @hasfuncs = opts[:hf]
    @islong = opts[:il]
    @isgenetic = opts[:ig]
    @recurses = opts[:rs]
    @checksscore = opts[:cs]
    @checksstate = opts[:st]
    @checksprotein = opts[:cp]
    @reverts = opts[:rv]
    @usesbuiltins = opts[:ub]
  end

  def to_hash
    {
      :linecount   => @numlines,
      :useslibrary => @hasfuncs,
      :longruntime => @islong,
      :genetic => @isgenetic,
      :recursion => @recurses,
      :smartscore => @checksscore,
      :smartstate => @checksstate,
      :protein => @checksprotein,
      :reverts => @reverts,
      :builtinusage => @usesbuiltins
    }
  end
end

def count_lines data
  data.split("\n").size
end

def funcs_and_libraries(code)
  total_number_matches(code, library_rgx())
end
def long_runtime(code)
  l = total_number_matches(code, long_runtime_rgx())
  s = total_number_matches(code, short_runtime_rgx())
  { :shortmatches => s, :longmatches => l }
end
def is_genetic(code)
  total_number_matches(code, genetic_rgx())
end
def has_recursion(code)
  total_number_matches(code, recursion_rgx())
end
def checks_score(code)
  total_number_matches(code, score_rgx())
end
def checks_state(code)
  total_number_matches(code, Regexp.new(foldit_check_state().join('|'), Regexp::IGNORECASE))
end
def checks_protein(code)
  total_number_matches(code, Regexp.new(foldit_check_protein().join('|'), Regexp::IGNORECASE))
end
def reverts_progress(code)
  total_number_matches(code, Regexp.new(foldit_check_revert().join('|'), Regexp::IGNORECASE))
end
def profile_builtins(code)
  d = {}
  foldit_funcs().each do |fun|
    d[fun] = total_number_matches(code,Regexp.new(fun,Regexp::IGNORECASE)) if code.downcase.include?(fun.downcase)
  end
  d
end

def foldit_funcs
  [
"AreConditionsMet", "GetEnergyScore", "GetExplorationMultiplier", "GetScore", "GetSegmentEnergyScore", "GetSegmentEnergySubscore", "Restore", "Add", "AddBetweenSegments", "AddToBandEndpoint", "Delete", "DeleteAll", "Disable", "DisableAll", "Enable", "EnableAll", "GetCount", "GetGoalLength", "GetLength", "GetStrength", "IsEnabled", "SetGoalLength", "SetStrength", "GetClashImportance", "GetShakeAccuracy", "GetWiggleAccuracy", "SetClashImportance", "SetShakeAccuracy", "SetWiggleAccuracy", "GetHeat", "IsContact", "AddButton", "AddCheckbox", "AddLabel", "AddSlider", "AddTextbox", "CreateDialog", "Show", "Freeze", "FreezeAll", "FreezeSelected", "IsFrozen", "Unfreeze", "UnfreezeAll", "GetDescription", "GetExpirationTime", "GetName", "GetPuzzleID", "StartOver", "Save", "CompareNumbers", "GetRandomSeed", "ReportStatus", "SectionEnd", "SectionStart", "SetRotamer", "LoadSecondaryStructure", "Quickload", "Quicksave", "SaveSecondaryStructure", "GetGroupRank", "GetGroupScore", "GetRank", "GetScoreType", "Deselect", "DeselectAll", "IsSelected", "Select", "SelectAll", "SelectRange", "GetAminoAcid", "GetAtomCount", "GetDistance", "GetNote", "GetSecondaryStructure", "IsHydrophobic", "IsMutable", "LocalWiggleAll", "LocalWiggleSelected", "MutateSidechainsAll", "MutateSidechainsSelected", "RebuildSelected", "SetAminoAcid", "SetAminoAcidSelected", "SetNote", "SetSecondaryStructure", "SetSecondaryStructureSelected", "ShakeSidechainsAll", "ShakeSidechainsSelected", "WiggleAll", "WiggleSelected", "AlignGuide", "CenterViewport", "GetTrackName", "GetGroupID", "GetGroupName", "GetPlayerID"
  ]
end

def foldit_check_state
  ['AreConditionsMet','GetEnergyScore','GetScore','GetSegmentEnergyScore','GetSegmentEnergySubscore', "GetClashImportance", "GetShakeAccuracy", "GetWiggleAccuracy", "GetGoalLength", "ReportStatus", "GetHeat", "GetStrength", "GetAtomCount"]
end

def foldit_check_revert
  ["StartOver", "Restore"]
end

def foldit_check_protein
  ["IsHydrophobic", "IsMutable", "IsContact", "IsFrozen", "IsSelected"]
end

def total_number_matches data, rgx
  res = process_regex(data, rgx)
  (res.empty?) ? -1 : res.size
end

def process_regex(string, rgx)
  string.scan(rgx).flatten
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

def genetic_rgx
  Regexp.new(['genetic', 'train', 'optimize', 'learn', 'herd', 'breed', 'mutate'].join('|'), Regexp::IGNORECASE)
end

def score_rgx
  Regexp.new(['best score', 'bestScore', 'best_score', 'more points', 'improve', 'scoreBefore', 'score_before'].join('|'), Regexp::IGNORECASE)
end

def recursion_rgx
  Regexp.new(['recursive', 'recursion', 'recurse'].join('|'), Regexp::IGNORECASE)
end
