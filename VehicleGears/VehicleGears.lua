behaviour("VehicleGears") --v3.1.0

function VehicleGears:Start()
    self.vehicle = self.targets.vehicleObject.GetComponent(Car)
    self.vehicleTransform = self.targets.vehicleObject.transform
    self.vehicleRigidbody = self.targets.vehicleObject.GetComponent(Rigidbody)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.fwdDragValues = self:Split(self.dataContainer.GetString("forwardDragValues"), " ")
    self.fwdAccValues = self:Split(self.dataContainer.GetString("forwardAccValues"), " ")
    self.fwdSpeedLimit = self:Split(self.dataContainer.GetString("forwardSpeedLimit"), " ") -- HAS to be in descending order
    self.revDragValues = self:Split(self.dataContainer.GetString("reverseDragValues"), " ")
    self.revAccValues = self:Split(self.dataContainer.GetString("reverseAccValues"), " ")
    self.revSpeedLimit = self:Split(self.dataContainer.GetString("reverseSpeedLimit"), " ") -- HAS to be in descending order

    self.hasNeutral = false
    if self.dataContainer.HasBool("hasNeutral") then
        self.hasNeutral = self.dataContainer.GetBool("hasNeutral")
        self.neutralDragValue = self.dataContainer.GetFloat("neutralDragValue")
        self.neutralAccValue = self.dataContainer.GetFloat("neutralAccValue")
    end

    self.neutralInWater = false
    if self.dataContainer.HasBool("neutralInWater") then
        self.neutralInWater = self.dataContainer.GetBool("neutralInWater") and self.hasNeutral
    end

    self.fwdGearCount = #self.fwdSpeedLimit
    
    self.revGearCount = #self.revSpeedLimit

    if self.targets.gearText ~= nil then
        self.gearText = self.targets.gearText.GetComponent(Text)

        self.forwardPrefix = self.dataContainer.GetString("forwardPrefix")
        self.reversePrefix = self.dataContainer.GetString("reversePrefix")
        self.forwardSuffix = self.dataContainer.GetString("forwardSuffix")
        self.reverseSuffix = self.dataContainer.GetString("reverseSuffix")
    end

    if self.targets.soundBank ~= nil then
        self.hitchSoundBank = self.targets.soundBank.GetComponent(SoundBank)
    end
    self.lastDrag = -1
    self.lastAcc = -1

    self.neutralHitchDrag = 0
    if self.dataContainer.HasFloat("hitchDragNeutral") and self.hasNeutral then
        self.neutralHitchDrag = self.dataContainer.GetFloat("hitchDragNeutral")
    end

    self.neutralHitchAcc = 0
    if self.dataContainer.HasFloat("hitchAccNeutral") and self.hasNeutral then
        self.neutralHitchAcc = self.dataContainer.GetFloat("hitchAccNeutral")
    end

    self.forwardHitchDrags = self:Split(self.dataContainer.GetString("forwardHitchDrags"), " ")
    self.forwardHitchAccs = self:Split(self.dataContainer.GetString("forwardHitchAccs"), " ")
    self.reverseHitchDrags = self:Split(self.dataContainer.GetString("reverseHitchDrags"), " ")
    self.reverseHitchAccs = self:Split(self.dataContainer.GetString("reverseHitchAccs"), " ")

    self.fwdHitchDurations = {}
    self.revHitchDurations = {}
    self.neutralHitchDuration = 0

    if self.dataContainer.HasFloat("hitchDuration") then
        local duration = self.dataContainer.GetFloat("hitchDuration")

        for i = 1, #self.fwdSpeedLimit do
            self.fwdHitchDurations[i] = duration
        end

        for i = 1, #self.revSpeedLimit do
            self.revHitchDurations[i] = duration
        end

        self.neutralHitchDuration = duration
    else
        self.fwdHitchDurations = self:Split(self.dataContainer.GetString("fwdHitchDurations"), " ")
        self.revHitchDurations = self:Split(self.dataContainer.GetString("revHitchDurations"), " ")
        self.neutralHitchDuration = self.dataContainer.GetFloat("neutralHitchDuration")
    end

    --self.hitchDuration = self.dataContainer.GetFloat("hitchDuration")
    self.controlGainDelay = self.dataContainer.GetFloat("controlDelay")
    self.hitchPower = self.dataContainer.GetFloat("hitchPower")

    self.hillBase = self.dataContainer.GetFloat("hillBase")
    self.hillBaseDelta = 1 - self.hillBase
    self.hillBaseFactor = self.hillBaseDelta / 90
    self.hillNeutral = 36000
    if self.dataContainer.HasFloat("hillNeutral") and self.hasNeutral then
        self.hillNeutral = self.dataContainer.GetFloat("hillNeutral")
    end

    self.durationLeft = 0
    self.dragLeft = 0
    --self.minDrag = 0
    self.baseDrag = 0
    self.baseAcc= 0
    self.unlocked = 0

    self.lastReverse = false

    self.gear = 0

    self.cacheVelocity = 0

    --self.gearZip = self:Zip(self.availableModes, self.fireModeValues)
end

function VehicleGears:Update()
    local reverse = self.vehicle.inReverseGear
    local mode = 0

    if reverse ~= self.lastReverse then
        self.unlocked = 0
        self.lastReverse = reverse
    end

    self.cacheVelocity = math.abs(self.vehicleTransform.worldToLocalMatrix.MultiplyVector(self.vehicleRigidbody.velocity).z * 3.6)

    local tableToUse = reverse and self.revSpeedLimit or self.fwdSpeedLimit

    local angle = self.vehicleTransform.eulerAngles.x

    if angle <= 90 then
        angle = -angle
    elseif angle >= 270 then
        angle = 360 - angle
    end

    local hitchDragForFrame = self.neutralHitchDrag
    local hitchAccForFrame = self.neutralHitchAcc

    if (self.neutralInWater and self.vehicle.isInWater) or (self.hasNeutral and self.cacheVelocity <= 0.2) or (angle >= self.hillNeutral) then
        local dragForSpeed = self.neutralDragValue
        local accForSpeed = self.neutralAccValue

        self.gear = 0
            
        if dragForSpeed ~= self.lastDrag or accForSpeed ~= self.lastAcc then
            self:OnHitchChange(mode)
            self.lastDrag = dragForSpeed
            self.baseDrag = dragForSpeed

            self.lastAcc = accForSpeed
            self.baseAcc = accForSpeed
        end
        
        if self.gearText ~= nil then
            local prefix = reverse and self.reversePrefix or self.forwardPrefix
            local suffix = reverse and self.reverseSuffix or self.forwardSuffix

            self.gearText.text = prefix .. "N" .. suffix
        end
    else
        for i, speed in pairs(tableToUse) do
            if self.cacheVelocity >= speed and Time.time > self.unlocked then
                local dragForSpeed = self.fwdDragValues[i]
                local accForSpeed = self.fwdAccValues[i]

                hitchDragForFrame = self.forwardHitchDrags[i]
                hitchAccForFrame = self.forwardHitchAccs[i]

                self.gear = i
                mode = 1
                if reverse then
                    hitchDragForFrame = self.reverseHitchDrags[i]
                    hitchAccForFrame = self.reverseHitchAccs[i]

                    dragForSpeed = self.revDragValues[i]
                    accForSpeed = self.revAccValues[i]
                    mode = -1
                end

            
                if dragForSpeed ~= self.lastDrag or accForSpeed ~= self.lastAcc then
                    self:OnHitchChange(mode)
                    self.lastDrag = dragForSpeed
                    self.baseDrag = dragForSpeed

                    self.lastAcc = accForSpeed
                    self.baseAcc = accForSpeed
                end

                if self.gearText ~= nil then
                    local gearNum = reverse and self.revGearCount or self.fwdGearCount
                    local prefix = reverse and self.reversePrefix or self.forwardPrefix
                    local suffix = reverse and self.reverseSuffix or self.forwardSuffix

                    self.gearText.text = prefix .. (gearNum - i) .. suffix
                end
                break
            end
        end
    end

    local left = self.durationLeft / self:GetHitchDuration(mode)

    self.vehicle.groundDrag = self.baseDrag + hitchDragForFrame * left

    local hillFactor = 1 - (angle * self.hillBaseFactor)

    local acc = (self.baseAcc * hillFactor) + (hitchAccForFrame * left)

    if reverse then
        self.vehicle.reverseAcceleration = acc
    else
        self.vehicle.acceleration = acc
    end

    if self.durationLeft > 0 then
        self.durationLeft = self.durationLeft - Time.deltaTime
    else
        self.durationLeft = 0
    end

end

function VehicleGears:GetHitchDuration(gearType)
    if gearType == 1 then -- forward gear
        return self.fwdHitchDurations[self.gear]
    elseif gearType == 0 then -- neutral gear
        return self.neutralHitchDuration
    elseif gearType == -1 then -- reverse gear
        return self.revHitchDurations[self.gear]
    end
end

function VehicleGears:OnHitchChange(type)
    if self.hitchSoundBank ~= nil then
        self.hitchSoundBank.PlayRandom()
    end

    self.durationLeft = self:GetHitchDuration(type)
    self.unlocked = Time.time + self.durationLeft + self.controlGainDelay
    self.dragLeft = 0

    self.vehicle.engine.power = self.hitchPower
end

function VehicleGears:Split(s, delimiter)
    result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, tonumber(match))
    end
    return result   
end

function VehicleGears:Zip(keyArray, valueArray)
    result = {}

    if #keyArray ~= #valueArray then
        return error("Array length not the same!")
    end
    for i=1, #keyArray, 1 do
        result[keyArray[i]] = tonumber(valueArray[i])
    end
    return result
end
