behaviour("FalconCountermeasures") --v1.0.0

function FalconCountermeasures:Start()
    self.vehicleObject = self.targets.vehicleObject.GetComponent(Vehicle)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.text = self.targets.text.GetComponent(Text)

    self.particleLeft = self.targets.particleLeft.GetComponent(ParticleSystem)
    self.particleRight = self.targets.particleRight.GetComponent(ParticleSystem)
    self.particleBot = self.targets.particleBot.GetComponent(ParticleSystem)

    self.chaffFlare = self.targets.chaffFlare.GetComponent(AudioSource)
    self.sound = self.targets.sound.GetComponent(AudioSource)
    self.bumpSwitch = self.targets.bumpSwitch.GetComponent(AudioSource)

    self.chanceFar = self.dataContainer.GetFloat("chanceFar")
    self.chanceClose = self.dataContainer.GetFloat("chanceClose")
    self.rangeFar = self.dataContainer.GetFloat("rangeFar") ^ 2
    self.rangeClose = self.dataContainer.GetFloat("rangeClose") ^ 2
    self.count = self.dataContainer.GetInt("count")
    self.left = true
    self.isPreemptive = false

    self.deployTimeMin = 0.2
    self.deployTimeMax = 0.7
    self.protectionTimeMin = 2
    self.protectionTimeMax = 4.5
    self.cooldownTimeMin = 2
    self.cooldownTimeMax = 5

    self.time = 0
    self.expire = 0
    self.countering = false
    self.flared = false

    self.keybind = KeyBinds.Countermeasures
end

function FalconCountermeasures:Update()
    if self.vehicleObject.playerIsInside then
        if Input.GetKeyBindButtonDown(self.keybind) and self.count > 0 then
            if Input.GetKey(KeyCode.LeftShift) or Input.GetKey(KeyCode.RightShift) then
                self.isPreemptive = not self.isPreemptive
                self.time = Time.time
            else
                self:PlayerCountermeasure()
            end
        end

        if self.isPreemptive and Time.time >= self.time then
            self:PlayerCountermeasure()

            self.time = Time.time + 1
        end

        local instrumentText = tostring(self.count * 2) .. tostring(self.count)

        instrumentText = instrumentText:sub(1, 1) .. " " .. instrumentText:sub(2, 2) .. "   " .. instrumentText:sub(3, 3) .. " " .. instrumentText:sub(4, 4)

        self.text.text = instrumentText
    elseif self.vehicleObject.hasDriver then
        local missiles = self.vehicleObject.GetTrackingMissiles()

        if #missiles > 0 and self.count > 0 then
            if not self.countering then
                if Time.time >= self.time then
                    self.time = Time.time + Random.Range(self.deployTimeMin, self.deployTimeMax)
                    self.expireTime = self.time + Random.Range(self.protectionTimeMin, self.protectionTimeMax)
                    self.countering = true
                    self.flared = false
                end
            else
                if Time.time >= self.time then
                    if not self.flared then
                        self.flared = true

                        self.particleBot.Play(true)
                        self.sound.Play()

                        self.count = self.count - 6
                    end

                    for i, missile in pairs(self.vehicleObject.GetTrackingMissiles()) do
                        missile.ClearTrackerTarget()
                    end
                end
                if Time.time >= self.expireTime then
                    self.countering = false
                    self.flared = false
                    self.time = self.expireTime + Random.Range(self.cooldownTimeMin, self.cooldownTimeMax)
                end
            end
        end
    end
end

function FalconCountermeasures:PlayerCountermeasure()
    local m = (self.chanceClose - self.chanceFar) / (self.rangeFar - self.rangeClose)

    for i, missile in pairs(self.vehicleObject.GetTrackingMissiles()) do
        local chance = 0

        local sqrRange = (missile.transform.position - self.transform.position).sqrMagnitude

        local factor = Mathf.Clamp((self.rangeClose - sqrRange) * m, 0, 1) + self.chanceClose

        if Random.Range(0, 1) <= chance then
            missile.ClearTrackerTarget()
        end
    end

    if self.left then
        self.particleLeft.Play(true)
    else
        self.particleRight.Play(true)
    end

    self.sound.Play()
    self.bumpSwitch.Play()

    if not self.chaffFlare.isPlaying then
        self.chaffFlare.Play()
    end

    self.count = self.count - 1
    self.left = not self.left
end
