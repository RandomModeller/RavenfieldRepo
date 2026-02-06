behaviour("DynamicObjectTimeOfDay") --v1.0.2

function DynamicObjectTimeOfDay:Start()
    self.vehicleObject = self.targets.vehicleObject.GetComponent(Vehicle)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    
    self.activateOnNight = self.dataContainer.GetGameObjectArray("activateOnNight")
    self.deactivateOnNight = self.dataContainer.GetGameObjectArray("deactivateOnNight")
    
    self.forceOffWhenEmpty = true
    if self.dataContainer.HasBool("forceOffWhenEmpty") then
        self.forceOffWhenEmpty = self.dataContainer.GetBool("forceOffWhenEmpty")
    end

    self.nightTime = 18
    if self.dataContainer.HasInt("nightTime") then
        self.nightTime = self.dataContainer.GetInt("nightTime")
    end
    self.dayTime = 6
    if self.dataContainer.HasInt("dayTime") then
        self.dayTime = self.dataContainer.GetInt("dayTime")
    end

    self.keybind = nil
    if self.dataContainer.HasString("keybind") then
        self.keybind = self.dataContainer.GetString("keybind")
    end
    
    local dayNightMutator = GameObject.Find("DayAndNightCycleSystem(Clone)")
	if dayNightMutator ~= nil then
		self.timeText = cycle.transform.GetChild(0).transform.GetChild(0).transform.GetChild(0).gameObject.GetComponent(Text)
        self.lastHour = tonumber(string.sub(self.cycletime.text, 1, 2))
    end
    
    self:Toggle(GameManager.isNightMode)

    self.lastHasDriver = self.vehicleObject.hasDriver
end

function DynamicObjectTimeOfDay:Update()
    local currentHour = nil

	if dayNightMutator ~= nil then
        currentHour = tonumber(string.sub(self.cycletime.text, 1, 2)) 
        if currentHour ~= self.lastHour then
            if currentHour == self.nightTime then
                self:Toggle(true)
            elseif currentHour == self.dayTime then
                self:Toggle(false)
            end
        
            self.lastHour = currentHour
        end
    end
    
    if self.keybind ~= nil then
        if Input.GetKeyDown(self.keybind) and self.vehicleObject.playerIsInside then
            self:Toggle(not self.isTurnedOn)
        end
    end


    if self.vehicleObject.hasDriver ~= self.lastHasDriver then
        if self.vehicleObject.hasDriver then
            if currentHour == nil then
                self:Toggle(GameManager.isNightMode)
            else
                self:Toggle(currentHour >= self.nightTime or currentHour < self.dayTime)
            end
        else
            self:Toggle(false)
        end

        self.lastHasDriver = self.vehicleObject.hasDriver
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
