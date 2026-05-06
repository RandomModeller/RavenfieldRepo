behaviour("ActiveWithSeat")  --v1.1.0

function ActiveWithSeat:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.seat = self.targets.seat.GetComponent(Seat)

    self.activateWhenOccupied = self.dataContainer.GetGameObjectArray("activateWhenOccupied")
    self.deactivateWhenOccupied = self.dataContainer.GetGameObjectArray("deactivateWhenOccupied")
    self.fakeActors = {}
    if self.dataContainer.HasObject("fakeActors1") then
        self.fakeActors = self.dataContainer.GetGameObjectArray("fakeActors")
    end
    
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

        for i, obj in pairs(self.fakeActors) do
            obj.SetActive(self.seat.isOccupied)

            if self.seat.isOccupied then
                local skin = self.seat.occupant.GetOverrideActorSkin()

                if skin == nil then
                    skin = ActorManager.GetTeamSkin(self.seat.occupant.team)
                end

                skin.characterSkin.Apply(obj.GetComponent(SkinnedMeshRenderer), self.seat.occupant.team)
            end
        end

        self.isOccupied = self.seat.isOccupied
    end
end
