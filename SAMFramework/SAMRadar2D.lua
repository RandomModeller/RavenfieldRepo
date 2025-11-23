behaviour("SAMRadar2D") --v1.0.0

function SAMRadar2D:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.radarOrigin = self.targets.radarOrigin.transform

    self.iconParent = self.targets.iconParent.transform
    self.icon = self.targets.icon
    self.blips = {}
    self.blipPositionMultiplier = self.dataContainer.GetFloat("blipPositionMultiplier")
    self.blipPositionMultiplierVertical = self.dataContainer.GetFloat("blipPositionMultiplierVertical")
    self.iconScale = self.dataContainer.GetVector("blipScale")

    self.elapsed = 0
    self.delay = self.dataContainer.GetFloat("delay")

    self.range = self.dataContainer.GetFloat("range")
    self.scanAngle = Mathf.Cos(self.dataContainer.GetFloat("scanAngle") * Mathf.Deg2Rad) ^ 2
    self.azimuthMult = 1 / Mathf.Tan(Mathf.Deg2Rad * self.dataContainer.GetFloat("scanAngle"))

    self.usePositionTick = self.dataContainer.GetBool("usePositionTick")
    self.positionTick = self.dataContainer.GetFloat("positionTick")
    
    self.transform = self.gameObject.transform
end

function SAMRadar2D:CreateDot()
    local newIcon = self.gameObject.Instantiate(self.icon, self.iconParent)
    local iconTrans = newIcon.transform

    iconTrans.localScale = self.iconScale
    iconTrans.localRotation = Quaternion.identity
    self.blips[#self.blips + 1] = newIcon.GetComponent(ScriptedBehaviour).self
end

function SAMRadar2D:EnableDot(index)
    if self.blips[index].gameObject.activeSelf then
        return
    end

    self.blips[index].gameObject.SetActive(true)
end

function SAMRadar2D:DisableDot(index)
    if not self.blips[index].gameObject.activeSelf then
        return
    end

    self.blips[index].gameObject.SetActive(false)
end

function SAMRadar2D:Update()
    self.elapsed = self.elapsed + Time.deltaTime

    if self.elapsed >= self.delay then
        local vehiclePos = self.radarOrigin.position
        local matrix = self.radarOrigin.worldToLocalMatrix
        vehiclePos.y = 0

        local vehicles = {}

        for i, vehicle in pairs(ActorManager.vehicles) do
            if vehicle.isAirplane or vehicle.isHelicopter then
                vehicles[#vehicles + 1] = vehicle
            end
        end

        local vehicleCount = #vehicles

        if vehicleCount > #self.blips then
            for i = 1, vehicleCount - #self.blips do
                self:CreateDot()
            end
        end

        for i, vehicle in pairs(vehicles) do
            if vehicle ~= nil and vehicle.spotChanceMultiplier > 0 then
                local flag1 = i > vehicleCount

                if flag1 then
                    self:DisableDot(i)
                else
                    self:EnableDot(i)

                    local vehiclePos1 = vehicles[i].transform.position
                    -- local height = position.y
                    local b = vehiclePos1 - vehiclePos
                    local show = self:VectorAngleSmaller(self.radarOrigin.forward, b, self.scanAngle)

                    if show then
                        local relativePosition = matrix.MultiplyPoint3x4(vehiclePos1)
                        local pos = Vector2(relativePosition.x * self.azimuthMult * self.blipPositionMultiplier * 2, relativePosition.z * self.blipPositionMultiplierVertical) / self.range

                        for j, blip in pairs(self.blips) do
                            if blip.available or blip.vehicle == vehicle then
                                blip.available = false
                                blip.endTime = Time.time + self.delay - 0.0000001
                                blip.vehicle = vehicle

                                if self.usePositionTick then
                                    pos.x = Mathf.Floor(pos.x / self.positionTick) * self.positionTick
                                    pos.y = Mathf.Floor(pos.y / self.positionTick) * self.positionTick
                                end

                                blip.rectTransform.anchoredPosition = pos
                                break
                            end
                        end
                    end
                end
            else
                self:DisableDot(i)
            end
        end
        self.elapsed = self.elapsed - self.delay
    end
end

function SAMRadar2D:VectorAngleSmaller(a, b, cos)
    -- a magnitude has to be 1

    --return Vector3.Angle(a, b) < Mathf.Acos(cos) * Mathf.Rad2Deg

    --return cos > Vector3.Dot(a, b) / b.magnitude

    local dot = Vector3.Dot(a, b)

    return (cos < (dot ^ 2) / b.sqrMagnitude) and (dot > 0)
end