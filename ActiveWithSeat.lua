behaviour("ActiveWithSeat")  --v1.0.1

function ActiveWithSeat:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.seat = self.targets.seat.GetComponent(Seat)

    self.activateWhenOccupied = self.dataContainer.GetGameObjectArray("activateWhenOccupied")
    self.deactivateWhenOccupied = self.dataContainer.GetGameObjectArray("deactivateWhenOccupied")
    
    self.isOccupied = self.seat.isOccupied
end

function ActiveWithSeat:Update()
    if self.seat.isOccupied ~= self.isOccupied then
        for i, obj in pairs(self.activateWhenOccupied) do
            obj.SetActive(self.seat.isOccupied)
        end

        for i, obj in pairs(self.deactivateWhenOccupied) do
            obj.SetActive(not self.seat.isOccupied)
        end

        self.isOccupied = self.seat.isOccupied
    end
end
