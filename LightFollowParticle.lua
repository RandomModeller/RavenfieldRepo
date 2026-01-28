behaviour("LightFollowParticle") --v1.0.0

function LightFollowParticle:Start()
    self.light = self.targets.light.GetComponent(Light)
    self.particle = self.targets.particle.GetComponent(ParticleSystem)
end

function LightFollowParticle:Update()
    self.light.enabled = self.particle.isPlaying

end
