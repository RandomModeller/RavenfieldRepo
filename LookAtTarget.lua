behaviour("LookAtTarget") -- v1.0.0

function LookAtTarget:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.weapon = self.targets.weapon.GetComponent(Weapon)

    self.speed = self.dataContainer.GetFloat("speed") * Mathf.Deg2Rad
    self.clampXMin = self.dataContainer.GetFloat("clampXMin")
    self.clampYMin = self.dataContainer.GetFloat("clampYMin")
    self.clampXMax = self.dataContainer.GetFloat("clampXMax")
    self.clampYMax = self.dataContainer.GetFloat("clampYMax")

    -- self.target = self:GetRandomTarget()
end

function LookAtTarget:Update()
    -- if self.vehicle.driver ~= nil then
    --     if self.vehicle.driver.squad ~= nil then
    --         if self.vehicle.driver.squad.attackTarget ~= nil then
    --             self.target = self.vehicle.driver.squad.attackTarget.centerPosition
    --         else
    --             if Random.Range(0, 1) > 0.95 then
    --                 self.target = self:GetRandomTarget()
    --             end
    --         end
    --     else
    --         if Random.Range(0, 1) > 0.95 then
    --             self.target = self:GetRandomTarget()
    --         end
    --     end
    -- else
    --     if Random.Range(0, 1) > 0.95 then
    --         self.target = self:GetRandomTarget()
    --     end
    -- end


    if self.weapon.user ~= nil then
        local delta = self.weapon.user.facingDirection
        local direction = Vector3.RotateTowards(self.transform.forward, delta, self.speed * Time.deltaTime, 0)
        self.transform.rotation = Quaternion.LookRotation(direction)

        -- local localEulerAngles = self.transform.localEulerAngles
        -- localEulerAngles.x = Mathf.Clamp(localEulerAngles.x, self.clampXMin, self.clampXMax)
        -- localEulerAngles.y = Mathf.Clamp(localEulerAngles.y, self.clampYMin, self.clampYMax)
        -- self.transform.localEulerAngles = localEulerAngles
    end
end

function LookAtTarget:GetRandomTarget()
    return Vector3(Random.Range(-3000, 3000), Random.Range(0, 1000), Random.Range(-3000, 3000))
end