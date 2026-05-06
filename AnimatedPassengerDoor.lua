behaviour("AnimatedPassengerDoor") --v1.1.4

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

    self.lowHeight = 8
    if self.dataContainer.HasFloat("lowHeight") then
        self.lowHeight = self.dataContainer.GetFloat("lowHeight")
    end
    self.midHeight = 18
    if self.dataContainer.HasFloat("midHeight") then
        self.midHeight = self.dataContainer.GetFloat("midHeight")
    end
    self.velocitySqr = 200
    if self.dataContainer.HasFloat("velocitySqr") then
        self.velocitySqr = self.dataContainer.GetFloat("velocitySqr")
    end
    self.horizontalRangeSqr = 25000
    if self.dataContainer.HasFloat("horizontalRangeSqr") then
        self.horizontalRangeSqr = self.dataContainer.GetFloat("horizontalRangeSqr")
    end

    self.lastAutoValue = 2
end

function AnimatedPassengerDoor:Update()
    local isFull = self.vehicle.GetEmptySeat(false) == nil
    local isLow = self.heightChecker.height <= self.lowHeight
    local isMedium = self.heightChecker.height <= self.midHeight
    local isSlow = self.vehicle.rigidbody.velocity.sqrMagnitude <= self.velocitySqr
    local isCloseToLZ = false
    local isCloseToCapturePoint = false
    local isPickingUp = false
    
    if self.vehicle.driver ~= nil then
        if self.vehicle.driver.squad ~= nil then
            if self.vehicle.driver.squad.claimedLandingZone ~= nil then
                isCloseToLZ = self.vehicle.driver.squad.claimedLandingZone.position - self.vehicle.transform.position
                isCloseToLZ.y = 0
                isCloseToLZ = isCloseToLZ.sqrMagnitude <= self.horizontalRangeSqr
            end

            if self.vehicle.driver.squad.order ~= nil then
                if self.vehicle.driver.squad.order.type == OrderType.Attack then
                    if self.vehicle.driver.squad.order.targetPoint ~= nil then
                        isCloseToCapturePoint = self.vehicle.driver.squad.order.targetPoint.transform.position - self.vehicle.transform.position
                        isCloseToCapturePoint.y = 0
                        isCloseToCapturePoint = isCloseToCapturePoint.sqrMagnitude <= self.horizontalRangeSqr
                    end
                end
            end


            isPickingUp = self.vehicle.driver.squad.hasLanded or self.vehicle.driver.squad.isPerformingLanding
        end
    end
    
    local doorOpen = (isLow and not isFull and isSlow) or (isCloseToLZ or isCloseToCapturePoint) or (isPickingUp and isMedium)

    if self.keybind then
        if Input.GetKeyDown(self.keybind) and self.vehicle.playerIsInside then
            self.animator.SetBool(self.name, not self.animator.GetBool(self.name))
        end
    end

    if doorOpen ~= self.lastAutoValue then
        self.animator.SetBool(self.name, doorOpen)
        self.lastAutoValue = doorOpen
    end
end
