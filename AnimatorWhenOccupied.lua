behaviour("AnimatorWhenOccupied") --v1.0.0

function AnimatorWhenOccupied:Start()
    self.animator = self.targets.animator.GetComponent(Animator)
    self.seat = self.targets.seat.GetComponent(Seat)

    self.name = self.animator.StringToHash(self.gameObject.GetComponent(DataContainer).GetString("name"))
end

function AnimatorWhenOccupied:Update()
    self.animator.SetBool(self.name, self.seat.occupant ~= nil)
end