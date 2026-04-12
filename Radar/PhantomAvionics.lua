behaviour("PhantomAvionics") --v1.2.0

function PhantomAvionics:Start()
    self.rigidbody = self.targets.rigidbody.GetComponent(Rigidbody)
    self.vehicleTransform = self.rigidbody.gameObject.transform
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    if self.targets.wsInputReader then
        self.wsInputReader = self.targets.wsInputReader.transform
    end

    self.gForce = 1
    self.lastVel = self.rigidbody.velocity
    self.gForces = {}
    self.counter = 0
    self.gForceCount = 8
    self.maxGForce = 1
    self.wsInput = 0

    self.flipGForce = false
    if self.dataContainer.HasBool("flipGForce") then
        self.flipGForce = self.dataContainer.GetBool("flipGForce")
    end
    self.gForceMultiplier = 1
    if self.dataContainer.HasFloat("gForceMultiplier") then
        self.gForceMultiplier = self.dataContainer.GetFloat("gForceMultiplier")
    end

    self.speed = 0
    self.init = true
end

function PhantomAvionics:Update()
    if Time.deltaTime > 0 then
        if self.wsInputReader then
            self.wsInput = (self.wsInputReader.localEulerAngles.x + 540) % 360 - 180
        end
        
        self.speed = self.rigidbody.velocity.magnitude

        local localVelocity = self.vehicleTransform.InverseTransformDirection(self.rigidbody.velocity)
        self.angleOfAttack = Mathf.Atan2(-localVelocity.y, localVelocity.z) * Mathf.Rad2Deg
    end
end

function PhantomAvionics:FixedUpdate()
    if Time.deltaTime > 0 then
        local a = self.rigidbody.velocity

        local acc = self.vehicleTransform.worldToLocalMatrix.MultiplyPoint3x4((a - self.lastVel) + self.rigidbody.position).y / Time.fixedDeltaTime * self.gForceMultiplier

        if self.flipGForce then
            acc = acc - Physics.gravity.y
        else
            acc = acc + Physics.gravity.y
        end

        self:AppendGForce(acc / -Physics.gravity.y)
        self.gForce = Mathf.Round(self:CalculateGForce() * 10) / 10
        
        if self.gForce > self.maxGForce then
            self.maxGForce = self.gForce
        end

        self.lastVel = a
    end
end

function PhantomAvionics:AppendGForce(val)
    self.counter = self.counter + 1

    self.gForces[self.counter] = val
    
    self.counter = self.counter % self.gForceCount
end

function PhantomAvionics:CalculateGForce()
    local sum = 0

    for i, num in pairs(self.gForces) do
        sum = sum + num
    end

    return sum / self.gForceCount
end
