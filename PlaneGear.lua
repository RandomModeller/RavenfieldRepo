behaviour("PlaneGear") --v1.1.0

function PlaneGear:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.animator = self.targets.animator.GetComponent(Animator)
    self.vehicle = self.targets.vehicleObject.GetComponent(Vehicle)
    self.rigidbody = self.vehicle.rigidbody
    self.heightChecker = self.targets.heightChecker.GetComponent(ScriptedBehaviour).self

    self.name = self.animator.StringToHash(self.gameObject.GetComponent(DataContainer).GetString("name"))

    self.gearDown = true

    self.drag = 0.045
    local loadKeybind = true

    if self.dataContainer ~= nil then
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
        self.animator.SetBool(self.name, self.heightChecker.height <= 20)
    end
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
