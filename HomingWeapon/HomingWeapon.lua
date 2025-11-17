behaviour("HomingWeapon")

function HomingWeapon:start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.maxRange = self.dataContainer.GetFloat("maxRange")
    self.maxRangeSqr = self.maxRange * self.maxRange
    self.maxAngle = self.dataContainer.GetFloat("maxAngle")
    self.maxAngleCosSqr = Mathf.Pow(Mathf.Cos(Mathf.Deg2Rad * self.maxAngle), 2)
    self.trackingSpeed = self.dataContainer.GetFloat("trackingSpeed")

    self.wpn = self.targets.weapon.GetComponent(Weapon)
    self.wpn.onSpawnProjectiles.AddListener(self, "OnFire")

    self.targetDesignatorBox = self.targets.targetDesignatorBox.GetComponent(RectTransform)
    self.refreshDelay = self.dataContainer.GetFloat("delay")
    self.next = Time.time + self.refreshDelay
    self.outOfBoundsPos = Vector2(9999, 9999)
end

function HomingWeapon:Update()
    if Time.time >= self.next then
        local matrix = self.transform.worldToLocalMatrix

        local actorsInRange = {}
        local actorPosition = nil
        local foundActor = false

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
                actorPosition = actor.centerPosition
                foundActor = true

                break
            end
        end

        if foundActor then
            local position = PlayerCamera.fpCamera.WorldToScreenPoint(actorPosition)

            self.targetDesignatorBox.position = position
        else
            self.targetDesignatorBox.anchoredPosition = self.outOfBoundsPos
        end

        self.next = self.next + self.refreshDelay
    end
end

function HomingWeapon:OnFire(projectiles)
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
            local homingScript = projectiles[1].gameObject.GetComponent(ScriptedBehaviour).self

            homingScript.projectile = projectiles[1]
            homingScript.target = actor
            homingScript.aimSpeed = self.trackingSpeed * Mathf.Deg2Rad

            break
        end
    end
end
