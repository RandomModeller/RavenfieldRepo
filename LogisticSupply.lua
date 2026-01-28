behaviour("LogisticSupply") --v1.0.0

function LogisticSupply:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.vehicleObject = self.targets.vehicleObject.GetComponent(Vehicle)
    self.reloadTime = self.dataContainer.GetFloat("reloadTime")
    self.spawnOffset = self.dataContainer.GetVector("spawnOffset")
    self.logisticBox = self.targets.logisticBox

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
                hasPassengers = hasPassengers or seat.occupant ~= nil
            end
        end

        if ((driverIsIn and self.lastDriverIsIn) and (not hasPassengers and self.lastHasPassengers)) or (not playerIsInside and self.lastPlayerIsInside) then
            GameObject.Instantiate(self.logisticBox, self.vehicleObject.transform.position + self.spawnOffset.x * self.vehicleObject.transform.right + self.spawnOffset.y * self.vehicleObject.transform.up + self.spawnOffset.z * self.vehicleObject.transform.forward, self.vehicleObject.transform.rotation)

            self.nextDeployTime = Time.time + self.reloadTime
        end

        self.lastDriverIsIn = driverIsIn
        self.lastHasPassengers = hasPassengers
        self.lastPlayerIsInside = playerIsInside
    end
end