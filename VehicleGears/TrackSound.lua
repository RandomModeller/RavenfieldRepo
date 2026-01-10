behaviour("TrackSound") --v1.0.0

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
    if self.performanceMode then
        self.audio.volume = Mathf.Min(self.gears.cacheVelocity / self.minSpeed, 1) * self.maxVolume

        self.audio.pitch = Mathf.Min(self.gears.cacheVelocity / self.maxSpeed, 1) * self.maxPitch
    else
        velocity = math.abs(self.vehicleTransform.worldToLocalMatrix.MultiplyVector(self.vehicleRigidbody.velocity).z * 3.6)
     
        self.audio.volume = Mathf.Min(velocity / self.minSpeed, 1) * self.maxVolume

        self.audio.pitch = Mathf.Min(velocity / self.maxSpeed, 1) * self.maxPitch
    end
end