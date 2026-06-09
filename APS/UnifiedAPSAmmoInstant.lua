behaviour("UnifiedAPSAmmoInstant") --v1.2.2

function UnifiedAPSAmmoInstant:Start()
    self.vehicle = self.targets.vehicleObject.GetComponent(Vehicle)
    self.accelComponent = self.vehicle.gameObject.GetComponent(Car)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.blocked = {"apfsds", "apcbc", "apcr", "apds"}
    self.teams = {}
    self.teams[-1] = Team.Neutral
    self.teams[0] = Team.Blue
    self.teams[1] = Team.Red

    GameEvents.onProjectileSpawned.AddListener(self, "onProjectileSpawned")

    self.projectilesWatched = {}

    self.isLoading = false
    self.activateWhenLoading = self.targets.activateWhenLoading
    self.deactivateWhenLoading = self.targets.deactivateWhenLoading

    -- values
    -- load duration per ammo
    self.loadDuration = self.dataContainer.GetFloat("loadDuration")
    -- load keybind
    self.loadKeybind = self.dataContainer.GetString("loadKeybind")
    self.maximumReloadTimes = 99999
    if self.dataContainer.HasInt("maximumReloadTimes") then
        self.maximumReloadTimes = self.dataContainer.GetInt("maximumReloadTimes")
    end
    -- APS cone radius
    self.arcRadius = self.dataContainer.GetFloat("apsGimbal")
    self.arcRadiusCosSqr = Mathf.Cos(self.arcRadius * Mathf.Deg2Rad)
    self.arcRadiusCosSqr = self.arcRadiusCosSqr * self.arcRadiusCosSqr

    if not (self.arcRadius == 180 or self.arcRadius <= 90) then
        print("<color=red>ValueError:</color> <color=white>" .. self.gameObject.name .. ", UnifiedAPSAmmoInstant.lua, DataContainer</color> <color=cyan>float</color> <color=white>apsGimbal</color> <color=red>value ERROR. The script can only take values under or equal to 90 degrees or exactly 180 degrees. The script will break</color>") 
    end

    if self.arcRadius == 180 then
        self.arcRadiusCosSqr = -1
    end
    -- APS range
    self.range = self.dataContainer.GetFloat("apsRange") ^ 2
    self.minRange = 0
    if self.dataContainer.HasFloat("minRange") then
        self.minRange = self.dataContainer.GetFloat("minApsRange") ^ 2
    end
    self.blastRadius = self.dataContainer.GetFloat("blastRadius") ^ 2
    -- APS ammo
    self.allAps = {}
    self.apsParticle = {}
    self.apsTransform = {}
    self.bearingTransform = {}
    self.turretTransform = {}
    self.apsAmmo = {}
    self.maxAmmo = {}
    self.colorGradient = {}
    -- Rotate model
    self.rotateModel = false
    if self.dataContainer.HasBool("rotateModel") then
        self.rotateModel = self.dataContainer.GetBool("rotateModel")
    end

    for i, aps in pairs(self.dataContainer.GetGameObjectArray("aps")) do
        self.allAps[i] = aps
        self.apsParticle[i] = aps.GetComponentInChildren(ParticleSystem)
        self.apsTransform[i] = aps.transform

        if self.rotateModel then
            self.bearingTransform[i] = self.dataContainer.GetGameObject("bearing" .. tostring(i)).transform
            self.turretTransform[i] = self.dataContainer.GetGameObject("turret" .. tostring(i)).transform
        end

        if self.dataContainer.HasFloat("apsAmmo") then
            self.maxAmmo[i] = self.dataContainer.GetFloat("apsAmmo")
        else
            self.maxAmmo[i] = self.dataContainer.GetFloat("apsAmmo" .. i)
        end

        if self.dataContainer.HasGradient("colorGradient") then
            self.colorGradient[i] = self.dataContainer.GetGradient("colorGradient")
        else
            self.colorGradient[i] = self.dataContainer.GetGradient("colorGradient" .. i)
        end

        self.apsAmmo[i] = self.maxAmmo[i]
    end

    self.apsReloadImmobilize = false
    if self.dataContainer.HasBool("reloadImmobilize") then
        self.apsReloadImmobilize = self.dataContainer.GetBool("reloadImmobilize")
    end

    self.interceptFriendly = false
    if self.dataContainer.HasBool("interceptFriendly") then
        self.interceptFriendly = self.dataContainer.GetBool("interceptFriendly")
    end
    self.interceptFriendly = self.interceptFriendly or GameManager.isTestingContentMod

    self.imageIndicators = {}
    
    for i, indicator in pairs(self.dataContainer.GetGameObjectArray("indicator")) do
        self.imageIndicators[i] = indicator.GetComponent(Image)

        if self.imageIndicators[i] == nil then
            self.imageIndicators[i] = indicator.GetComponent(Text)
        end

        self.imageIndicators[i].color = self.colorGradient[i].Evaluate(1)
    end

    self.textIndicators = {}
    
    for i, text in pairs(self.dataContainer.GetGameObjectArray("text")) do
        self.textIndicators[i] = text.GetComponent(Text)
    end

    self.accel = self.accelComponent.acceleration
    self.turnTorque = self.accelComponent.baseTurnTorque

    self.delay = self.dataContainer.GetFloat("delay")
    self.elapsedTime = 0
end

function UnifiedAPSAmmoInstant:onStartLoad()
    if self.isLoading then
        return
    end

    if self.maximumReloadTimes <= 0 then
        return
    end

    self.script.StartCoroutine("LoadAPS")
end

function UnifiedAPSAmmoInstant:LoadAPS()
    self.isLoading = true

    local ammoDelta = 0

    for i, aps in pairs(self.apsAmmo) do
        ammoDelta = ammoDelta + (self.maxAmmo[i] - aps)
    end

    if ammoDelta == 0 then
        return
    end

    local loadDuration = self.loadDuration * ammoDelta

    local timePassed = 0

    if self.apsReloadImmobilize then
        self.accelComponent.acceleration = 0
        self.accelComponent.baseTurnTorque = 0
    end

    if self.activateWhenLoading ~= nil then
        self.activateWhenLoading.SetActive(true)
    end
    if self.deactivateWhenLoading ~= nil then
        self.deactivateWhenLoading.SetActive(false)
    end

    coroutine.yield(WaitForSeconds(loadDuration))

    if self.activateWhenLoading ~= nil then
        self.activateWhenLoading.SetActive(false)
    end
    if self.deactivateWhenLoading ~= nil then
        self.deactivateWhenLoading.SetActive(true)
    end

    for i, indicator in pairs(self.imageIndicators) do
        indicator.color = self.colorGradient[i].Evaluate(1)
    end

    for i, text in pairs(self.textIndicators) do
        text.text = tostring(self.apsAmmo[i])
    end
        
    for i, aps in pairs(self.apsAmmo) do
        self.apsAmmo[i] = self.maxAmmo[i]
    end

    self.accelComponent.acceleration = self.accel
    self.accelComponent.baseTurnTorque = self.turnTorque
    self.isLoading = false

    self.maximumReloadTimes = self.maximumReloadTimes - 1
end

function UnifiedAPSAmmoInstant:onProjectileSpawned(projectile)
    if projectile == nil then
        return
    end
    if projectile.source == nil then
        return
    end
    if self.vehicle == nil then
        return
    end
    if self.vehicle.driver == nil then
        return
    end
    if (not self.interceptFriendly) and projectile.source.team == self.vehicle.driver.team then
        return
    end
    if not (projectile.isTargetSeekingMissileProjectile) and not (projectile.isExplodingProjectile and not projectile.sourceWeapon.isAuto) then
        return
    end

    local weaponName = tostring(projectile.sourceWeapon):lower()

    for k, blockedName in pairs(self.blocked) do
        if weaponName:find(blockedName) then
            return
        end
    end

    for i, proj in pairs(self.projectilesWatched) do
        if proj == nil then
            proj = projectile
            return
        end
    end

    self.projectilesWatched[#self.projectilesWatched + 1] = projectile
end

function UnifiedAPSAmmoInstant:Update()
    self.elapsedTime = self.elapsedTime + Time.deltaTime

    if self.elapsedTime < self.delay then
        return
    end

    self.elapsedTime = 0

    if self.vehicle.playerIsInside or self.vehicle.hasDriver then
        local check = false

        for i, aps in pairs(self.apsAmmo) do
            if aps > 0 then
                check = true
                break
            end
        end
        
        if check then
            local destroyedProjPositions = {}

            for i, proj in pairs(self.projectilesWatched) do -- get all projectile in range
                if proj ~= nil then
                    local projectileDistance = (self.vehicle.transform.position - proj.transform.position).sqrMagnitude

                    if projectileDistance <= self.range and projectileDistance >= self.minRange then
                        local projPosition = proj.transform.position
                        local projDestroyed = false

                        for j, posit in pairs(destroyedProjPositions) do -- chain reaction
                            if not projDestroyed then
                                if (projPosition - posit).sqrMagnitude <= self.blastRadius then
                                    self:Intercept(proj, i)
                                    destroyedProjPositions[#destroyedProjPositions + 1] = projPosition
                                    break
                                end
                            end
                        end

                        if not projDestroyed then -- hard kil interception
                            for j, apsTransform in pairs(self.apsTransform) do
                                if self.apsAmmo[j] ~= 0 and apsTransform.gameObject.activeInHierarchy then
                                    local positionDelta = projPosition - apsTransform.position
                                    local dot = Vector3.Dot(apsTransform.forward, positionDelta)

                                    if (dot ^ 2) / positionDelta.sqrMagnitude >= self.arcRadiusCosSqr and dot >= 0 then
                                        self:Intercept(proj, i)
                                        self:PlayEffect(j, projPosition)
                                        self.apsAmmo[j] = self.apsAmmo[j] - 1
                                        destroyedProjPositions[#destroyedProjPositions + 1] = projPosition

                                        if self.imageIndicators[j] ~= nil then
                                            self.imageIndicators[j].color = self.colorGradient[j].Evaluate(self.apsAmmo[j] / self.maxAmmo[j])
                                        end

                                        if self.textIndicators[j] ~= nil then
                                            self.textIndicators[j].text = tostring(self.apsAmmo[j])
                                        end

                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            self:onStartLoad()
        end
    end
end

function UnifiedAPSAmmoInstant:Intercept(proj, i)
    proj.Stop(false)
    self.projectilesWatched[i] = nil
end

function UnifiedAPSAmmoInstant:PlayEffect(index, projPosition)
    if self.rotateModel then
        local bearing = self.bearingTransform[index]
        local pitch = self.turretTransform[index]

        local bearingVector = bearing.InverseTransformPoint(projPosition)
        bearingVector.y = 0

        if bearingVector.sqrMagnitude < 0.0004 then
            bearingVector = -Vector3.forward
        end

        bearing.LookAt(bearing.TransformPoint(bearingVector), bearing.up)
        pitch.LookAt(projPosition, -bearing.forward)
    end

    self.apsParticle[index].Play(true)
end
