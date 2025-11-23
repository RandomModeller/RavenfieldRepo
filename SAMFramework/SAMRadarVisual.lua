behaviour("SAMRadarVisual") --v1.0.0

function SAMRadarVisual:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.radarOrigin = self.targets.radarOrigin.transform
    self.transform = self.gameObject.transform

    self.lockAngle = Mathf.Cos(self.dataContainer.GetFloat("lockAngle") * Mathf.Deg2Rad) ^ 2

    self.loadedKeybind = false
end

function SAMRadarVisual:Update()
    if not self.loadedKeybind then
        self:LoadKeybind()

        self.loadedKeybind = true
    end

    if Input.GetKeyDown(self.lockKey) or (GameManager.isTestingContentMod and Input.GetKeyDown("\\")) then
        if self.lockedVehicle then
            self.lockedVehicle = nil
        else
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
                    self.lockedVehicle = vehicle
                    break
                end
            end
        end
    end
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