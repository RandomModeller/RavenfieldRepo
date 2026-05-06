behaviour("LogisticSupply") --v1.2.0

function LogisticSupply:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.vehicleObject = self.targets.vehicleObject.GetComponent(Vehicle)
    if self.targets.weapon == nil then
        self.reloadTime = self.dataContainer.GetFloat("reloadTime")
        self.spawnOffset = self.dataContainer.GetVector("spawnOffset")
        self.logisticBox = self.targets.logisticBox
    else
        self.weapon = self.targets.weapon.GetComponent(Weapon)
    end

    self.dropOnPlayerExit = true
    if self.dataContainer.HasBool("dropOnPlayerExit") then
        self.dropOnPlayerExit = self.dataContainer.GetBool("dropOnPlayerExit")
    end

    self.nextDeployTime = 0
    self.lastDriverIsIn = false
    self.lastHasPassengers = false
    self.lastPlayerIsInside = false
end

function LogisticSupply:Update()
    if Time.time >= self.nextDeployTime then
        local driverIsIn = self.vehicleObject.hasDriver
        local hasPassengers = false
        local playerIsInside = self.vehicleObject.playerIsInside

        for i, seat in pairs(self.vehicleObject.seats) do
            if not seat.hasWeapons then
                hasPassengers = hasPassengers or (seat.occupant ~= nil and seat.occupant ~= Player.actor)
            end
        end

        local flag1 = (driverIsIn and self.lastDriverIsIn) and (not hasPassengers and self.lastHasPassengers)

        local flag2 = not playerIsInside and self.lastPlayerIsInside and self.dropOnPlayerExit

        local flag3 = false
        -- if self.weapon ~= nil then
        --     local flag3 = self.weapon.isHoldingFire and self.weapon.canFire
        -- end

        if flag1 or flag2 or flag3 then
            if self.weapon == nil then
                GameObject.Instantiate(self.logisticBox, self.vehicleObject.transform.position + self.spawnOffset.x * self.vehicleObject.transform.right + self.spawnOffset.y * self.vehicleObject.transform.up + self.spawnOffset.z * self.vehicleObject.transform.forward, self.vehicleObject.transform.rotation)

                self.nextDeployTime = Time.time + self.reloadTime
            else
                if self.weapon.canFire then
                    self.weapon.Shoot(true)
                end
            end
        end

        self.lastDriverIsIn = driverIsIn
        self.lastHasPassengers = hasPassengers
        self.lastPlayerIsInside = playerIsInside
    end
end
