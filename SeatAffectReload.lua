behaviour("SeatAffectReload") --v1.0.0

function SeatAffectReload:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    
    self.weapon = self.targets.weapon.GetComponent(Weapon)
    self.seats = self.dataContainer.GetGameObjectArray("seat")

    for i, seat in pairs(self.seats) do
        seat = seat.GetComponent(Seat)
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
end