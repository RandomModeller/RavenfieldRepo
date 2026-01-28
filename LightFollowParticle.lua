behaviour("LightFollowParticle")

function LightFollowParticle:Start()
    self.light = self.targets.light.GetComponent(Light)
    self.particle = self.targets.particle.GetComponent(ParticleSystem)
end

function LightFollowParticle:Update()
    self.light.enabled = self.particle.isPlaying
end