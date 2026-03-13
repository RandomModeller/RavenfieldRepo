behaviour("CoaxFireButton") -- v1.0.0

function CoaxFireButton:Start()
    self.coax = self.targets.coax.GetComponent(Weapon)

    --self.vehicle = self.targets.vehicleObject.GetComponent(Vehicle)
    self.audio = self.targets.audio.GetComponent(AudioSource)
    self.seat = self.targets.seatTarget.GetComponent(Seat)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.keybind = self.dataContainer.GetString("keybind")
end

function CoaxFireButton:Update()
    if Input.GetKey(self.keybind) and self.seat.occupant == Player.actor then
        if Input.GetKeyDown(self.keybind) and self.coax.canFire then
            self.audio.Play()
        end

        self.coax.Shoot(false)
    end

    if Input.GetKeyUp(self.keybind) then
        self.audio.Stop()
    end
end
