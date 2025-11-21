behaviour("SAMSetTarget") --v1.0.0

function SAMSetTarget:Start()
    self.vehicle = self.targets.vehicleObject.GetComponent(Vehicle)
    self.target = self.targets.target.transform
    self.weapon = self.targets.weapon.GetComponent(Weapon)
    self.weapon.onSpawnProjectiles.AddListener(self, "OnFire")

    if not self.vehicle.playerIsInside then
        return
    end

    self.radar = self.targets.radar.GetComponent(ScriptedBehaviour).self
end

function SAMSetTarget:Update()
    if not self.vehicle.playerIsInside then
        return
    end

    if self.radar == nil then
        self.radar = self.targets.radar.GetComponent(ScriptedBehaviour).self
    end
    if self.radar.lockedVehicle then
        self.target.position = self.radar.lockedVehicle.transform.position
    end
end

function SAMSetTarget:OnFire(projectile)
    if not self.vehicle.playerIsInside then
        return
    end

    if self.radar == nil then
        self.radar = self.targets.radar.GetComponent(ScriptedBehaviour).self
    end

    if self.radar.lockedVehicle then
        local projScript = projectile[1].gameObject.GetComponent(Projectile)

        projScript.SetTrackerTarget(self.radar.lockedVehicle)
    end
end