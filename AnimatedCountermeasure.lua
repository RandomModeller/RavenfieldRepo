behaviour("AnimatedCountermeasure") --v1.0.0

function AnimatedCountermeasure:Start()
    self.animator = self.targets.animator.GetComponent(Animator)
    if self.targets.hands ~= nil then
        self.seat = self.targets.seat.GetComponent(Seat)
        self.hands = self.targets.hands.GetComponent(SkinnedMeshRenderer)
    end

    if self.targets.audio ~= nil then
        self.audio = self.targets.audio.GetComponent(AudioSource)
    end

    if self.targets.particleSystem ~= nil then
        self.particleSystem = self.targets.particleSystem.GetComponent(ParticleSystem)
    end

    self.COUNTERMEASURE_ANIMATION_HASH = Animator.StringToHash("deploy_countermeasure")
end

function AnimatedCountermeasure:LateUpdate()
    local flag1 = true
    local flag2 = true

    if self.hands ~= nil then
        if self.seat.occupant ~= nil then
            local skin = self.seat.occupant.GetOverrideActorSkin()

            if skin == nil then
                skin = ActorManager.GetTeamSkin(self.seat.occupant.team)
            end

            self.hands.sharedMesh = skin.mesh
            self.hands.sharedMaterials = skin.materials
        end
    end

    if self.audio ~= nil then
        flag1 = self.audio.isPlaying
    end

    if self.particleSystem ~= nil then
        flag2 = self.particleSystem.isPlaying
    end

    if Input.GetKeybindButtonDown(KeyBinds.Countermeasures) and flag1 and flag2 then
        self.animator.SetTrigger(self.COUNTERMEASURE_ANIMATION_HASH)
    end
end