behaviour("DynamicObjectTimeOfDay") --v1.0.0

function DynamicObjectTimeOfDay:Start()
    self.vehicleObject = self.targets.vehicleObject.GetComponent(Vehicle)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    
    self.activateOnNight = self.dataContainer.GetGameObjectArray("activateOnNight")
    self.deactivateOnNight = self.dataContainer.GetGameObjectArray("deactivateOnNight")
    
    self.forceOffWhenEmpty = self.dataContainer.GetBool("forceOffWhenEmpty")
    self.nightTime = self.dataContainer.GetInt("nightTime")
    self.dayTime = self.dataContainer.GetInt("dayTime")
    self.keybind = self.dataContainer.GetString("keybind")
    
    local dayNightMutator = GameObject.Find("DayAndNightCycleSystem(Clone)")
	if dayNightMutator ~= nil then
		self.timeText = cycle.transform.GetChild(0).transform.GetChild(0).transform.GetChild(0).gameObject.GetComponent(Text)
    end
    
    self:Toggle(GameManager.isNightMode)
    
    self.lastHour = tonumber(string.sub(self.cycletime.text, 1, 2))
end

function DynamicObjectTimeOfDay:Update()
    local currentHour = tonumber(string.sub(self.cycletime.text, 1, 2)) 
    if currentHour ~= self.lastHour then
        if currentHour == self.nightTime then
            self:Toggle(true)
        elseif currentHour == self.dayTime then
            self:Toggle(false)
        end
    
        self.lastHour = currentHour
    end
    
    if Input.GetKeyDown(self.keybind) then
        self:Toggle(not self.isTurnedOn)
    end
end

function DynamicObjectTimeOfDay:Toggle(isOn)
    if self.forceOffWhenEmpty and not self.vehicleObject.hasDriver then
        isOn = false
    end
    
    self.isTurnedOn = isOn

    for i, obj in pairs(self.activateOnNight) do
        obj.SetActive(self.isTurnedOn)
    end
    
     for i, obj in pairs(self.deactivateOnNight) do
        obj.SetActive(not self.isTurnedOn)
    end
end