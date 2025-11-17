behaviour("FixedAPSAmmo")

function FixedAPSAmmo:Start()
    self.vehicle = self.targets.vehicleObject.GetComponent(Vehicle)
    self.accelComponent = self.vehicle.gameObject.GetComponent(Car)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    --self.blocked = {"repair (autorepairvehicleweapon)", "apfsds (mountedstabilizedturret)", "apcbc (mountedstabilizedturret)", "apcr (mountedstabilizedturret)", "apds (mountedstabilizedturret)", "apfsds (mountedweapon)", "apcbc (mountedweapon)", "apcr (mountedweapon)", "apds (mountedweapon)"}
    self.blocked = {"autorepairvehicleweapon", "apfsds", "apcbc", "apcr", "apds", "carhorn"}
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
    -- APS cone radius
    self.arcRadius = self.dataContainer.GetFloat("apsCone")
    self.arcRadiusCosSqr = Mathf.Cos(self.arcRadius * Mathf.Deg2Rad)
    self.arcRadiusCosSqr = self.arcRadiusCosSqr * self.arcRadiusCosSqr
    -- APS range
    self.range = self.dataContainer.GetFloat("apsRange") ^ 2
    self.blastRadius = self.dataContainer.GetFloat("blastRadius") ^ 2
    -- APS ammo
    self.allAps = {}
    self.apsParticle = {}
    self.apsTransform = {}
    self.apsAmmo = {}
    self.maxAmmo = {}

    for i, aps in pairs(self.dataContainer.GetGameObjectArray("aps")) do
        self.allAps[i] = aps
        self.apsParticle[i] = aps.GetComponentInChildren(ParticleSystem)
        self.apsTransform[i] = aps.transform
        self.maxAmmo[i] = self.dataContainer.GetFloat("apsAmmo" .. i)
        self.apsAmmo[i] = self.maxAmmo[i]
    end

    self.apsReloadImmobilize = false
    if self.dataContainer.HasBool("reloadImmobilize") then
        self.apsReloadImmobilize = self.dataContainer.GetBool("reloadImmobilize")
    end

    self.full = Color(0, 255, 0)
    self.empty = Color(255, 0, 0)

    self.imageIndicators = {}
    
    for i, indicator in pairs(self.dataContainer.GetGameObjectArray("indicator")) do
        self.imageIndicators[i] = indicator.GetComponent(Image)
    end

    self.accel = self.accelComponent.acceleration
    self.turnTorque = self.accelComponent.baseTurnTorque

    self.delay = self.dataContainer.GetFloat("delay")
    self.elapsedTime = 0
end

function FixedAPSAmmo:onStartLoad()
    if self.isLoading then
        return
    end

    self.script.StartCoroutine("LoadAPS")
end

function FixedAPSAmmo:LoadAPS()
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

    self.activateWhenLoading.SetActive(true)
    self.deactivateWhenLoading.SetActive(false)

    coroutine.yield(WaitForSeconds(loadDuration))

    self.activateWhenLoading.SetActive(false)
    self.deactivateWhenLoading.SetActive(true)

    for i, indicator in pairs(self.imageIndicators) do
        indicator.color = self.full
    end
        
    for i, aps in pairs(self.apsAmmo) do
        self.apsAmmo[i] = self.maxAmmo[i]
    end

    self.accelComponent.acceleration = self.accel
    self.accelComponent.baseTurnTorque = self.turnTorque
    self.isLoading = false
end

function FixedAPSAmmo:onProjectileSpawned(projectile)
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
    if projectile.source.team == self.vehicle.driver.team then
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

function FixedAPSAmmo:Update()
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
                    if projectileDistance <= self.range then
                        local projPosition = proj.transform.position
                        local projDestroyed = false

                        for j, posit in pairs(destroyedProjPositions) do
                            if not projDestroyed then
                                if (projPosition - posit).sqrMagnitude <= self.blastRadius then
                                    self:Intercept(proj, i)
                                    projDestroyed = true
                                    destroyedProjPositions[#destroyedProjPositions + 1] = projPosition
                                    break
                                end
                            end
                        end

                        if not projDestroyed then
                            for j, apsTransform in pairs(self.apsTransform) do
                                if self.apsAmmo[j] ~= 0 and not projDestroyed then
                                    local positionDelta = projPosition - apsTransform.position

                                    if (Vector3.Dot(apsTransform.forward, positionDelta) ^ 2) / positionDelta.sqrMagnitude >= self.arcRadiusCosSqr then
                                        self:Intercept(proj, i)
                                        self:PlayEffect(j)
                                        self.apsAmmo[j] = self.apsAmmo[j] - 1
                                        destroyedProjPositions[#destroyedProjPositions + 1] = projPosition

                                        if self.apsAmmo[j] == 0 and self.imageIndicators[j] ~= nil then
                                            self.imageIndicators[j].color = self.empty
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

function FixedAPSAmmo:Intercept(proj, i)
    proj.Stop(false)
    self.projectilesWatched[i] = nil
end

function FixedAPSAmmo:PlayEffect(j)
        self.apsParticle[j].Play(true)
end