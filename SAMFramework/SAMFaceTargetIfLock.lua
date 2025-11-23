behaviour("SAMFaceTargetIfLock") --v1.0.0

function SAMFaceTargetIfLock:Start()
    self.vehicle = self.targets.vehicleObject.GetComponent(Vehicle)
    self.bearing = self.targets.bearing.transform
    self.pitch = self.targets.pitch.transform
    self.fakeBearing = self.targets.fakeBearing.transform
    self.fakePitch = self.targets.fakePitch.transform
    self.target = self.targets.target.transform

    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.speed = self.dataContainer.GetFloat("rotationSpeed")
    self.pitchMin = self.dataContainer.GetFloat("pitchMin")
    self.pitchMax = self.dataContainer.GetFloat("pitchMax")
    self.pitchOffset = self.dataContainer.GetFloat("pitchOffset")

    self.targetLastLocalPosition = self.target.localPosition

    self.lastRot = self.pitch.rotation
end

function SAMFaceTargetIfLock:Update()
    local bearingTarget = nil
    local pitchTarget = nil

    if not self.vehicle.playerIsInside or self.targetLastLocalPosition == self.target.localPosition then
        bearingTarget = self.fakeBearing.rotation
        pitchTarget = self.fakePitch.rotation
    else
        local pos = self.target.position

        local bearingVector = self.bearing.InverseTransformPoint(pos)
        bearingVector.y = 0
    
        if bearingVector.sqrMagnitude < 0.0004 then
            bearingVector = -Vector3.forward
        end

        bearingTarget = Quaternion.LookRotation(self.bearing.TransformPoint(bearingVector) - self.bearing.position, self.bearing.up)
        pitchTarget = Quaternion.LookRotation(pos - self.pitch.position, self.bearing.up)
    end
    
    self.bearing.rotation = Quaternion.RotateTowards(self.bearing.rotation, bearingTarget, self.speed * Time.deltaTime)
    self.pitch.rotation = Quaternion.RotateTowards(self.lastRot, pitchTarget, self.speed * Time.deltaTime)
    self.lastRot = self.pitch.rotation
    local rot = self.pitch.localEulerAngles
    rot.x = Mathf.Clamp(((rot.x + 540) % 360) - 180, self.pitchMin, self.pitchMax) + self.pitchOffset
    rot.y = 0
    rot.z = 0
    self.pitch.localEulerAngles = rot
    self.targetLastLocalPosition = self.target.localPosition
end