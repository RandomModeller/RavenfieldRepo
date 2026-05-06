behaviour("AnimatedPassengerDoor") --v1.1.0

function AnimatedPassengerDoor:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.animator = self.targets.animator.GetComponent(Animator)
    self.heightChecker = self.targets.heightChecker.GetComponent(ScriptedBehaviour).self
    self.vehicle = self.targets.vehicle.GetComponent(Vehicle)

    self.name = self.animator.StringToHash(self.dataContainer.GetString("name"))
    self.keybind = ""
    if self.dataContainer.HasString("keybind") then
        self.keybind = self.dataContainer.GetString("keybind")
    end

    self.lastAutoValue = 2
end

function AnimatedPassengerDoor:Update()
    local isFull = self.vehicle.GetEmptySeat(false) == nil
    local isLow = self.heightChecker <= 8
    local isSlow = self.vehicle.rigidbody.velocity.sqrMagnitude <= 200
    local isCloseToLZ = false
    local isPickingUp = false
    
    if self.vehicle.driver ~= nil then
        if self.vehicle.driver.squad ~= nil then
            if self.vehicle.driver.squad.claimedLandingZone ~= nil then
                isCloseToLZ = self.vehicle.driver.squad.claimedLandingZone.position - self.vehicle.transform.position
                isCloseToLZ.y = 0
                isCloseToLZ = isCloseToLZ.sqrMagnitude <= 15000
            end

            isPickingUp = self.vehicle.driver.squad.hasLanded or self.vehicle.driver.squad.isPerformingLanding
        end
    end
    
    local doorOpen = (isLow and not isFull and isSlow) or (isCloseToLZ) or (isPickingUp)
    local autoValue = doorOpen

    if self.keybind then
        if Input.GetKey(self.keybind) and self.vehicle.playerIsInside then
            doorOpen = not doorOpen
        end
    end

    if doorOpen ~= self.lastAutoValue then
        self.animator.SetBool(self.name, doorOpen)
        self.lastAutoValue = autoValue
    end
end
