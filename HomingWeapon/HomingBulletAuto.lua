behaviour("HomingBulletAuto") --1.0.0

function HomingBulletAuto:Start()
    self.projectile = self.targets.projectile
    self.dataContainer = self.targets.dataContainer

    self.maxRange = self.dataContainer.GetFloat("maxRange")
    self.maxRangeSqr = self.maxRange * self.maxRange
    self.maxAngle = self.dataContainer.GetFloat("maxAngle")
    self.maxAngleCosSqr = Mathf.Pow(Mathf.Cos(Mathf.Deg2Rad * self.maxAngle), 2)
    self.aimSpeed = self.dataContainer.GetFloat("trackingSpeed") * Mathf.Deg2Rad

    local matrix = self.transform.worldToLocalMatrix

    local actorsInRange = {}

    for i, actor in pairs(ActorManager.actors) do
        if self.maxRangeSqr >= (actor.centerPosition - self.transform.position).sqrMagnitude and not actor.isDead then
            actorsInRange[#actorsInRange + 1] = actor
        end
    end

    for j, actor in pairs(actorsInRange) do
        local localPosition = matrix.MultiplyPoint3x4(actor.centerPosition)

        local zSqr = Mathf.Pow(localPosition.z, 2)

        local inCone = zSqr / localPosition.sqrMagnitude > self.maxAngleCosSqr
        local inFront = localPosition.z > 0

        if (inCone and inFront) then

            self.target = actor
            break
        end
    end
end

function HomingBulletAuto:Update()
    if (self.projectile == nil) or (self.target == nil) then
        return
    end

    self.projectile.velocity = Vector3.RotateTowards(self.projectile.velocity, self.target.centerPosition - self.transform.position, self.aimSpeed * Time.deltaTime, 0)
end