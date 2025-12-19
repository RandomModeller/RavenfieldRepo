behaviour("ModernOptic") --v2.0.0

function ModernOptic:Start()
    self.camera = self.targets.camera.GetComponent(Camera)
    self.cameraTransform = self.camera.transform
    self.seat = self.targets.seat.GetComponent(Seat)

    self.lastAiming = self:AimStatus()

    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.minRange = self.dataContainer.GetFloat("minRange")
    self.maxRange = self.dataContainer.GetFloat("maxRange")
    self.minFov = self.dataContainer.GetFloat("minFov")
    self.defaultFov = self.dataContainer.GetFloat("defaultFov")
    self.defaultAimFov = self.dataContainer.GetFloat("defaultAimFov")
    self.maxFov = self.dataContainer.GetFloat("maxFov")
    self.fovStep = self.dataContainer.GetFloat("fovStep")

    self.factor = (self.minFov - self.maxFov) / (self.maxRange - self.minRange)
    self:ResetZoom()

    self.fieldOfViewTarget = self.camera.fieldOfView
end

function ModernOptic:LateUpdate()
    local isAiming = self:AimStatus()

    if isAiming ~= self.lastAiming then
        if not isAiming then
            self:ResetZoom()
        else
            local raycast = Physics.Raycast(Ray(self.cameraTransform.position, self.cameraTransform.forward), self.maxRange, RaycastTarget.ProjectileHit)

            if raycast ~= nil then
                local distance = Vector3.Distance(raycast.point, self.cameraTransform.position)

                if distance < self.minRange then
                    self.fieldOfViewTarget = self.minFov
                elseif distance > self.maxRange then
                    self.fieldOfViewTarget = self.maxFov
                else
                    self.fieldOfViewTarget = (self.maxFov - distance) * self.factor + self.minFov
                end
            else
                self.fieldOfViewTarget = self.defaultAimFov
            end
        end

        self.lastAiming = isAiming
    end

    if Input.GetMouseButtonDown(4) or Input.GetKeyDown(KeyCode.Keypad4) then -- zoom out
        self:Zoom(1)
    end

    if Input.GetMouseButtonDown(3) or Input.GetKeyDown(KeyCode.Keypad6) then -- zoom in
        self:Zoom(-1)
    end

    self.camera.fieldOfView = self.fieldOfViewTarget
end

function ModernOptic:AimStatus()
    if self.seat.activeWeapon ~= nil then
        return self.seat.activeWeapon.isAiming
    end

    return false
end

function ModernOptic:Zoom(val)
    self.fieldOfViewTarget = Mathf.Clamp(self.fieldOfViewTarget + (self.fovStep * val), self.maxFov, self.minFov)
end

function ModernOptic:ResetZoom()
    self.fieldOfViewTarget = self.defaultFov
end