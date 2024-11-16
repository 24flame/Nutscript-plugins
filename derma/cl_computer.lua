if CLIENT then
    local PANEL = {}

    function PANEL:Init()
        self:SetSize(800, 300)
        self:Center()
        self:SetTitle("")
        self:MakePopup()

        self.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20)) 
            surface.SetDrawColor(Color(40, 40, 40))
            surface.DrawRect(0, 0, w, 30)
            draw.SimpleText("Serial number search", "DermaLarge", w / 2, 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
        end

        self.SearchPanel = vgui.Create("DPanel", self)
        self.SearchPanel:Dock(TOP)
        self.SearchPanel:SetTall(60)
        self.SearchPanel:DockMargin(10, 10, 10, 0)
        self.SearchPanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30)) 
        end

        self.SearchPanel.TextEntry = vgui.Create("DTextEntry", self.SearchPanel)
        self.SearchPanel.TextEntry:Dock(FILL)
        self.SearchPanel.TextEntry:DockMargin(10, 10, 5, 10)
        self.SearchPanel.TextEntry:SetFont("DermaLarge")
        self.SearchPanel.TextEntry:SetTextColor(Color(255, 255, 255))
        self.SearchPanel.TextEntry:SetPlaceholderText("enter serial number")
        self.SearchPanel.TextEntry:SetPlaceholderColor(Color(150, 150, 150))
        self.SearchPanel.TextEntry:SetDrawBackground(false)
        self.SearchPanel.TextEntry:SetDrawBorder(false)
        self.SearchPanel.TextEntry:SetHighlightColor(Color(130, 50, 50))
        self.SearchPanel.TextEntry.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 40)) 
            self:DrawTextEntryText(Color(255, 255, 255), Color(130, 50, 50), Color(255, 255, 255))
        end
        self.SearchPanel.TextEntry.AllowInput = function(_, char)
            return not string.find("0123456789", tostring(char))
        end

        self.SearchPanel.SearchButton = vgui.Create("DButton", self.SearchPanel)
        self.SearchPanel.SearchButton:Dock(RIGHT)
        self.SearchPanel.SearchButton:SetWide(150)
        self.SearchPanel.SearchButton:DockMargin(5, 10, 10, 10)
        self.SearchPanel.SearchButton:SetText("Search")
        self.SearchPanel.SearchButton:SetFont("DermaLarge")
        self.SearchPanel.SearchButton:SetTextColor(Color(255, 255, 255))
        self.SearchPanel.SearchButton.Paint = function(self, w, h)
            local color = self:IsHovered() and Color(70, 70, 70) or Color(60, 60, 60)
            draw.RoundedBox(8, 0, 0, w, h, color) 
        end
        self.SearchPanel.SearchButton.DoClick = function()
            local serialNumber = self.SearchPanel.TextEntry:GetText()
            if serialNumber and serialNumber ~= "" then
                net.Start("SerialNumbers.OwnerRequest")
                net.WriteString(serialNumber)
                net.SendToServer()
            end
        end

        self.OwnersList = vgui.Create("DListView", self)
        self.OwnersList:Dock(FILL)
        self.OwnersList:SetSortable(false)
        self.OwnersList:AddColumn("Owner"):SetWide(200)
        self.OwnersList:AddColumn("Owner ID"):SetWide(100)
        self.OwnersList:AddColumn("Serial number"):SetWide(200)
        self.OwnersList:SetHeaderHeight(30)
        self.OwnersList.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40)) 
        end
        for _, col in pairs(self.OwnersList.Columns) do
            col.Header:SetTextColor(Color(255, 255, 255))
            col.Header.Paint = function(_, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30)) 
            end
        end
    end

    function PANEL:ReceiveData(data)
        self.OwnersList:Clear()
        for _, ownerData in ipairs(data) do
            local line = self.OwnersList:AddLine(ownerData.name, ownerData.charID, ownerData.serialNumber)
            for _, column in pairs(line.Columns) do
                column:SetFont("DermaDefault")
                column:SetTextColor(Color(255, 255, 255))
            end
        end
    end

    vgui.Register("SerialNumbersComputer", PANEL, "DFrame")

    net.Receive("SerialNumbers.OpenComputer", function()
        if IsValid(SerialNumberSearch) then
            SerialNumberSearch:Remove()
        end
        SerialNumberSearch = vgui.Create("SerialNumbersComputer")
    end)

    net.Receive("SerialNumbers.OwnerResponse", function()
        local data = net.ReadTable()
        if IsValid(SerialNumberSearch) then
            SerialNumberSearch:ReceiveData(data)
        end
    end)
end