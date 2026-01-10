behaviour("TrackSound") --v1.1.0

function TrackSound:Start()
    self.audio = self.targets.audio.GetComponent(AudioSource)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.performanceMode = self.dataContainer.GetBool("performanceMode")
    self.gears = nil

    if self.performanceMode then
        self.gears = self.targets.gears.GetComponent(ScriptedBehaviour).self
    end

    self.maxSpeed = self.dataContainer.GetFloat("maxSpeed")
    self.minSpeed = self.dataContainer.GetFloat("minSpeed")
    self.maxPitch = self.dataContainer.GetFloat("maxPitch")
    self.maxVolume = self.dataContainer.GetFloat("maxVolume")
end

function TrackSound:Update()
    local velocity = 0
    
    if self.performanceMode then
        velocity = self.gears.cacheVelocity
    else
        velocity = math.abs(self.vehicleTransform.worldToLocalMatrix.MultiplyVector(self.vehicleRigidbody.velocity).z * 3.6)
    end

    self.audio.volume = Mathf.Min(velocity / self.minSpeed, 1) * self.maxVolume

    self.audio.pitch = Mathf.Min(velocity / self.maxSpeed, 1) * self.maxPitch
end
