behaviour("TrackerActivator") --v1.0.0

function TrackerActivator:Start()
    self.seat = self.targets.seat.GetComponent(Seat)
    if self.targets.tracker then
       self.tracker = self.targets.tracker
    end
end

function TrackerActivator:Update()
    if self.tracker then
        self.tracker.SetActive(not (self.seat.occupant == Player.actor))
    else
        self.gameObject.SetActive(not (self.seat.occupant == Player.actor))
    end
end