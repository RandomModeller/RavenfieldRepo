behaviour("SAMRadar") --v1.0.1

function SAMRadar:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.iconParent = self.targets.iconParent.transform
    self.icon = self.targets.icon
    self.blips = {}
    self.blipPositionMultiplier = self.dataContainer.GetFloat("blipPositionMultiplier")
    self.iconScale = self.dataContainer.GetVector("blipScale")

    self.elapsed = 0
    self.delay = self.dataContainer.GetFloat("delay")

    self.range = self.dataContainer.GetFloat("range")
    
    --constants
    -- self.outOfBounds = Vector2(5000, 5000)

    self.transform = self.gameObject.transform

    self.rotationSpeed = self.dataContainer.GetFloat("rotationSpeed")
    self.doubleDirection = self.dataContainer.GetBool("doubleDirection")
    self.directionVector = Vector3(1, 0, 0)
    self.lastGradient = Mathf.Infinity
    
    self.line = self.targets.line.GetComponent(RectTransform)
    if self.targets.cursor then
        self.cursor = self.targets.cursor.GetComponent(RectTransform)
    end
    if self.targets.grid then
        self.grid = self.targets.grid.GetComponent(RectTransform)
    end

    self.alignBlipToVelocityVector = false
    if self.dataContainer.HasBool("alignBlipToVelocityVector") then
        self.alignBlipToVelocityVector = self.dataContainer.GetBool("alignBlipToVelocityVector")
    end

    self.displayName = false
    if self.dataContainer.HasBool("displayName") then
        self.displayName = self.dataContainer.GetBool("displayName")
    end

    self.displayIFF = false
    if self.dataContainer.HasBool("displayIFF") then
        self.displayIFF = self.dataContainer.GetBool("displayIFF")
        if self.displayIFF then
            self.friendlyColor = self.dataContainer.GetColor("friendlyColor")
            self.foeColor = self.dataContainer.GetColor("foeColor")
            self.neutralColor = self.dataContainer.GetColor("neutralColor")
        end
    end

    self.displayVelocity = false
    if self.dataContainer.HasBool("displayVelocity") then
        self.displayVelocity = self.dataContainer.GetBool("displayVelocity")
        if self.displayVelocity then
            self.velocityMultiplier = self.dataContainer.GetFloat("velocityMultiplier")
        end
    end

    self.displayVelocityStick = false
    if self.dataContainer.HasBool("displayVelocityStick") then
        self.displayVelocityStick = self.dataContainer.GetBool("displayVelocityStick")
        if self.displayVelocityStick then
            self.velocityStickMultiplier = self.dataContainer.GetFloat("velocityStickMultiplier")
        end
    end

    self.displayAltitude = false
    if self.dataContainer.HasBool("displayAltitude") then
        self.displayAltitude = self.dataContainer.GetBool("displayAltitude")
        if self.displayAltitude then
            self.heightMultiplier = self.dataContainer.GetFloat("heightMultiplier")
        end
    end

    self.displayRange = false
    if self.dataContainer.HasBool("displayRange") then
        self.displayRange = self.dataContainer.GetBool("displayRange")
        if self.displayRange then
            self.rangeMultiplier = self.dataContainer.GetFloat("rangeMultiplier")
        end
    end
    
    self.displayMissile = false
    if self.dataContainer.HasBool("displayMissile") then
        self.displayMissile = self.dataContainer.GetBool("displayMissile")
        if self.displayMissile then
            self.missileManager = self.targets.missileManager.GetComponent(ScriptedBehaviour).self
            self.missileIcon = self.targets.missileIcon
            self.missileBlips = {}
        end
    end

    self.loadedKeybind = false
end

function SAMRadar:CreateDot()
    local newIcon = self.gameObject.Instantiate(self.icon, self.iconParent)
    local iconTrans = newIcon.transform

    iconTrans.localScale = self.iconScale
    iconTrans.localRotation = Quaternion.identity
    self.blips[#self.blips + 1] = newIcon.GetComponent(ScriptedBehaviour).self
    -- self:DisableDot(#self.blips)
end

function SAMRadar:EnableDot(index)
    if self.blips[index].gameObject.activeSelf then
        return
    end

    self.blips[index].gameObject.SetActive(true)
end

function SAMRadar:DisableDot(index)
    if not self.blips[index].gameObject.activeSelf then
        return
    end

    self.blips[index].gameObject.SetActive(false)
end

function SAMRadar:CreateMissileDot()
    local newIcon = self.gameObject.Instantiate(self.missileIcon, self.iconParent)
    local iconTrans = newIcon.transform

    iconTrans.localScale = self.iconScale
    iconTrans.localRotation = Quaternion.identity
    self.missileBlips[#self.missileBlips + 1] = newIcon.GetComponent(ScriptedBehaviour).self
end

function SAMRadar:EnableMissileDot(index)
    if self.missileBlips[index].gameObject.activeSelf then
        return
    end

    self.missileBlips[index].gameObject.SetActive(true)
end

function SAMRadar:DisableMissileDot(index)
    if not self.missileBlips[index].gameObject.activeSelf then
        return
    end

    self.missileBlips[index].gameObject.SetActive(false)
end

function SAMRadar:Update()
    if not self.loadedKeybind then
        self:LoadKeybind()

        self.loadedKeybind = true
    end

    self.elapsed = self.elapsed + Time.deltaTime

    self.directionVector = Quaternion.Euler(0, self.rotationSpeed * Time.deltaTime, 0) * self.directionVector

    local currentGradient = self.directionVector.z / self.directionVector.x
    if self.elapsed >= self.delay then
        local vehiclePos = self.transform.position
        local normalVehiclePos = vehiclePos
        vehiclePos.y = 0

        if self.grid then
            self.grid.gameObject.SetActive(self.lockedVehicle ~= nil)
        end

        if self.lockedVehicle then
            local pos = self:GetBlipPosition(self.lockedVehicle.transform.position, vehiclePos) * self.blipPositionMultiplier

            if self.grid then
                self.grid.anchoredPosition = pos
            end

            self.blips[1].rectTransform.anchoredPosition = pos
            
            if self.alignBlipToVelocityVector then
                local velocity = self.lockedVehicle.rigidbody.velocity

                if velocity.sqrMagnitude >= 10 then
                    self.blips[1].symbolRectTransform.localEulerAngles = Vector3(0, 0, -Mathf.Atan2(velocity.x, velocity.z) * Mathf.Rad2Deg)
                else
                    self.blips[1].symbolRectTransform.localRotation = Quaternion.identity
                end

                if self.displayAltitude then
                    self.blips[1].height.text = tostring(Mathf.Round(self.lockedVehicle.transform.position.y * self.heightMultiplier))
                end

                if self.displayVelocity then
                    self.blips[1].velocity.text = tostring(Mathf.Round(self.lockedVehicle.rigidbody.velocity.magnitude * self.velocityMultiplier))
                end

                if self.displayVelocityStick then
                    self.blips[1].velocityStick.localScale = Vector3(1, self.lockedVehicle.rigidbody.velocity.magnitude * self.velocityStickMultiplier, 1)
                end

                if self.displayRange then
                    self.blips[1].range.text = tostring(Mathf.Round(Vector3.Distance(self.lockedVehicle.transform.position, vehiclePos) * self.rangeMultiplier))
                end

                if self.displayName then
                    self.blips[1].name.text = self.lockedVehicle.name
                end

                if self.displayIFF then
                    if self.lockedVehicle.driver == nil then
                        self.blips[1].symbol.color = self.neutralColor
                    elseif self.lockedVehicle.driver.team == Player.actor.team then
                        self.blips[1].symbol.color = self.friendlyColor
                    else
                        self.blips[1].symbol.color = self.foeColor
                    end
                end
            end
        else
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

                        local pos = self:GetBlipPosition(vehiclePos1, vehiclePos)

                        local flag2 = self:IsInArea(currentGradient, self.lastGradient, pos.x, pos.y)
                        local flag3 = self.doubleDirection or (pos.x * self.directionVector.x >= 0 and pos.y * self.directionVector.z >= 0)
                        local flag4 = pos.sqrMagnitude <= 1

                        if flag2 and flag3 and flag4 then
                            for j, blip in pairs(self.blips) do
                                if blip.available or blip.vehicle == vehicle then
                                    blip.available = false
                                    if self.doubleDirection then
                                        blip.endTime = Time.time + 180 / self.rotationSpeed - 0.075
                                    else
                                        blip.endTime = Time.time + 360 / self.rotationSpeed - 0.15  
                                    end
                                    blip.vehicle = vehicle

                                    blip.rectTransform.anchoredPosition = pos * self.blipPositionMultiplier

                                    if self.alignBlipToVelocityVector then
                                        local velocity = vehicle.rigidbody.velocity

                                        if velocity.sqrMagnitude >= 10 then
                                            blip.symbolRectTransform.localEulerAngles = Vector3(0, 0, -Mathf.Atan2(velocity.x, velocity.z) * Mathf.Rad2Deg)
                                        else
                                            blip.symbolRectTransform.localRotation = Quaternion.identity
                                        end

                                        if self.displayAltitude then
                                            blip.height.text = tostring(Mathf.Round(vehicle.transform.position.y * self.heightMultiplier))
                                        end
                        
                                        if self.displayVelocity then
                                            blip.velocity.text = tostring(Mathf.Round(vehicle.rigidbody.velocity.magnitude * self.velocityMultiplier))
                                        end
                        
                                        if self.displayVelocityStick then
                                            blip.velocityStick.localScale = Vector3(1, vehicle.rigidbody.velocity.magnitude * self.velocityStickMultiplier, 1)
                                        end
                        
                                        if self.displayRange then
                                            blip.range.text = tostring(Mathf.Round(Vector3.Distance(vehicle.transform.position, vehiclePos) * self.rangeMultiplier))
                                        end
                        
                                        if self.displayName then
                                            blip.name.text = vehicle.name
                                        end
                        
                                        if self.displayIFF then
                                            if vehicle.driver == nil then
                                                blip.symbol.color = self.neutralColor
                                            elseif vehicle.driver.team == Player.actor.team then
                                                blip.symbol.color = self.friendlyColor
                                            else
                                                blip.symbol.color = self.foeColor
                                            end
                                        end
                                    end
                                    break
                                end
                            end
                        end

                        --blip.rotation = self.transform.rotation
                    end
                else
                    self:DisableDot(i)
                end
            end
        end

        if self.displayMissile then
            local missileCount = #self.missileManager.missiles

            if missileCount > #self.missileBlips then
                for i = 1, missileCount - #self.missileBlips do
                    self:CreateMissileDot()
                end
            end

            for i, blip in pairs(self.missileBlips) do
                local flag1 = i > missileCount

                if flag1 then
                    self:DisableMissileDot(i)
                else
                    self:EnableMissileDot(i)

                    local missile = self.missileManager.missiles[i]

                    local pos = self:GetBlipPosition(missile.transform.position, vehiclePos)

                    self.missileBlips[i].rectTransform.anchoredPosition = pos * self.blipPositionMultiplier

                    local velocity = missile.velocity

                    self.missileBlips[i].symbolRectTransform.localEulerAngles = Vector3(0, 0, -Mathf.Atan2(velocity.x, velocity.z) * Mathf.Rad2Deg)

                    if self.missileBlips[i].velocityStick ~= nil then
                        self.missileBlips[i].velocityStick.localScale = Vector3(1, velocity.magnitude * self.velocityStickMultiplier * 0.5, 1)
                    end
                end
            end
        end

        self.elapsed = self.elapsed - self.delay

        self.lastGradient = currentGradient
    end

    if self.cursor then
        if Input.GetKey(KeyCode.UpArrow) then
            self.cursor.anchoredPosition = self.cursor.anchoredPosition + Vector2(0, 0.5) * Time.deltaTime * self.blipPositionMultiplier
        end

        if Input.GetKey(KeyCode.DownArrow) then
            self.cursor.anchoredPosition = self.cursor.anchoredPosition + Vector2(0, -0.5) * Time.deltaTime * self.blipPositionMultiplier
        end

        if Input.GetKey(KeyCode.LeftArrow) then
            self.cursor.anchoredPosition = self.cursor.anchoredPosition + Vector2(-0.5, 0) * Time.deltaTime * self.blipPositionMultiplier
        end

        if Input.GetKey(KeyCode.RightArrow) then
            self.cursor.anchoredPosition = self.cursor.anchoredPosition + Vector2(0.5, 0) * Time.deltaTime * self.blipPositionMultiplier
        end

        local pos = self.cursor.anchoredPosition
        pos.x = Mathf.Clamp(pos.x, -self.blipPositionMultiplier, self.blipPositionMultiplier)
        pos.y = Mathf.Clamp(pos.y, -self.blipPositionMultiplier, self.blipPositionMultiplier)
        self.cursor.anchoredPosition = pos

        if Input.GetKeyDown(self.lockKey) or (GameManager.isTestingContentMod and Input.GetKeyDown("\\")) then
            if self.lockedVehicle then
                self.lockedVehicle = nil
            else
                local cursorPos = self.cursor.transform.position

                for i, blip in pairs(self.blips) do
                    if blip.vehicle ~= nil then
                        local delta = blip.transform.position - cursorPos

                        if delta.sqrMagnitude <= 500 then
                            self.lockedVehicle = blip.vehicle
        
                            for j, blip in pairs(self.blips) do
                                blip.available = true
                                self:DisableDot(j)
                            end
        
                            self:EnableDot(1)
                            break
                        end
                    end
                end
            end
        end
    end

    self.line.up = Vector3(self.directionVector.x, self.directionVector.z, 0)
end

function SAMRadar:GetBlipPosition(pos, selfPos)
    pos.y = 0
    local delta = pos - selfPos
    delta.Normalize()

    return Vector2(delta.x, delta.z) / self.range * Vector3.Distance(pos, selfPos)
end

function SAMRadar:IsInArea(grad1, grad2, x, y)
    return (y/x > grad1 and y/x < grad2) or (y/x < grad1 and y/x > grad2)
end

function SAMRadar:LoadKeybind()
    local script = GameObject.Find("SAM Config(Clone)")

    if script then
        script = script.GetComponent(ScriptedBehaviour).self
       
        if script then
            self.lockKey = script.DebilSAMConfig_Lock
        end
    end
    if self.lockKey == nil then
        self.lockKey = KeyCode.Mouse2
    end
end
