behaviour("DynamicHydropneumatic") --v1.0.0

function DynamicHydropneumatic:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    -- self.wheels = self.dataContainer.GetGameObjectArray("wheel")

    self.hull = self.targets.hull.transform
    self.fakePitch = self.targets.fakePitch.transform
    self.originalPitch = self.targets.originalPitch.transform
    self.originalBearing = self.targets.originalBearing.transform

    self.pitchMaxNormal = self.dataContainer.GetFloat("pitchMaxNormal")
    self.pitchMaxExtra = self.dataContainer.GetFloat("pitchMaxExtra")
    self.pitchMinNormal = self.dataContainer.GetFloat("pitchMinNormal")
    self.pitchMinExtra = self.dataContainer.GetFloat("pitchMinExtra")
    self.speed = self.dataContainer.GetFloat("speed")
end

function DynamicHydropneumatic:Update()
    local pitch = (self.fakePitch.localEulerAngles.x + 180) % 360 - 180
    local bearing = self.originalBearing.localEulerAngles.y

    local targetRotation = Quaternion.identity

    if pitch > self.pitchMaxNormal or pitch < self.pitchMinNormal then
        local delta = 0
        
        if pitch > self.pitchMaxNormal then
            delta = self.pitchMaxNormal - pitch
        elseif pitch < self.pitchMinNormal then
            delta = self.pitchMinNormal - pitch
        end

        targetRotation = Quaternion.AngleAxis(-Mathf.Round(delta * 2) / 2, self.originalBearing.right) -- round it to nearest multiple of 0.5 prevent jitter
    end

    self.hull.localRotation = Quaternion.RotateTowards(self.hull.localRotation, targetRotation, self.speed * Time.deltaTime)

    local rotation = self.fakePitch.localEulerAngles
    rotation.x = Mathf.Clamp(pitch, self.pitchMinNormal, self.pitchMaxNormal)

    self.originalPitch.localEulerAngles = rotation
end