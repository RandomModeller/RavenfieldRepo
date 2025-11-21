behaviour("RadarEmitter") --v1.0.0

function RadarEmitter:Start()
    self.vehicleObject = self.targets.vehicleObject.GetComponent(Vehicle)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.transform = self.gameObject.transform

    self.isLocking = false
    self.isOn = true
    self.alive = not self.vehicleObject.isDead

    self.rangeClose = self.dataContainer.GetFloat("rangeClose") ^ 2
    self.rangeFar = self.dataContainer.GetFloat("rangeFar") ^ 2

    self.name = self.dataContainer.GetString("name")
    self.displayName = self.dataContainer.GetString("displayName")
    self.secondaryDisplayName = self.dataContainer.GetString("secondaryDisplayName")

    self.isAirborne = self.dataContainer.GetBool("isAirborne")
    self.isShip = self.dataContainer.GetBool("isShip")

    if self.dataContainer.HasFloat("azimuth") then
        self.azimuth = self.dataContainer.GetFloat("azimuth")
    elseif self.isAirborne then
        self.azimuth = 60
    else
        self.azimuth = 90
    end
    self.cosAzimuth = Mathf.Cos(self.azimuth * Mathf.Deg2Rad) ^ 2

    self.position = self.transform.position

    self:Register()
end

function RadarEmitter:Register()
    local scriptObject = GameObject.Find("RadarEmitterManager(Clone)")

    if scriptObject == nil then
        scriptObject = GameObject.Instantiate(self.targets.radarManagerPrefab)
    end
    scriptObject = scriptObject.GetComponent(ScriptedBehaviour).self

    scriptObject:Add(self)
end

function RadarEmitter:Update()
    self.alive = not self.vehicleObject.isDead
    self.position = self.transform.position
end