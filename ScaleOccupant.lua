behaviour("ScaleOccupant") -- v1.3.0

function ScaleOccupant:Start()
    self.seat = self.targets.seat.GetComponent(Seat)
    self.scale = self.gameObject.GetComponent(DataContainer).GetVector("scale")

    self.lastOccupant = nil

    -- self.isPlayer = false

    
end

function ScaleOccupant:Update()
    local occupant = self.seat.occupant

    if occupant ~= self.lastOccupant then
        if occupant == nil then -- exit
            local isPlayer = self.lastOccupant == Player.actor

            if isPlayer then -- if player exit
                -- self.isPlayer = false
                -- if self.playerArmature == nil then
                    -- self:FindPlayer()
                -- end
                self:FindPlayer()
                self.playerArmature.localScale = Vector3.one -- reset player scale
            else -- if not player exit
                -- self.lastOccupant.gameObject.transform.localScale = Vector3.one
                self.lastOccupant.gameObject.transform.GetChild(0).GetChild(0).localScale = Vector3.one -- reset bot scale
            end
        else -- enter
            local isPlayer = occupant == Player.actor

            if isPlayer then
                -- self.isPlayer = true
                -- if self.playerArmature == nil then
                    -- self:FindPlayer()
                -- end
                self:FindPlayer()
                self.playerArmature.localScale = self.scale -- set player scale

                if self.lastOccupant ~= Player.actor and self.lastOccupant ~= nil and not self.lastOccupant.isDead then -- if player entered and replaced a bot
                    self.lastOccupant.gameObject.transform.GetChild(0).GetChild(0).localScale = Vector3.one -- reset bot scale
                end
            else
                -- occupant.gameObject.transform.localScale = self.scale
                occupant.gameObject.transform.GetChild(0).GetChild(0).localScale = self.scale -- set bot scale
            end
        end

        self.lastOccupant = occupant
    end

    --if self.isPlayer then
    --    Player.SetFirstPersonRenderMode()
    --end
end

function ScaleOccupant:FindPlayer()
    self.playerArmature = GameObject.Find("Actor Parent").transform.Find("Soldier").Find("Armature")
    -- print(GameObject.Find("Actor Parent"))
    -- print(GameObject.Find("Actor Parent").transform.Find("Soldier"))
    -- print(GameObject.Find("Actor Parent").transform.Find("Soldier").Find("Armature"))
end