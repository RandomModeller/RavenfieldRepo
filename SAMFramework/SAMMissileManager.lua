behaviour("SAMMissileManager") --v1.0.0

function SAMMissileManager:Awake()
    self.missiles = {}

    if self.targets.launcher ~= nil then
        self.launcher = self.targets.launcher.GetComponent(Weapon)
    else
        self.launcher = self.gameObject.GetComponent(DataContainer).GetGameObject("launcher").GetComponent(Weapon)
    end

    self.launcher.onSpawnProjectiles.AddListener(self, "TrackMissile")
end

function SAMMissileManager:TrackMissile(newMissile)
    self.missiles[#self.missiles + 1] = newMissile[1]
    self.lastDistanceTravelled[#self.missiles] = -1
end

function SAMMissileManager:LateUpdate()
    local newMissiles = {}
    local newLastDistanceTravelled = {}

    for i, missile in pairs(self.missiles) do
        if missile ~= nil and missile.distanceTravelled ~= self.lastDistanceTravelled[i] then
            newMissiles[#newMissiles + 1] = missile
            newLastDistanceTravelled[#newMissiles] = missile.distanceTravelled
        end
    end

    self.missiles = newMissiles
    self.lastDistanceTravelled = newLastDistanceTravelled
end