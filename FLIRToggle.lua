behaviour("FLIRToggle") --v1.1.0

function FLIRToggle:Start()
    if self.targets.vehicleObject == nil then
        self.seat = self.targets.seat.GetComponent(Seat)
    else
        self.vehicle = self.targets.vehicleObject.GetComponent(Vehicle)
    end
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.keybind = self.dataContainer.GetString("keybind")

    self.mainCamera = self.targets.mainCamera.GetComponent(Camera)
    self.flirCamera1 = self.targets.flirCamera1.GetComponent(Camera)
    self.flirCamera2 = self.targets.flirCamera2.GetComponent(Camera)
    self.flirCamera3 = self.targets.flirCamera3.GetComponent(Camera)
    self.panel = self.targets.panel

    self.enabled = false
    self.last = false
end

function FLIRToggle:Update()
    local flag1 = false

    if self.seat == nil then
        flag1 = self.seat.occupant == Player.actor
    else
        flag1 = self.vehicle.playerIsInside
    end

    if Input.GetKeyDown(self.keybind) and flag1 and not PlayerCamera.tpCamera.enabled then
        self.enabled = not self.enabled

        self.mainCamera.enabled = not self.enabled
        self.flirCamera1.enabled = self.enabled
        self.flirCamera2.enabled = self.enabled
        self.flirCamera3.enabled = self.enabled
        self.panel.SetActive(self.enabled)
        if self.targets.activateOnEnable ~= nil then
            self.targets.activateOnEnable.SetActive(self.enabled)
        end
        if self.targets.deactivateOnEnable ~= nil then
            self.targets.deactivateOnEnable.SetActive(not self.enabled)
        end
    end

    local camFov = self.mainCamera.fieldOfView

    self.flirCamera1.fieldOfView = camFov
    self.flirCamera2.fieldOfView = camFov
    self.flirCamera3.fieldOfView = camFov
end
