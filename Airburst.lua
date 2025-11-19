behaviour("Airburst") --v1.0.0

function Airburst:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.projectile = self.gameObject.GetComponent(Projectile)

    if self.dataContainer.HasFloat("distance") then
        self.distance = self.dataContainer.GetFloat("distance")
    else
        self.distance = Random.Range(self.dataContainer.GetFloat("distanceMin"), self.dataContainer.GetFloat("distanceMax"))
    end

    if self.dataContainer.HasFloat("lifetime") then
        self.lifetime = self.dataContainer.GetFloat("lifetime")
    else
        self.lifetime = Random.Range(self.dataContainer.GetFloat("lifetimeMin"), self.dataContainer.GetFloat("lifetimeMax"))
    end

    self.delay = self.dataContainer.GetFloat("delay")

    self.minimumHeight = 0
    if self.dataContainer.HasFloat("minimumHeight") then
        self.minimumHeight = self.dataContainer.GetFloat("minimumHeight")
    end

    self.useSphereCast = self.dataContainer.GetBool("useSphereCast")
    
    self.randomDir = false
    if self.dataContainer.HasBool("randomDir") then
        self.randomDir = self.dataContainer.GetBool("randomDir")
    end

    self.container = nil
    if self.targets.container ~= nil then
        self.container = self.targets.container.transform

        for i = 1, self.container.childCount do
            if self.randomDir then
                self.container.GetChild(i-1).forward = Random.onUnitSphere
            end

            self.container.GetChild(i-1).localPosition = Vector3.zero
        end
    end

    self.hasExploded = false
    self.countdownStarted = false
    self.time = Time.time
end

function Airburst:Update()
    if self.hasExploded then
        return
    end

    if self.countdownStarted then
        self.delay = self.delay - Time.deltaTime

        if self.delay <= 0 then
            self:Explode()
        end

        return
    end

    if not self.randomDir and self.container ~= nil then
        self.container.up = Vector3.up
        self.container.Rotate(0, Random.Range(0, 360), 0, Space.World)
    end
    
    if Time.time - self.time >= self.lifetime then
        self:StartCountdown()
    end


    if self.distance > 0 then
        local trigger = false
        local ray = nil

        if self.useSphereCast then
            if self.minimumHeight > 0 then
                ray = Physics.Raycast(Ray(self.transform.position, -Vector3.up), self.minimumHeight, RaycastTarget.Opaque)

                if ray == nil then
                    trigger = true
                end
            end

            if trigger then
                trigger = false
                ray = Physics.OverlapSphere(self.transform.position, self.distance, RaycastTarget.ProjectileHit)
                if #ray > 0 then
                    trigger = true
                end
            end
        else
            ray = Physics.Raycast(Ray(self.transform.position, -Vector3.up), self.distance, RaycastTarget.Opaque)

            if ray ~= nil then
                trigger = true
            end
        end

        if trigger then
            self:StartCountdown()
        end
    end
end

function Airburst:StartCountdown()
    self.countdownStarted = true

    if self.delay <= 0 then
        self:Explode()
    end
end

function Airburst:Explode()
    self.hasExploded = true
    self.projectile.Stop(false)
end