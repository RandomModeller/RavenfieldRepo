behaviour("SingleProjBreech") -- v1.0.1

function SingleProjBreech:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.cannons = {}

    for i, cannonObject in pairs(self.dataContainer.GetGameObjectArray("cannon")) do
        self.cannons[i] = cannonObject.GetComponent(Weapon)

        self.cannons[i].ammo = 0
        self.cannons[i].spareAmmo = 0
    end

    self.text = nil
    if self.targets.text ~= nil then
        self.text = self.targets.text.GetComponent(Text)
    end

    self:Load(1)
    self.cannons[1].ammo = 1
end

function SingleProjBreech:Update()
    local allEmpty = false

    for i, cannon in pairs(self.cannons) do
        if i == self.activeCannonIndex then
            allEmpty = cannon.ammo ~= 1
        else
            if cannon.ammo == 1 then
                self:Load(i)
            else
                cannon.ammo = 0
            end
        end
    end

    for i, cannon in pairs(self.cannons) do
        if allEmpty and cannon.isUnholstered then
            cannon.spareAmmo = 1
        else
            cannon.spareAmmo = 0
        end
    end

    if self.text ~= nil then
        self.text = self.cannons[self.activeCannonIndex].gameObject.name
    end
end

function SingleProjBreech:Load(index)
    self.activeCannonIndex = index
    -- self.cannons[index].ammo = 1
end