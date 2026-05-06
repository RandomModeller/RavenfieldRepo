behaviour("AnimatedPassengerDoor") --v1.0.1

function AnimatedPassengerDoor:Start()
    self.animator = self.targets.animator.GetComponent(Animator)
    self.heightChecker = self.targets.heightChecker.GetComponent(ScriptedBehaviour).self
    self.vehicle = self.targets.vehicle.GetComponent(Vehicle)

    self.name = self.animator.StringToHash(self.gameObject.GetComponent(DataContainer).GetString("name"))
end

function AnimatedPassengerDoor:Update()
    local isFull = self.vehicle.GetEmptySeat() == nil
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

    self.animator.SetBool(self.name, doorOpen)
end
