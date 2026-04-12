behaviour("FalconCalculateBomb") --v1.0.0

function FalconCalculateBomb:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.vehicleTransform = self.targets.vehicleObject.transform
    self.vehicleRigidbody = self.targets.vehicleObject.GetComponent(Rigidbody)
    -- self.fcr = self.targets.fcr.GetComponent(ScriptedBehaviour).self

    self.offset = self.dataContainer.GetFloat("offset")
end

function FalconCalculateBomb:GetCCRPAngle(origin, target, velocity)
    local gravity = -Physics.gravity.y
    local diff = target - origin

    local y = diff.y
    local x = Mathf.Sqrt(diff.x ^ 2 + diff.z ^ 2)
    local gx = gravity * x
    local speed2 = velocity.sqrMagnitude
    local speed4 = speed2 ^ 2

    local root = speed4 - gravity * (gravity * x * x + 2 * y * speed2);

    if root < 0 then
        return 0
    end

    root = Mathf.Sqrt(root)

    local result1 = Mathf.Atan2(speed2 - root, gx) * Mathf.Rad2Deg + self.vehicleTransform.localEulerAngles.x
    local result2 = Mathf.Atan2(speed2 + root, gx) * Mathf.Rad2Deg + self.vehicleTransform.localEulerAngles.x

    return result1, result2
end

function FalconCalculateBomb:GetCCIPPosition(origin, target, velocity, skipHeightCalc)
    local gravity = -Physics.gravity.y

    local y = target

    if not skipHeightCalc then
        y = Mathf.Abs((target - origin).y)
    end

    y = y - self.offset

    local vy = velocity.y
    local disc = (4 * vy * vy) - (8 * gravity * -y)

    if disc < 0 then
        return Vector3.zero
    end

    local root = Mathf.Sqrt(disc)

    local tof = (2 * vy + root) / (2 * gravity)

    local deltaY = (velocity.y - 0.5 * gravity * tof) * tof

    return origin + Vector3(velocity.x * tof, deltaY, velocity.z * tof)
end