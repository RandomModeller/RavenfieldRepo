behaviour("SeatAffectReload") --v1.2.0

function SeatAffectReload:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    
    self.weapon = self.targets.weapon.GetComponent(Weapon)
    if self.targets.animator then
        self.animator = self.targets.animator.GetComponent(Animator)
        self.name = self.animator.StringToHash("reloadSpeedMultiplier")
    end
    if self.targets.reloadSound then
        self.reloadSound = self.targets.reloadSound.GetComponent(AudioSource)
        self.reloadSounds = self.dataContainer.GetAudioClipArray("reloadSound")
    end

    self.seats = {}

    for i, seat in pairs(self.dataContainer.GetGameObjectArray("seat")) do
        self.seats[i] = seat.GetComponent(Seat)
    end

    self.baseReload = self.weapon.reloadTime
    self.secondsPerEmptySeat = self.dataContainer.GetFloat("secondsPerEmptySeat")
end

function SeatAffectReload:Update()
    local numberOfEmptySeat = 0

    for i, seat in pairs(self.seats) do
        if seat.occupant == nil then
            numberOfEmptySeat = numberOfEmptySeat + 1
        end
    end

    self.weapon.reloadTime = self.baseReload + numberOfEmptySeat * self.secondsPerEmptySeat

    if self.animator then
        self.animator.SetFloat(self.name, self.baseReload / self.weapon.reloadTime)
    end

    if self.reloadSound then
        self.reloadSound.clip = self.reloadSounds[numberOfEmptySeat + 1]
    end
end
