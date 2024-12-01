local PLUGIN = PLUGIN or {}
FlamesserialNumbers = FlamesserialNumbers or {}
PLUGIN.name = "Serial Numbers"
PLUGIN.author = "Flame"
PLUGIN.desc = " :) "
------------------------------------------------------------------
nut.util.include( "sv_plugin.lua" )
nut.util.include( "cl_plugin.lua" )
------------------------------------------------------------------
----Add the Factions that should be allowed here
------------------------------------------------------------------
FlamesserialNumbers.Factions = {
    [FACTION_DEFAULT] = true,
}
------------------------------------------------------------------