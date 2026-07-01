behaviour("RotatingMortar") --v2.1.0

function RotatingMortar:Start()
    self.seat = self.targets.seat.GetComponent(Seat)

    self.indicator = self.targets.indicator.transform
    self.bearing = self.targets.bearing.transform
    self.pitch = self.targets.pitch.transform

    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.minAngle = self.dataContainer.GetFloat("minAngle")
    self.maxAngle = self.dataContainer.GetFloat("maxAngle")
    self.minRange = self.dataContainer.GetFloat("minRange")
    self.maxRange = self.dataContainer.GetFloat("maxRange")
    self.speed = self.dataContainer.GetFloat("rotationSpeed")
    self.rangeDelta = self.maxRange - self.minRange
    self.angleDelta = self.maxAngle - self.minAngle
end

function RotatingMortar:LateUpdate()
    if self.seat.occupant ~= nil then
        -- calculate bearing rotation
        local bearingTarget = Vector3.zero

        if self.seat.occupant == Player.actor then
            bearingTarget = self.indicator.position
        elseif self.seat.occupant.aiController.currentAttackTarget ~= nil then
            bearingTarget = self.seat.occupant.aiController.currentAttackTarget.position
        else
            self.bearing.rotation = Quaternion.RotateTowards(self.bearing.rotation, Quaternion.LookRotation(Vector3(self.seat.occupant.facingDirection.x, 0, self.seat.occupant.facingDirection.z), self.bearing.parent.up), self.speed * Time.deltaTime)
            self.pitch.localEulerAngles = Vector3(Mathf.MoveTowards((self.pitch.localEulerAngles.x + 540) % 360 - 180, Mathf.Clamp(-Mathf.Asin(self.seat.occupant.facingDirection.y) * Mathf.Rad2Deg, self.maxAngle, self.minAngle), Time.deltaTime * self.speed), self.pitch.localEulerAngles.y, self.pitch.localEulerAngles.z)
            return
        end

        local bearingVector = self.bearing.InverseTransformPoint(bearingTarget)
        bearingVector.y = 0

        if bearingVector.sqrMagnitude < 0.0004 then
            bearingVector = -Vector3.forward
        end
        
        self.bearing.rotation = Quaternion.RotateTowards(self.bearing.rotation, Quaternion.LookRotation(self.bearing.TransformPoint(bearingVector) - self.bearing.position, self.bearing.parent.up), self.speed * Time.deltaTime)

        bearingTarget.y = self.bearing.position.y

        local range = Vector3.Distance(self.bearing.position, bearingTarget)
        local ratio = Mathf.Max((range - self.minRange) / self.rangeDelta, 0)
        local angle = ratio * self.angleDelta + self.minAngle

        self.pitch.localEulerAngles = Vector3(Mathf.MoveTowards((self.pitch.localEulerAngles.x + 540) % 360 - 180, angle, Time.deltaTime * self.speed), self.pitch.localEulerAngles.y, self.pitch.localEulerAngles.z)
    end
end
