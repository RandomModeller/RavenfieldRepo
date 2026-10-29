behaviour("PhantomFCR") --v1.0.0

function PhantomFCR:Start()
    self.vehicleObject = self.targets.vehicleObject.GetComponent(Vehicle)

    self.target = {}
    self.groundTarget = {}
    self.seaTarget = {}

    GameEvents.onVehicleSpawn.AddListener(self, "UpdateVehicles")
    GameEvents.onVehicleDestroyed.AddListener(self, "UpdateVehicles")

    self:UpdateVehicles()

    self.hasTarget = false
    self.hasTargetPoint = false
end

function PhantomFCR:UpdateVehicles(vehicle)
    self.target = {}
    self.groundTarget = {}
    self.seaTarget = {}

    for i, vehicle in pairs(ActorManager.vehicles) do
        if vehicle ~= nil and vehicle ~= self.vehicleObject then
            if vehicle.isAirplane or vehicle.isHelicopter then
                self.target[#self.target + 1] = vehicle
            elseif vehicle.isBoat then
                self.groundTarget[#self.groundTarget + 1] = vehicle
                self.seaTarget[#self.seaTarget + 1] = vehicle
            else
                self.groundTarget[#self.groundTarget + 1] = vehicle
            end
        end
    end
end