behaviour("SAMFaceTarget")

function SAMFaceTarget:Start()
    -- if self.targets.radar then
    --     self.radar = self.targets.radar.GetComponent(ScriptedBehaviour).self
    -- end
    self.bearing = self.targets.bearing.transform
    self.pitch = self.targets.pitch.transform
    self.target = self.targets.target.transform

    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.speed = self.dataContainer.GetFloat("rotationSpeed")
    self.pitchMin = self.dataContainer.GetFloat("pitchMin")
    self.pitchMax = self.dataContainer.GetFloat("pitchMax")
    self.pitchOffset = self.dataContainer.GetFloat("pitchOffset")

    self.lastRot = self.pitch.rotation
end

function SAMFaceTarget:Update()
    local pos = self.target.position

    -- if self.radar then
    --     if self.radar.lockedVehicle then
    --         pos = self.radar.lockedVehicle.transform.position
    --     else
    --         return
    --     end
    -- end


    local bearingVector = self.bearing.InverseTransformPoint(pos)
    bearingVector.y = 0

    if bearingVector.sqrMagnitude < 0.0004 then
        bearingVector = -Vector3.forward
    end

    self.bearing.rotation = Quaternion.RotateTowards(self.bearing.rotation, Quaternion.LookRotation(self.bearing.TransformPoint(bearingVector) - self.bearing.position, self.bearing.up), self.speed * Time.deltaTime)
    self.pitch.rotation = Quaternion.RotateTowards(self.lastRot, Quaternion.LookRotation(pos - self.pitch.position, self.bearing.up), self.speed * Time.deltaTime)
    self.lastRot = self.pitch.rotation
    local rot = self.pitch.localEulerAngles
    rot.x = Mathf.Clamp(((rot.x + 540) % 360) - 180, self.pitchMin, self.pitchMax) + self.pitchOffset
    rot.y = 0
    rot.z = 0
    self.pitch.localEulerAngles = rot
end