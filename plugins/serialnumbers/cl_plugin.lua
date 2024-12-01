net.Receive("SerialNumbers.InitiateSerialScratch", function()
    local validItems = net.ReadTable()

    if nut.gui and IsValid(nut.gui.menu) then
        nut.gui.menu:Remove()
    end

    if IsValid(weaponsFrame) then weaponsFrame:Remove() end

    weaponsFrame = vgui.Create("DFrame")
    weaponsFrame:SetSize(400, 300)
    weaponsFrame:Center()
    weaponsFrame:SetTitle("Choose a weapon...")
    weaponsFrame:SetBackgroundBlur(false) 
    weaponsFrame:SetDraggable(true)
    weaponsFrame:MakePopup()

    weaponsFrame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30))
    end

    weaponsFrame.lblTitle:SetFont("DermaDefaultBold")
    weaponsFrame.lblTitle:SetTextColor(Color(255, 255, 255))

    local ListView = vgui.Create("DListView", weaponsFrame)
    ListView:Dock(FILL)
    ListView:SetMultiSelect(false)
    ListView:SetHeaderHeight(30)
    ListView:SetDataHeight(25)

    ListView.PaintHeader = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40))
    end

    -- Add columns with dark grey background
    local column1 = ListView:AddColumn("Weapon Name")
    local column2 = ListView:AddColumn("Serial number")
    column1.Header:SetFont("DermaDefaultBold")
    column2.Header:SetFont("DermaDefaultBold")
    column1.Header:SetTextColor(Color(255, 255, 255))
    column2.Header:SetTextColor(Color(255, 255, 255))
    column1.Header:SetContentAlignment(5)
    column2.Header:SetContentAlignment(5)
    column1.Header:SetContentAlignment(5)
    column2.Header:SetContentAlignment(5)
    column1.Header:SetTall(30)
    column2.Header:SetTall(30)

    ListView.Paint = function(self, w, h)
        for _, line in pairs(self.Lines) do
            line.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
            end
        end
    end

    for _, item in ipairs(validItems) do
        ListView:AddLine(item.name, item.serialNumber)
    end

    ListView.OnRowSelected = function(_, _, row)
        local selectedItemId = tonumber(row:GetValue(2))
        
        weaponsFrame:AlphaTo(0, 0.2, 0, function()
            weaponsFrame:Remove()
        end)
        
        local countdownFrame = vgui.Create("DPanel")
        countdownFrame:SetSize(500, 100)
        countdownFrame:Center()
        countdownFrame:SetPos(countdownFrame:GetPos(), countdownFrame:GetPos() + 50)

        countdownFrame.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30)) 
        end

        local progressBar = vgui.Create("DProgress", countdownFrame)
        progressBar:SetSize(480, 30) 
        progressBar:SetPos(10, 50)
        progressBar:SetFraction(0)

        local progressBarTexture = Material("gui/gradient_up")

        progressBar.Paint = function(self, w, h)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(progressBarTexture)
            surface.DrawTexturedRect(0, 0, w * self:GetFraction(), h) 
        end

        local textLabel = vgui.Create("DLabel", countdownFrame)
        textLabel:SetText("Removing serial number...")
        textLabel:SetFont("DermaDefaultBold") 
        textLabel:SetTextColor(Color(255, 255, 255))
        textLabel:SizeToContents()
        textLabel:SetContentAlignment(5)
        textLabel:SetWide(countdownFrame:GetWide())
        textLabel:SetPos(10, 20)


        local originalWalkSpeed = LocalPlayer():GetWalkSpeed()
        LocalPlayer():SetWalkSpeed(15) 

        local startTime = 10 
        local endTime = CurTime() + startTime
        local updateInterval = 0.05 

        local timerName = "SerialNumberScratchTimer_" .. os.time() 

        timer.Create(timerName, updateInterval, 0, function()
            local timeLeft = endTime - CurTime()
            local progress = 1 - (timeLeft / startTime) 
            progressBar:SetFraction(progress)

            if timeLeft <= 0 then
                net.Start("SerialNumbers.FinishSerialScratch")
                net.WriteBool(true)
                net.WriteUInt(selectedItemId, 32)
                net.SendToServer()

                timer.Remove(timerName)
                countdownFrame:Remove()
                LocalPlayer():SetWalkSpeed(originalWalkSpeed)
            end
        end)
    end
end)