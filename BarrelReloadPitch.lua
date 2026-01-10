behaviour("BarrelReloadPitch") --v1.1.0

function BarrelReloadPitch:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    if self.targets.originalBearing ~= nil then
        self.originalBearing = self.targets.originalBearing.transform
        self.fakeBearing = self.targets.fakeBearing.transform
    end
    self.originalPitch = self.targets.originalPitch.transform
    self.fakePitch = self.targets.fakePitch.transform

    self.weapons = {}

    for i, weapon in pairs(self.dataContainer.GetGameObjectArray("weapon")) do
        self.weapons[#self.weapons + 1] = weapon.GetComponent(Weapon)
    end

    self.reloadRotation = Quaternion.Euler(self.dataContainer.GetFloat("reloadPitchAngle"), 0, 0)
    self.rotationSpeed = self.dataContainer.GetFloat("rotationSpeed")
end

function BarrelReloadPitch:Update()
    local isReloading = false

    for i, weapon in pairs(self.weapons) do
        if weapon.isReloading then
            isReloading = true
            break
        end
    end

    if isReloading then
        self.fakePitch.localRotation = Quaternion.RotateTowards(self.fakePitch.localRotation, self.reloadRotation, self.rotationSpeed * Time.deltaTime)
    else
        self.fakePitch.localRotation = Quaternion.RotateTowards(self.fakePitch.localRotation, self.originalPitch.localRotation, self.rotationSpeed * Time.deltaTime)
    end

    if self.originalBearing ~= nil then
        self.fakeBearing.rotation = self.originalBearing.rotation
    end
end
