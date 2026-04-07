behaviour("RadarGuidedMissile") --v1.1.0

function RadarGuidedMissile:Init()
    self.projectile = self.gameObject.GetComponent(TargetSeekingMissileProjectile)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.transform = self.gameObject.transform

    self.leadTimePercentage = 0
    self.id = -1
    self.tti = 0
    self.status = 0
    -- 0 is launch
    -- 1 is mprf/pitbull
    -- 2 is snipped
    -- -1 is exploded/splash

    -- self.velocity = self.dataContainer.GetFloat("velocity")
    self.proximityRange = self.dataContainer.GetFloat("proximityRange")
    self.minDistancePredict = self.dataContainer.GetFloat("minDistancePredict")
    self.maxDistancePredict = self.dataContainer.GetFloat("maxDistancePredict")
    self.maxTimePrediction = self.dataContainer.GetFloat("maxTimePrediction")
    if self.dataContainer.HasFloat("turnRate") then
        self.turnRate = self.dataContainer.GetFloat("turnRate") * Mathf.Deg2Rad
    end
end

function RadarGuidedMissile:Update()
    if self.projectile == nil then
        self:Init()
    end
    
    if self.projectile.currentTarget == nil then
        return
    end

    local targetPosition = self.projectile.currentTarget.transform.position

    local range = (targetPosition - self.transform.position).magnitude

    if range <= self.proximityRange and self.status ~= -1 then
        self.projectile.Stop(false)
        self.status = -1
    end

    local velocity = self.projectile.velocity.magnitude

    self.tti = range / velocity

    self.moveTo = targetPosition
    
    self.leadTimePercentage = Mathf.InverseLerp(self.minDistancePredict, self.maxDistancePredict, Vector3.Distance(self.transform.position, self.moveTo))

    if self.leadTimePercentage ~= 0 then
       self:PredictMovement()
    end

    if self.turnRate then
        self.projectile.velocity = Vector3.RotateTowards(self.projectile.velocity / velocity, (self.moveTo - self.transform.position).normalized, self.turnRate * Time.deltaTime, 0) * velocity
    else
        self.projectile.velocity = (self.moveTo - self.transform.position).normalized * velocity
    end
end

function RadarGuidedMissile:PredictMovement()
    local predictionTime = Mathf.Lerp(0, self.maxTimePrediction, self.leadTimePercentage)

    self.moveTo = self.moveTo + self.projectile.currentTarget.rigidbody.velocity * predictionTime
end