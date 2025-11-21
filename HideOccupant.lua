behaviour("HideOccupant") --v1.0.0

function HideOccupant:Start()
    self.seat = self.targets.seat.GetComponent(Seat)

    self.lastOccupant = nil

    self.isPlayer = false
end

function HideOccupant:Update()
    local occupant = self.seat.occupant

    if occupant ~= self.lastOccupant then

        if occupant == nil then -- exit
            local isPlayer = self.lastOccupant == Player.actor

            if isPlayer then
                self.isPlayer = false
                Player.SetFirstPersonRenderMode()
            elseif not self.lastOccupant.isDead then
                self.lastOccupant.gameObject.transform.GetChild(0).GetChild(1).gameObject.GetComponent(Renderer).enabled = true
            end
        else -- enter
            local isPlayer = occupant == Player.actor

            if isPlayer then
                self.isPlayer = true

                if self.lastOccupant ~= Player.actor and self.lastOccupant ~= nil and not self.lastOccupant.isDead then
                    self.lastOccupant.gameObject.transform.GetChild(0).GetChild(1).gameObject.GetComponent(Renderer).enabled = true
                end
            else
                occupant.gameObject.transform.GetChild(0).GetChild(1).gameObject.GetComponent(Renderer).enabled = false
            end
        end

        self.lastOccupant = occupant
    end

    if self.isPlayer then
        Player.SetFirstPersonRenderMode()
    end

end
