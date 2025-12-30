behaviour("FalconEngine") --v1.1.0

function FalconEngine:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.vehicle = self.targets.vehicleObject.GetComponent(Airplane)
    self.avionics = self.targets.avionics.GetComponent(ScriptedBehaviour).self

    self.power = 0 -- 0-100 = mil, 100-200 = afterburner
    self.powerPerSecond = 70
    self.milPowerMax = self.dataContainer.GetFloat("milPowerMax")
    self.afterburnerPowerMax = self.dataContainer.GetFloat("afterburnerPowerMax")

    if self.targets.throttle ~= nil then
        self.throttle = self.targets.throttle.transform
        self.throttleRotMin = self.dataContainer.GetFloat("throttleRotMin")
        self.throttleRotAft = self.dataContainer.GetFloat("throttleRotAft")
        self.throttleRotMax = self.dataContainer.GetFloat("throttleRotMax")

        self.throttle.localEulerAngles = Vector3(self.throttleRotMin, 0, 0)
    end

    if self.targets.nozzle ~= nil then
        self.nozzle = self.targets.nozzle.GetComponent(SkinnedMeshRenderer)
        self.nozzlePos = 0
        self.targetNozzlePos = 0
        self.nozzlePosPerSecond = 90

        self.nozzle.SetBlendShapeWeight(0, 0)
    end

    self.defaultAcceleration = self.vehicle.acceleration
    self.defaultAccelerationThrottleUp = self.vehicle.accelerationThrottleUp
    self.defaultAccelerationThrottleDown = self.vehicle.accelerationThrottleDown

    self.vehicle.acceleration = 0
    self.vehicle.accelerationThrottleDown = 0
    self.vehicle.accelerationThrottleUp = 0


end

function FalconEngine:Update()
    if not self.vehicle.playerIsInside then
        self.vehicle.acceleration = self.defaultAcceleration
        self.vehicle.accelerationThrottleUp = self.defaultAccelerationThrottleUp
        self.vehicle.accelerationThrottleDown = self.defaultAccelerationThrottleDown
    else
        if self.avionics.wsInput ~= 0 then
            self:UpdateThrottle(self.avionics.wsInput)
        end
    
        if self.nozzle ~= nil then
            self.nozzlePos = Mathf.MoveTowards(self.nozzlePos, self.targetNozzlePos, self.nozzlePosPerSecond * Time.deltaTime)
        
            self.nozzle.SetBlendShapeWeight(0, self.nozzlePos)
        end
    end
end

function FalconEngine:UpdateThrottle(input)
    if input == nil then
        return
    end

    self.power = Mathf.Clamp(self.power + self.powerPerSecond * Time.deltaTime * input, 0, 200)

    local accel = self:Lerp3Point(0, self.milPowerMax, self.afterburnerPowerMax, self.power)

    self.vehicle.acceleration = accel
    self.vehicle.accelerationThrottleDown = accel
    self.vehicle.accelerationThrottleUp = accel

    self:UpdateVisual()
end

function FalconEngine:UpdateVisual()
    if self.throttle ~= nil then
        self.throttle.localEulerAngles = Vector3(self:Lerp3Point(
                                                                self.throttleRotMin,
                                                                self.throttleRotAft,
                                                                self.throttleRotMax,
                                                                self.power),
                                                0, 0)
    end
    
    if self.nozzle ~= nil then
        if self.power < 5 then
            self.targetNozzlePos = Mathf.Lerp(0, 100, self.power / 5)
        elseif self.power <= 100 then
            self.targetNozzlePos = 100
        else
            self.targetNozzlePos = Mathf.Lerp(100, 0, (self.power - 100) / 100)
        end
    end
end

function FalconEngine:Lerp3Point(valA, valB, valC, value)
    if value > 100 then
        return Mathf.Lerp(valB, valC, (value - 100) / 100)
    else
        return Mathf.Lerp(valA, valB, value / 100)
    end
end
