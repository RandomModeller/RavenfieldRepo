behaviour("EnemyDesignator") --v1.0.0

function EnemyDesignator:start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.maxRange = self.dataContainer.GetFloat("maxRange")
    self.maxRangeSqr = self.maxRange * self.maxRange
    self.maxAngle = self.dataContainer.GetFloat("maxAngle")
    self.maxAngleCosSqr = Mathf.Pow(Mathf.Cos(Mathf.Deg2Rad * self.maxAngle), 2)

    if self.targets.targetDesignatorBox ~= nil then
        self.targetDesignatorBox = self.targets.targetDesignatorBox.GetComponent(RectTransform)
    end
    self.refreshDelay = self.dataContainer.GetFloat("delay")
    self.next = Time.time + self.refreshDelay
    self.outOfBoundsPos = Vector2(9999, 9999)
end

function EnemyDesignator:Update()
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

            if self.targets.targetDesignatorBox ~= nil then
                self.targetDesignatorBox.position = position
            end
        else
            if self.targets.targetDesignatorBox ~= nil then
                self.targetDesignatorBox.anchoredPosition = self.outOfBoundsPos
            end
        end

        self.next = self.next + self.refreshDelay
    end
end