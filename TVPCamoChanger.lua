behaviour("TVPCamoChanger") --v1.0.0

function TVPCamoChanger:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.materials = self.dataContainer.GetMaterialArray("material")

    self.dropdown = self.targets.dropdownObject.GetComponent(Dropdown)
    self.dropdown.onValueChanged.AddListener(self, "OnDropdownChange")
end

function TVPCamoChanger:OnDropdownChange(newValue)
    local newColor = self.dataContainer.GetColor("color" .. (newValue + 1))
    for i, material in pairs(self.materials) do
        material.color = newColor
    end
end