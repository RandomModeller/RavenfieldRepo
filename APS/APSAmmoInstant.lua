behaviour("APSAmmoInstant") --v1.4.3

function APSAmmoInstant:Start()
    self.vehicle = self.targets.vehicleObject.GetComponent(Vehicle)
    self.accelComponent = self.vehicle.gameObject.GetComponent(Car)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    -- self.blocked = {"autorepairvehicleweapon", "apfsds", "apcbc", "apcr", "apds", "carhorn"}
    self.blocked = {"apfsds", "apcbc", "apcr", "apds"}
    self.teams = {}
    self.teams[-1] = Team.Neutral
    self.teams[0] = Team.Blue
    self.teams[1] = Team.Red

    GameEvents.onProjectileSpawned.AddListener(self, "onProjectileSpawned")

    self.projectilesWatched = {}

    -- self.ammoDisplayText = self.targets.ammoDisplay.GetComponent(Text)

    self.isLoading = false
    self.activateWhenLoading = self.targets.activateWhenLoading
    self.deactivateWhenLoading = self.targets.deactivateWhenLoading

    -- values
    -- load duration per ammo
    self.loadDuration = self.dataContainer.GetFloat("loadDuration")
    -- load keybind
    self.loadKeybind = self.dataContainer.GetString("loadKeybind")
    -- APS range
    self.range = self.dataContainer.GetFloat("apsRange") ^ 2
    self.blastRadius = self.dataContainer.GetFloat("blastRadius") ^ 2
    -- APS ammo
    self.allAps = {}
    self.apsParticle = {}
    self.apsTransform = {}
    self.turretTransform = {}
    self.apsAmmo = {}
    self.maxAmmo = {}
    self.colorGradient = {}
    self.currentIndex = 1

    for i, aps in pairs(self.dataContainer.GetGameObjectArray("aps")) do
        self.allAps[i] = aps
        self.apsParticle[i] = aps.GetComponentInChildren(ParticleSystem)
        self.apsTransform[i] = aps.transform
        self.turretTransform[i] = self.dataContainer.GetGameObject("turret" .. tostring(i)).transform

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

    -- self.full = Color(0, 255, 0)
    -- self.empty = Color(255, 0, 0)

    self.imageIndicators = {}
    
    for i, indicator in pairs(self.dataContainer.GetGameObjectArray("indicator")) do
        self.imageIndicators[i] = indicator.GetComponent(Image)

        if self.imageIndicators[i] == nil then
            self.imageIndicators[i] = indicator.GetComponent(Text)
        end
    end

    self.textIndicators = {}
    
    for i, text in pairs(self.dataContainer.GetGameObjectArray("text")) do
        self.textIndicators[i] = text.GetComponent(Text)
    end

    self.accel = self.accelComponent.acceleration
    self.turnTorque = self.accelComponent.baseTurnTorque

    -- self.angleCos20 = Mathf.Cos(20 * Mathf.Deg2Rad) ^ 2

    self.delay = self.dataContainer.GetFloat("delay")
    self.elapsedTime = 0
end

function APSAmmoInstant:onStartLoad()
    if self.isLoading then
        return
    end

    self.script.StartCoroutine("LoadAPS")
end

function APSAmmoInstant:LoadAPS()
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

    self.currentIndex = 1

    self.accelComponent.acceleration = self.accel
    self.accelComponent.baseTurnTorque = self.turnTorque
    self.isLoading = false
end

function APSAmmoInstant:onProjectileSpawned(projectile)
    if projectile == nil then
        return
    end
    if projectile.source == nil then
        return
    end
    -- if projectile.sourceWeapon == nil then
    --     return
    -- end
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

    -- table.insert(self.projectilesWatched, projectile)
end

function APSAmmoInstant:Update()
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

            local projWatchLoopCount = 0
            local projDestroyedLoopCount = 0

            for i, proj in pairs(self.projectilesWatched) do -- get all projectile in range
                if proj ~= nil then
                    local projectileDistance = (self.vehicle.transform.position - proj.transform.position).sqrMagnitude

                    if projectileDistance <= self.range then
                        local projPosition = proj.transform.position
                        local projDestroyed = false

                        for j, posit in pairs(destroyedProjPositions) do
                            if not projDestroyed then
                                if (projPosition - posit).sqrMagnitude <= self.blastRadius then
                                    self:Intercept(proj, i)
                                    destroyedProjPositions[#destroyedProjPositions + 1] = projPosition
                                    break
                                end
                            end

                            projDestroyedLoopCount = projDestroyedLoopCount + 1
                        end

                        if not projDestroyed then
                            local delta = self.vehicle.transform.position - projPosition
                            -- if proj.velocity.sqrMagnitude > 0.01f then
                            -- if (Vector3.Dot(delta, proj.transform.forward) ^ 2) / delta.sqrMagnitude >= self.angleCos20 then

                            self:Intercept(proj, i)
                            self:PlayEffect(self.currentIndex, projPosition)
                            self.apsAmmo[self.currentIndex] = self.apsAmmo[self.currentIndex] - 1
                            destroyedProjPositions[#destroyedProjPositions + 1] = projPosition

                            if self.imageIndicators[self.currentIndex] ~= nil then
                                self.imageIndicators[self.currentIndex].color = self.colorGradient[self.currentIndex].Evaluate(self.apsAmmo[self.currentIndex] / self.maxAmmo[self.currentIndex])
                            end

                            if self.textIndicators[self.currentIndex] ~= nil then
                                self.textIndicators[self.currentIndex].text = tostring(self.apsAmmo[self.currentIndex])
                            end

                            if self.apsAmmo[self.currentIndex] == 0 then
                                self.currentIndex = self.currentIndex + 1
                            end

                            break
                        end
                    end
                end
                projWatchLoopCount = projWatchLoopCount + 1
            end

            -- if self.vehicle.playerIsInside then
                -- print("ProjWatchLoopCount: " .. tostring(projWatchLoopCount) .. ", ProjDestroyedLoopCount: " .. tostring(projDestroyedLoopCount) .. ", WatchedProjCount: " .. tostring(#self.projectilesWatched))
            -- end
        else
            self:onStartLoad()
        end
    end
end

function APSAmmoInstant:Intercept(proj, i)
    proj.Stop(false)
    self.projectilesWatched[i] = nil
end

function APSAmmoInstant:PlayEffect(index, projPosition)
    local bearing = self.apsTransform[index]
    local pitch = self.turretTransform[index]

    local bearingVector = bearing.InverseTransformPoint(projPosition)
    bearingVector.y = 0

    if bearingVector.sqrMagnitude < 0.0004 then
        bearingVector = -Vector3.forward
    end

    bearing.LookAt(bearing.TransformPoint(bearingVector), bearing.up)
    pitch.LookAt(projPosition, -bearing.forward)

    self.apsParticle[index].Play(true)
end


