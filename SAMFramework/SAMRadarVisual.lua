behaviour("SAMRadarVisual") --v1.1.1

function SAMRadarVisual:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.radarOrigin = self.targets.radarOrigin.transform
    self.transform = self.gameObject.transform

    self.lockAngle = Mathf.Cos(self.dataContainer.GetFloat("lockAngle") * Mathf.Deg2Rad) ^ 2

    self.loadedKeybind = false

    self.activateWhenCanLock = self.targets.activateWhenCanLock
    self.activateWhenLock = self.targets.activateWhenLock
end

function SAMRadarVisual:Update()
    if not self.loadedKeybind then
        self:LoadKeybind()

        self.loadedKeybind = true
    end

    local vehicleToLock = nil

    if self.activateWhenCanLock ~= nil then
        vehicleToLock = self:FindTargetToLock()

        if self.activateWhenCanLock ~= nil then
            self.activateWhenCanLock.SetActive(vehicleToLock ~= false)
        end
    end

    if (Input.GetKeyDown(self.lockKey) or (GameManager.isTestingContentMod and Input.GetKeyDown("\\"))) then -- thx to Nuclear Oven
        if self.lockedVehicle then
            self.lockedVehicle = nil
        elseif vehicleToLock ~= false then
            if vehicleToLock == nil then
                vehicleToLock = self:FindTargetToLock()
            end
            self.lockedVehicle = vehicleToLock
        end
    end

    if self.activateWhenLock ~= nil then
        self.activateWhenLock.SetActive(self.lockedVehicle ~= nil)
    end
end

function SAMRadarVisual:FindTargetToLock()
    local vehiclePos = self.radarOrigin.position
    local vehicles = {}

    for i, vehicle in pairs(ActorManager.vehicles) do
        if vehicle.isAirplane or vehicle.isHelicopter then
            vehicles[#vehicles + 1] = vehicle
        end
    end

    for i, vehicle in pairs(vehicles) do
        local position = vehicle.transform.position

        local b = position - vehiclePos

        -- local inRange = b.sqrMagnitude < self.acmRange * 4
        local inCone = self:PointInsideCone(position, self.lockAngle)

        if inCone then
            return vehicle
        end
    end

    return false
end

function SAMRadarVisual:VectorAngleSmaller(a, b, cos)
    -- a magnitude has to be 1

    --return Vector3.Angle(a, b) < Mathf.Acos(cos) * Mathf.Rad2Deg

    --return cos > Vector3.Dot(a, b) / b.magnitude

    local dot = Vector3.Dot(a, b)

    return (cos < (dot ^ 2) / b.sqrMagnitude) and (dot > 0)
end

function SAMRadarVisual:PointInsideCone(b, cos)
    return self:VectorAngleSmaller(self.radarOrigin.forward, b - self.radarOrigin.position, cos)
end

function SAMRadarVisual:LoadKeybind()
    local script = GameObject.Find("SAM Config(Clone)")

    if script then
        script = script.GetComponent(ScriptedBehaviour).self
       
        if script then
            self.lockKey = script.DebilSAMConfig_Lock
        end
    end
    if self.lockKey == nil then
        self.lockKey = KeyCode.Mouse2
    end
end

