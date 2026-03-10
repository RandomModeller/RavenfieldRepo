behaviour("PlayerCountTiedSeat")  --v1.0.0

function PlayerCountTiedSeat:Start()
    self.vehicle = self.targets.vehicle.GetComponent(Vehicle)
    self.seat = self.targets.seat.GetComponent(Seat)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    self.minimumPlayer = self.dataContainer.GetInt("minimumPlayer")

    -- self.affectPlayer = self.dataContainer.GetBool("affectPlayer")
    -- self.kickFromSquad = self.dataContainer.GetBool("kickFromSquad")
    -- self.kickFromSquadExcludePlayerSquad = self.dataContainer.GetBool("kickFromSquadExcludePlayerSquad")
end

function PlayerCountTiedSeat:Update()
    if self.vehicle.ownerTeam ~= Team.Neutral then
        local playerCount = #ActorManager.GetActorsOnTeam(self.vehicle.ownerTeam)
        local playerAboveMinimum = playerCount >= self.minimumPlayer

        self.seat.gameObject.SetActive(playerAboveMinimum)

        -- if not playerAboveMinimum then
        --     local bot = self.seat.occupant

        --     if bot ~= nil then
        --         local isPlayer = bot == Player.actor
        --         local inPlayerSquad = bot.squad.leader == Player.actor

        --         if not (isPlayer and self.affectPlayer) then
        --             -- bot.ExitVehicle()

        --             if not isPlayer and self.kickFromSquad and not (inPlayerSquad and self.kickFromSquadExcludePlayerSquad) then
        --                 bot.squad.RemoveMember(bot)
        --             end
        --         end
        --     end
        -- end
    end
end
