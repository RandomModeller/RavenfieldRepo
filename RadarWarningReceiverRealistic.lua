behaviour("RadarWarningReceiverRealistic")

function RadarWarningReceiverRealistic:Start()
    self.vehicleObject = self.targets.vehicleObject.GetComponent(Vehicle)
    self.vehicleTransform = self.targets.vehicleObject.transform
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.iconParent = self.targets.iconParent.transform
    self.icon = self.targets.icon
    self.blips = {}

    self.elapsed = 0
    self.delay = self.dataContainer.GetFloat("delay")
    self.lastIter = 0
    
    self.missileCloseDistance = self.dataContainer.GetFloat("missileCloseDistance") ^ 2
    self.veryCloseMultiplier = self.dataContainer.GetFloat("veryCloseMultiplier")
    self.closeMultiplier = self.dataContainer.GetFloat("closeMultiplier")
    self.farMultiplier = self.dataContainer.GetFloat("farMultiplier")
    self.missileText = self.dataContainer.GetString("missileText")

    self.newEmitterAudioSource = self.targets.newEmitterAudioSource.GetComponent(AudioSource)
    self.newEmitterAir = self.dataContainer.GetAudioClip("newEmitterAir")
    self.newEmitterGround = self.dataContainer.GetAudioClip("newEmitterGround")

    self.hybridMode = false
    if self.dataContainer.HasBool("hybridMode") then
        self.hybridMode = self.dataContainer.GetBool("hybridMode")
        self.genericCloseDistance = self.dataContainer.GetFloat("genericCloseDistance") ^ 2
        self.genericFarDistance = self.dataContainer.GetFloat("genericFarDistance") ^ 2
        self.genericAirborneText = self.dataContainer.GetString("genericAirborneText")
        self.genericGroundText = self.dataContainer.GetString("genericGroundText")
        self.cos60 = Mathf.Cos(60 * Mathf.Deg2Rad) ^ 2
    end

    self.showIfLooking = false
    if self.dataContainer.HasBool("showIfLooking") then
        self.showIfLooking = self.dataContainer.GetBool("showIfLooking")
    end

    self.blinkOnLaunchingVehicle = false
    if self.dataContainer.HasBool("blinkOnLaunchingVehicle") then
        self.blinkOnLaunchingVehicle = self.dataContainer.GetBool("blinkOnLaunchingVehicle")
    end

    --constants
    self.iconScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform
    self.radarEmitterManager = GameObject.Find("RadarEmitterManager(Clone)").GetComponent(ScriptedBehaviour).self
end

function RadarWarningReceiverRealistic:CreateDot()
    local newIcon = self.gameObject.Instantiate(self.icon, self.iconParent)
    local iconScript = newIcon.GetComponent(ScriptedBehaviour).self
    local iconTrans = newIcon.transform

    iconScript:Init()

    iconTrans.localScale = self.iconScale
    iconTrans.localRotation = Quaternion.identity
    self.blips[#self.blips + 1] = iconScript
end

function RadarWarningReceiverRealistic:EnableDot(index)
    if self.blips[index].gameObject.activeSelf then
        return
    end

    self.blips[index].gameObject.SetActive(true)
end

function RadarWarningReceiverRealistic:DisableDot(index)
    if not self.blips[index].gameObject.activeSelf then
        return
    end

    self.blips[index].gameObject.SetActive(false)
end

function RadarWarningReceiverRealistic:Update()
    self.elapsed = self.elapsed + Time.deltaTime

    if self.elapsed >= self.delay then
        self.iconParent.localEulerAngles = Vector3(0, 0, self.vehicleTransform.localEulerAngles.y)

        local missiles = self.vehicleObject.GetTrackingMissiles()

        local missileCount = #missiles

        if missileCount > #self.blips then
            for i = 1, missileCount - #self.blips do
                self:CreateDot()
            end
        end

        local vehiclePos = self.vehicleTransform.position
        local normalVehiclePos = vehiclePos
        vehiclePos.y = 0

        local launchingVehicles = {}

        for i, blip in pairs(self.blips) do
            local missile = missiles[i]

            if missile ~= nil then
                local flag1 = i > missileCount

                if flag1 then
                    blip:Hide()
                else
                    --local trans = missile.transform
                    local missilePos = missile.transform.position

                    local distance = (missilePos - normalVehiclePos).sqrMagnitude

                    if distance <= self.missileCloseDistance then
                        blip:SetPosition(self:GetBlipPosition(missilePos, vehiclePos) * self.veryCloseMultiplier, self.transform.rotation)
                    else
                        blip:SetPosition(self:GetBlipPosition(missilePos, vehiclePos) * self.closeMultiplier, self.transform.rotation)
                    end

                    blip.emitter = -1
                    blip:SetName(self.missileText)

                    if self.blinkOnLaunchingVehicle and missile.killCredit.activeVehicle ~= nil then
                        launchingVehicles[#launchingVehicles + 1] = missile.killCredit.activeVehicle
                    end
                    --blip.rotation = self.transform.rotation
                end
            else
                blip:Hide()
            end
            blip.blink = false
        end

        local counter = #missiles + 1
        local iterCounter = 0
        local lastEmitterIsAirborne = false

        local registered = {}

        if self.radarEmitterManager ~= nil then
            for i, emitter in pairs(self.radarEmitterManager.DebilRadarEmitters) do
                if emitter.alive and emitter.isOn and emitter.vehicleObject ~= self.vehicleObject and emitter.transform ~= nil and emitter.vehicleObject.driver ~= nil then
                    local delta = (emitter.position - normalVehiclePos)
                    local distance = delta.sqrMagnitude


                    local flag = distance <= emitter.rangeFar

                    if self.showIfLooking then
                        local b = -delta
                        local dot = Vector3.Dot(emitter.transform.forward, b)


                        local cosToUse = -1

                        if emitter.cosAzimuth then
                            cosToUse = emitter.cosAzimuth
                        else
                            if emitter.isAirborne then
                                cosToUse = self.cos60
                            end
                        end

                        flag = flag and ((cosToUse < (dot ^ 2) / b.sqrMagnitude) and (dot > 0))
                    end

                    if flag then
                        if counter > #self.blips then
                            self:CreateDot()
                        end
                        
                        local blip = self.blips[counter]

                        blip.emitter = emitter
                        if distance <= emitter.rangeClose then
                            blip:SetPosition(self:GetBlipPosition(emitter.position, vehiclePos) * self.closeMultiplier, self.transform.rotation)
                        else
                            blip:SetPosition(self:GetBlipPosition(emitter.position, vehiclePos) * self.farMultiplier, self.transform.rotation)
                        end

                        if self.blinkOnLaunchingVehicle then
                            for j, launchVehicle in pairs(launchingVehicles) do
                                if blip.emitter.vehicleObject.gameObject == launchVehicle.gameObject then
                                    blip.blink = true
                                    break
                                end
                            end
                        end

                        counter = counter + 1
                        iterCounter = iterCounter + 1
                        lastEmitterIsAirborne = emitter.isAirborne

                        if self.hybridMode then
                            registered[#registered + 1] = emitter.vehicleObject
                        end
                    end
                end
            end
        end

        if self.hybridMode then
            for i, vehicle in pairs(ActorManager.vehicles) do
                if not vehicle.isDead and vehicle ~= self.vehicleObject and vehicle.driver ~= nil then
                    local skip = false                    

                    for j, vehicle2 in pairs(registered) do
                        if vehicle == vehicle2 then
                            skip = true
                        end
                    end

                    local isAirborne = vehicle.isAirplane or vehicle.isHelicopter

                    if not skip and not isAirborne then
                        for i, weapon in pairs (vehicle.seats[1].weapons) do
                            if weapon.effectivenessAir == Effectiveness.Yes or weapon.effectivenessAir == Effectiveness.Preferred or weapon.effectivenessAirFastMover == Effectiveness.Yes or weapon.effectivenessAirFastMover == Effectiveness.Preferred then
                                skip = true
                                break
                            end
                        end

                        if not skip and #vehicle.seats > 1 then
                            for i, weapon in pairs (vehicle.seats[2].weapons) do
                                if weapon.effectivenessAir == Effectiveness.Yes or weapon.effectivenessAir == Effectiveness.Preferred or weapon.effectivenessAirFastMover == Effectiveness.Yes or weapon.effectivenessAirFastMover == Effectiveness.Preferred then
                                    skip = true
                                    break
                                end
                            end
                        end
                    end

                    if not skip then
                        local vehicle2Pos = vehicle.transform.position

                        local delta = (vehicle2Pos - normalVehiclePos)
                        local distance = delta.sqrMagnitude

                        local flag = distance <= self.genericFarDistance

                        if self.showIfLooking then
                            local b = -delta
                            local dot = Vector3.Dot(vehicle.transform.forward, b)

                            flag = flag and ((self.cos60 < (dot ^ 2) / b.sqrMagnitude) and (dot > 0))
                        end

                        if flag then
                            if counter > #self.blips then
                                self:CreateDot()
                            end
                            
                            local blip = self.blips[counter]

                            if isAirborne then
                                blip:SetName(self.genericAirborneText)
                                blip:Airborne(true)
                                blip:Circle(false)
                            else
                                blip:SetName(self.genericGroundText)
                                blip:Airborne(false)
                                blip:Circle(false)
                            end

                            if distance <= self.genericCloseDistance then
                                blip:SetPosition(self:GetBlipPosition(vehicle2Pos, vehiclePos) * self.closeMultiplier, self.transform.rotation)
                            else
                                blip:SetPosition(self:GetBlipPosition(vehicle2Pos, vehiclePos) * self.farMultiplier, self.transform.rotation)
                            end

                            if self.blinkOnLaunchingVehicle then
                                for j, launchVehicle in pairs(launchingVehicles) do
                                    if vehicle.gameObject == launchVehicle.gameObject then
                                        blip.blink = true
                                        break
                                    end
                                end
                            end

                            counter = counter + 1
                            iterCounter = iterCounter + 1
                            lastEmitterIsAirborne = isAirborne
                        end
                    end
                end
            end
        end

        if self.lastIter < iterCounter then
            if lastEmitterIsAirborne and self.newEmitterAir ~= nil then
                self.newEmitterAudioSource.PlayOneShot(self.newEmitterAir)
            elseif self.newEmitterGround ~= nil then
                self.newEmitterAudioSource.PlayOneShot(self.newEmitterGround)
            end
        end

        self.lastIter = iterCounter 
        self.elapsed = self.elapsed - self.delay
    end
end

function RadarWarningReceiverRealistic:GetBlipPosition(pos, selfPos)
    pos.y = 0
    local delta = pos - selfPos
    delta.Normalize()

    return Vector2(delta.x, delta.z)
end