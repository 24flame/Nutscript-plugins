
ITEM.name = "File"
ITEM.desc = "A file for scratching off the serial number of a gun."
ITEM.model = "models/props_c17/TrapPropeller_Lever.mdl"
ITEM.uniqueID = "feile124"
ITEM.functions.Use = {
    name = "Use",
    icon = "icon16/tick.png",
    onRun = function( item )
        InitiateSerialScratch( item.player, item )
        return false
    end,
    onCanRun = function()
        return true
    end
}