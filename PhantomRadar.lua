behaviour("PhantomRadar") --v1.0.0

function PhantomRadar:Start()
    self.vehicleObject = self.targets.vehicleObject.GetComponent(Vehicle)
    self.vehicleRigidbody = self.targets.vehicleObject.GetComponent(Rigidbody)
    self.fcr = self.targets.fcr.GetComponent(ScriptedBehaviour).self
    self.vehicleTransform = self.targets.vehicleObject.transform

    self.radarOrigin = self.targets.origin.transform
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    
    self.isGround = false
    if self.dataContainer.HasBool("isGround") then
        self.isGround = self.dataContainer.GetBool("isGround")
    end
    self.velocityVectorRotateInTWS = false
    if self.dataContainer.HasBool("velocityVectorRotateInTWS") then
        self.velocityVectorRotateInTWS = self.dataContainer.GetBool("velocityVectorRotateInTWS")
    end
    self.velocityVectorRotateInSTT = false
    if self.dataContainer.HasBool("velocityVectorRotateInSTT") then
        self.velocityVectorRotateInSTT = self.dataContainer.GetBool("velocityVectorRotateInSTT")
    end

    self.currentRange = self.dataContainer.GetFloat("range")
    self.currentAzimuth = self.dataContainer.GetFloat("azimuth")
    self.cosRwsAngle = Mathf.Cos(self.currentAzimuth * Mathf.Deg2Rad) ^ 2

    self.friendlyColor = self.dataContainer.GetColor("friendly")
    self.foeColor = self.dataContainer.GetColor("foe")

    self.viewportSize = 100
    self.lockBlipDistance = 49 -- 7^2

    self.blipParent = self.targets.blipParent.transform
    self.airBlipPrefab = self.targets.blipPrefab
    self.blips = {}
    self.blips[1] = self:CreateBlip()
    self.blips[1]:Init()
    -- self.groundBlipPrefab = self.targets.groundBlipPrefab
    -- self.groundBlips = {}
    -- self.groundBlips[1] = self:CreateGroundBlip()
    -- self.groundBlips[1]:Init()
    self.maxBlip = 999
    if self.dataContainer.HasFloat("maxBlip") then
        self.maxBlip = self.dataContainer.GetFloat("maxBlip")
    end

    self.multiplier = 1
    self:CalculateMultiplier()
    self.rangesMult = self.viewportSize / self.currentRange
    self.azimuthMult = 1 / Mathf.Tan(Mathf.Deg2Rad * self.currentAzimuth)

    self.targetTrackerTransform = self.targets.targetTrackerTransform.transform
    self.lastTargetTrackerPosition = Vector3.zero

    if self.targetTrackerTransform ~= nil then
        self.lastTargetTrackerPosition = self.targetTrackerTransform.localPosition
    end

    self.activateOnSTT = self.targets.activateOnSTT
    self.deactivateOnSTT = self.targets.deactivateOnSTT

    self.lastTime = Time.time - 0.1
    self.lastPosition = Vector3.zero
    self.lastRange = Vector3.zero
    self.targetRange = 0
end

function PhantomRadar:Update()
    if Time.time - self.lastTime < 0.1 then
        return
    else
        self.lastTime = Time.time
    end

    local matrix = self.radarOrigin.worldToLocalMatrix

    for i, blip in pairs(self.blips) do
        blip:Hide()
    end
    self.targetRange = 0

    -- for i, blip in pairs(self.groundBlips) do
    --     blip:Hide()
    -- end

    local isSTT = false

    if self.targetTrackerTransform ~= nil then
        isSTT = self.targetTrackerTransform.localPosition ~= self.lastTargetTrackerPosition

        self.lastTargetTrackerPosition = self.targetTrackerTransform.localPosition
    end

    if self.activateOnSTT ~= nil and self.activateOnSTT.activeSelf ~= isSTT then
        self.activateOnSTT.SetActive(isSTT)
    end
    if self.deactivateOnSTT ~= nil and self.deactivateOnSTT.activeSelf ~= not isSTT then
        self.deactivateOnSTT.SetActive(not isSTT)
    end

    local targetPool = self.fcr.target
    if self.isGround then
        targetPool = self.fcr.groundTarget
    end

    local count = 1

    for i, vehicle in pairs(targetPool) do
        if vehicle.spotChanceMultiplier > 0 and vehicle.driver ~= nil then
            local calculate = true

            if isSTT then
                if (self.targetTrackerTransform.position - vehicle.transform.position).sqrMagnitude > 600 then
                    calculate = false
                end
            end

            calculate = calculate and count <= self.maxBlip

            if calculate then
                local position = vehicle.transform.position
                local b = position - self.radarOrigin.position

                local show = self:VectorAngleSmaller(self.radarOrigin.forward, b, self.cosRwsAngle)

                if show then
                    position = matrix.MultiplyPoint3x4(position)
                    local widthAtRange = position.x * self.azimuthMult

                    position = Vector2(widthAtRange, position.z) * self.multiplier

                    if count > #self.blips then
                        self.blips[count] = self:CreateBlip()
                        self.blips[count]:Init()
                    end

                    self.blips[count].vehicle = vehicle

                    if vehicle.driver == nil then
                        self.blips[count]:SetColor(self.friendlyColor)
                    elseif self.vehicleObject.driver.team == vehicle.driver.team then
                        self.blips[count]:SetColor(self.friendlyColor)
                    else
                        self.blips[count]:SetColor(self.foeColor)
                    end

                    self.blips[count]:SetLockSymbol(isSTT)

                    self.blips[count].rectTransform.anchoredPosition = position

                    if isSTT then
                        self.targetRange = b.magnitude
                    end

                    if (isSTT and self.velocityVectorRotateInSTT) or (not isSTT and self.velocityVectorRotateInTWS) then
                        local relativeVelocity = Vector3.zero
                        local heading = 0

                        if vehicle.rigidbody ~= nil then
                            relativeVelocity = matrix.MultiplyPoint3x4(vehicle.rigidbody.velocity + self.radarOrigin.position)
                            heading = Mathf.Atan2(relativeVelocity.x, relativeVelocity.z) * Mathf.Rad2Deg
                        end

                        self.blips[count].rectTransform.localEulerAngles = Vector3(0, 0, -heading)
                    else
                        self.blips[count].rectTransform.localEulerAngles = Vector3.zero
                    end

                    count = count + 1
                end
            end
        end
    end

    -- for i, vehicle in pairs(self.fcr.groundTarget) do
    --     local position = vehicle.transform.position
    --     local b = position - self.radarOrigin.position

    --     local show = self:VectorAngleSmaller(self.radarOrigin.forward, b, self.cosRwsAngle)

    --     if show then
    --         position = matrix.MultiplyPoint3x4(position)
    --         local widthAtRange = position.x * self.azimuthMult

    --         position = Vector2(widthAtRange, position.z) * self.multiplier

    --         if i > #self.groundBlips then
    --             self.groundBlips[i] = self:CreateGroundBlip()
    --             self.groundBlips[i]:Init()
    --         end

    --         self.groundBlips[i].vehicle = vehicle

    --         if vehicle.driver == nil then
    --             self.groundBlips[i]:SetColor(self.friendlyColor)
    --         elseif self.vehicleObject.driver.team == vehicle.driver.team then
    --             self.groundBlips[i]:SetColor(self.friendlyColor)
    --         else
    --             self.groundBlips[i]:SetColor(self.foeColor)
    --         end

    --         self.groundBlips[i].rectTransform.anchoredPosition = position
    --     end
    -- end
end

function PhantomRadar:VectorAngleSmaller(a, b, cos)
    -- a magnitude has to be 1

    local dot = Vector3.Dot(a, b)

    return (cos < (dot ^ 2) / b.sqrMagnitude) and (dot > 0)
end

function PhantomRadar:PointInsideCone(b, cos)
    return self:VectorAngleSmaller(self.radarOrigin.forward, b - self.radarOrigin.position, cos)
end

function PhantomRadar:GetRange()
    return self.currentRange
end

function PhantomRadar:SetRange(val)
    self.currentRange = val
    self:CalculateMultiplier()
end

function PhantomRadar:CreateBlip()
    local blip = self.gameObject.Instantiate(self.airBlipPrefab, self.blipParent).GetComponent(ScriptedBehaviour).self

    return blip
end

function PhantomRadar:CreateGroundBlip()
    local blip = self.gameObject.Instantiate(self.groundBlipPrefab, self.blipParent).GetComponent(ScriptedBehaviour).self

    return blip
end

function PhantomRadar:CalculateMultiplier()
    self.multiplier = self.viewportSize / self.currentRange
end

function PhantomRadar:CalculatePosition(localPosition)
    local range = localPosition.z / self.rangesMult
    local azimuth = localPosition.x / range / self.azimuthMult

    return Vector2(range, azimuth)
end

function PhantomRadar:Split(to_split)
    words = {}

    for word in to_split:gmatch("%w+") do
        table.insert(words, tonumber(word))
    end

    return words
end