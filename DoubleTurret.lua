behaviour("DoubleTurret") --v1.0.0

function DoubleTurret:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.originalBearing = self.targets.originalBearing.transform
    self.originalPitch = self.targets.originalPitch.transform
    self.fakeBearingLarge = self.targets.fakeBearingLarge.transform
    self.fakeBearingSmall = self.targets.fakeBearingSmall.transform
    self.fakePitchLarge = self.targets.fakePitchLarge.transform
    self.fakePitchSmall = self.targets.fakePitchSmall.transform

    self.bearingSmallMin = self.dataContainer.GetFloat("bearingSmallMin")
    self.bearingSmallMax = self.dataContainer.GetFloat("bearingSmallMax")
    self.pitchSmallMin = self.dataContainer.GetFloat("pitchSmallMin")
    self.pitchSmallMax = self.dataContainer.GetFloat("pitchSmallMax")
end

function DoubleTurret:LateUpdate()
    local originalBearing = (self.originalBearing.localEulerAngles.y + 540) % 360 - 180
    local originalPitch = (self.originalPitch.localEulerAngles.x + 540) % 360 - 180

    local bearingSmall = Mathf.Clamp(originalBearing, self.bearingSmallMin, self.bearingSmallMax)
    local pitchSmall = Mathf.Clamp(originalPitch, self.pitchSmallMin, self.pitchSmallMax)

    self.fakeBearingLarge.localEulerAngles = Vector3.up * (originalBearing - bearingSmall)
    self.fakeBearingSmall.localEulerAngles = Vector3.up * bearingSmall
    self.fakePitchLarge.localEulerAngles = Vector3.right * (originalPitch - pitchSmall)
    self.fakePitchSmall.localEulerAngles = Vector3.right * pitchSmall
end