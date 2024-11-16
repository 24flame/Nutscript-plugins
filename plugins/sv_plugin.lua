local PLUGIN = PLUGIN

util.AddNetworkString("SerialNumbers.InitiateSerialScratch")
util.AddNetworkString("SerialNumbers.FinishSerialScratch")
util.AddNetworkString("SerialNumbers.OpenComputer")
util.AddNetworkString("SerialNumbers.OwnerRequest")
util.AddNetworkString("SerialNumbers.OwnerResponse")

function GenerateUniqueSerialNumber()
    local serial
    local isUnique = false

    while not isUnique do
        serial = tostring(math.random(100000, 999999)) 
        isUnique = true 
        for _, item in pairs(nut.item.instances) do
            if item:getData("SerialNumber") == serial then
                isUnique = false 
                break 
            end
        end
    end

    return serial 
end

function PLUGIN:AssignSerialNumber(weaponItem, character)
    if weaponItem.isWeapon then
        local serialNumber = GenerateUniqueSerialNumber()
        weaponItem:setData("SerialNumber", serialNumber)
        if character and character.getID then
            local charID = character:getID()
            weaponItem:setData("ownerCharID", charID)
        end
    end
end

net.Receive("SerialNumbers.FinishSerialScratch", function(len, ply)
    local scratch = net.ReadBool()
    local itemId = net.ReadUInt(32)
    local item = nut.item.instances[itemId]
    if item and scratch then
        if item.isWeapon then
            item:setData("SerialNumber_Scratched", true)
            ply:notify("The serial number was successfully removed.")

            local fileItemFound, fileItemId = PLUGIN:FindFileItem(ply)
            if fileItemFound then
                local fileItem = nut.item.instances[fileItemId]
                fileItem:remove() 
                ply:notify("The file has been removed from your inventory.")
            else
                ply:notify("No file item found in inventory.")
            end
        else
            ply:notify("You cannot modify this weapon.")
        end
    else
        ply:notify("Operation cancelled or failed.")
    end
end)

function PLUGIN:FindFileItem(player)
    local character = player:getChar()
    if character then
        for _, item in pairs(character:getInv():getItems()) do
            if item.uniqueID == "feile124" then 
                return true, item.id
            end
        end
    end
    return false
end

net.Receive("SerialNumbers.OwnerRequest", function(len, ply)
    local serialNumber = net.ReadString()
    local ownersData = PLUGIN:FindOwnersBySerialNumber(serialNumber)
    net.Start("SerialNumbers.OwnerResponse")
     net.WriteTable(ownersData)
    net.Send(ply)
end)

function PLUGIN:FindOwnersBySerialNumber(serialNumber)
    local owners = {}
    for _, item in pairs(nut.item.instances) do
        if item.isWeapon and item:getData("SerialNumber") == serialNumber and not item:getData("SerialNumber_Scratched") then
            local charID = item:getData("ownerCharID")
            if charID then
                local character = nut.char.loaded[charID]
                if character then
                    local ownerName = character:getName()
                    local ownerData = {
                        name = ownerName,
                        charID = charID,
                        serialNumber = serialNumber
                    }
                    table.insert(owners, ownerData)
                end
            end
        end
    end
    return owners
end

function regisetrSerialnumberetc(item)
	client = item:getOwner()
	character = cleint:getChar()
	serialnumber12 = GenerateUniqueSerialNumber()
	charid123 = character:getID()
    if not table.HasValue(serialNumbersTable, serialNumber12) then
        table.insert(serialNumbersTable, serialNumber12)
        item:setData("SerialNumber", serialNumber12)
        item:setData("ownerCharID", charid123)
    end
end 

function InitiateSerialScratch(player, item)
    local validItems = {}
    validItems = PLUGIN:GetValidWeaponsForPlayer(player)
    if validItems then 
        net.Start("SerialNumbers.InitiateSerialScratch")
        net.WriteTable(validItems)
        net.Send(player)
    else
        player:notify("You have no weapon in your inventory")
    end
end

function PLUGIN:GetValidWeaponsForPlayer(player)
    local character = player:getChar()
    local validWeapons = {} 

    for k, v in pairs(character:getInv():getItems()) do
        if v.isWeapon and not v:getData("SerialNumber_Scratched") then
            local weaponInfo = {
                name = v.name,
                serialNumber = v.id
            }
            table.insert(validWeapons, weaponInfo)
        end
    end
    return validWeapons
end