behaviour("TVPCamoChanger") --v1.1.0

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

        for j=1, #self.materials do
            for k, object in self.dataContainer.GetGameObjectArray("object" .. tostring(k)) do
                if object ~= nil then
                    object.SetActive(j == newValue + 1)
                end
            end
        end
    end
end
