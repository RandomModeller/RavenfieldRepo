behaviour("SeatAffectMagazineSize") --v1.0.0

function SeatAffectMagazineSize:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)
    
    self.weapon = self.targets.weapon.GetComponent(Weapon)

    self.seats = {}

    for i, seat in pairs(self.dataContainer.GetGameObjectArray("seat")) do
        self.seats[i] = seat.GetComponent(Seat)
    end

    self.baseMaxAmmo = self.weapon.maxAmmo
    self.ammoPerOccupiedSeat = self.dataContainer.GetFloat("ammoPerOccupiedSeat")
end

function SeatAffectMagazineSize:Update()
    local numberOfOccupiedSeat = 0

    for i, seat in pairs(self.seats) do
        if seat.occupant ~= nil then
            numberOfOccupiedSeat = numberOfOccupiedSeat + 1
        end
    end

    self.weapon.maxAmmo = self.baseMaxAmmo + numberOfOccupiedSeat * self.ammoPerOccupiedSeat
end