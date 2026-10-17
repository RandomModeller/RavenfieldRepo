behaviour("BlockingTrimVane") --v1.0.0

function BlockingTrimVane:Start()
    self.vehicle = self.targets.vehicleObject.GetComponent(Vehicle)
    self.bearing = self.targets.bearing.transform
    self.pitch = self.targets.pitch.transform
    -- self.fakeBearing = self.targets.fakeBearing.transform
    self.fakePitch = self.targets.fakePitch.transform

    self.bearingMin = self.dataContainer.GetFloat("bearingMin")
    self.bearingMax = self.dataContainer.GetFloat("bearingMax")
    self.maxPitch = self.dataContainer.GetFloat("maxPitch")
end

function BlockingTrimVane:LateUpdate()
    if not self.vehicle.isInWater then
        return
    end

    local yaw = (self.bearing.localEulerAngles.y + 540) % 360 - 180

    if yaw >= self.bearingMin and yaw <= self.bearingMax then
        local pitch = self.pitch.localEulerAngles

        if pitch.x > 0 or pitch.x > self.maxPitch then
            pitch.x = self.maxPitch
        end

        self.fakePitch.localEulerAngles = pitch
    end
end