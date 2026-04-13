behaviour("PlaneGear") --v1.2.2

function PlaneGear:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.animator = self.targets.animator.GetComponent(Animator)
    self.vehicle = self.targets.vehicleObject.GetComponent(Vehicle)
    self.rigidbody = self.vehicle.rigidbody
    self.heightChecker = self.targets.heightChecker.GetComponent(ScriptedBehaviour).self

    self.name = self.animator.StringToHash(self.dataContainer.GetString("name"))

    self.gearDown = true
    self.gearValue = 1

    self.gearDeployDuration = 2.5
    if self.dataContainer.HasFloat("gearDeployDuration") then
        self.gearDeployDuration = self.dataContainer.GetFloat("gearDeployDuration")
    end

    self.gearDeployDuration = 1 / self.gearDeployDuration

    self.drag = 0.045
    local loadKeybind = true

    if self.dataContainer.HasFloat("drag") then
        self.drag = self.dataContainer.GetFloat("drag")
    end
    
    if self.dataContainer.HasString("keybind") then
        self.key = self.dataContainer.GetString("keybind")
        loadKeybind = false
    end

    if self.dataContainer.HasBool("useMutatorKeybind") then
        loadKeybind = self.dataContainer.HasBool("useMutatorKeybind")
    end

    self.loadedKeybind = DebilFalconConfig_ConfigLoaded
    if self.loadedKeybind then
        self:LoadKeybind()
    end
end

function PlaneGear:Update()
    if not self.loadedKeybind then
        self:LoadKeybind()

        self.loadedKeybind = true
    end

    if self.vehicle.playerIsInside then
        if Input.GetKeyDown(self.key) then
            self.gearDown = not self.gearDown

            self.animator.SetBool(self.name, self.gearDown)

            if self.gearDown then
                self.rigidbody.drag = self.rigidbody.drag + self.drag
            else
                self.rigidbody.drag = self.rigidbody.drag - self.drag
            end
        end
    else
        self.animator.SetBool(self.name, self.heightChecker.height <= 20 and self.rigidbody.velocity.sqrMagnitude <= 5300)
    end

    self.gearValue = Mathf.Clamp(self.gearValue + (self.gearDown and 1 or -1) * self.gearDeployDuration * Time.deltaTime, 0, 1)
end

function PlaneGear:LoadKeybind()
    local script = GameObject.Find("F-16 Config(Clone)")

    if script then
        script = script.GetComponent(ScriptedBehaviour).self
       
        if script then
            self.key = script.DebilFalconConfig_GearToggle
        end
    end
    if self.key == nil then
        self.key = KeyCode.Z
    end
end
