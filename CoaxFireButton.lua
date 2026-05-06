behaviour("CoaxFireButton") --v1.2.1

function CoaxFireButton:Start()
    self.coax = self.targets.coax.GetComponent(Weapon)

    --self.vehicle = self.targets.vehicleObject.GetComponent(Vehicle)
    self.audio = self.targets.coax.GetComponent(AudioSource)
    self.seat = self.targets.seatTarget.GetComponent(Seat)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    self.keybind = self.dataContainer.GetString("keybind")
end

function CoaxFireButton:LateUpdate()
    if self.seat.activeWeapon == self.coax then
        if Input.GetKey(self.keybind) then
            if self.coax.canFire then
                self.coax.Shoot(true)
            end
            self.audio.volume = 1
        end
    else
        if Input.GetKey(self.keybind) and self.seat.occupant == Player.actor then
            if Input.GetKeyDown(self.keybind) and self.coax.canFire then
                self.audio.Play()
                self.audio.volume = 1
            end

            if self.coax.canFire then
                self.coax.Shoot(true)
            end
        end

        if not Input.GetKey(self.keybind) then
            self.audio.Stop()
        end
    end
end
