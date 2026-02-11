behaviour("DynamicHydropneumatic") --v1.1.0

function DynamicHydropneumatic:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.hull = self.targets.hull.transform
    self.fakePitch = self.targets.fakePitch.transform
    self.originalPitch = self.targets.originalPitch.transform
    self.originalBearing = self.targets.originalBearing.transform

    self.pitchMaxNormal = self.dataContainer.GetFloat("pitchMaxNormal")
    self.pitchMaxExtra = self.dataContainer.GetFloat("pitchMaxExtra")
    self.pitchMinNormal = self.dataContainer.GetFloat("pitchMinNormal")
    self.pitchMinExtra = self.dataContainer.GetFloat("pitchMinExtra")
    self.speed = self.dataContainer.GetFloat("speed")

    if self.targets.audio ~= nil then
        self.audio = self.targets.audio.GetComponent(AudioSource)
    end

end

function DynamicHydropneumatic:Update()
    local pitch = (self.fakePitch.localEulerAngles.x + 180) % 360 - 180
    local bearing = self.originalBearing.localEulerAngles.y

    local targetRotation = Quaternion.identity

    local delta = 0

    if pitch > self.pitchMaxNormal or pitch < self.pitchMinNormal then
        
        if pitch > self.pitchMaxNormal then
            delta = self.pitchMaxNormal - pitch
        elseif pitch < self.pitchMinNormal then
            delta = self.pitchMinNormal - pitch
        end

        targetRotation = Quaternion.AngleAxis(-delta, Quaternion.AngleAxis(-self.hull.parent.localEulerAngles.y, Vector3.up) * self.originalBearing.right)
    end

    local move = Quaternion.Angle(self.hull.localRotation, targetRotation) > 0.5

    if move then
        self.hull.localRotation = Quaternion.RotateTowards(self.hull.localRotation, targetRotation, self.speed * Time.deltaTime)
    end

    local rotation = self.fakePitch.localEulerAngles
    rotation.x = Mathf.Clamp(pitch, self.pitchMinNormal, self.pitchMaxNormal)

    self.originalPitch.localEulerAngles = rotation

    if self.audio ~= nil then
        if self.audio.isPlaying ~= move then
            if move then
                self.audio:Play()
            else
                self.audio:Stop()
            end
        end
    end
end
