behaviour("ActiveWithSeat")  --v1.2.0

function ActiveWithSeat:Start()
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.seat = self.targets.seat.GetComponent(Seat)

    self.activateWhenOccupied = {}
    self.deactivateWhenOccupied = {}
    self.fakeActors = {}
    
    if self.dataContainer.HasObject("activateWhenOccupied") then
        self.activateWhenOccupied[1] = self.dataContainer.GetGameObject("activateWhenOccupied")
        self.activateWhenOccupied[1].SetActive(self.seat.isOccupied)
    end
    for i, obj in pairs(self.dataContainer.GetGameObjectArray("activateWhenOccupied")) do
        self.activateWhenOccupied[#self.activateWhenOccupied + 1] = obj
        self.activateWhenOccupied[i].SetActive(self.seat.isOccupied)
    end

    if self.dataContainer.HasObject("deactivateWhenOccupied") then
        self.deactivateWhenOccupied[1] = self.dataContainer.GetGameObject("deactivateWhenOccupied")
        self.deactivateWhenOccupied[1].SetActive(not self.seat.isOccupied)
    end
    for i, obj in pairs(self.dataContainer.GetGameObjectArray("deactivateWhenOccupied")) do
        self.deactivateWhenOccupied[#self.deactivateWhenOccupied + 1] = obj
        self.deactivateWhenOccupied[i].SetActive(not self.seat.isOccupied)
    end

    if self.dataContainer.HasObject("fakeActors") then
        self.fakeActors[1] = self.dataContainer.GetGameObject("fakeActors")
        self.fakeActors[1].SetActive(self.seat.isOccupied)
    end
    for i, obj in pairs(self.dataContainer.GetGameObjectArray("fakeActors")) do
        self.fakeActors[#self.fakeActors + 1] = obj
        self.fakeActors[i].SetActive(self.seat.isOccupied)
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
