behaviour("SAMMover") --v1.0.0

function SAMMover:Start()
    -- self.vehicle = self.targets.vehicleObject.GetComponent(Vehicle)
    self.dataContainer = self.gameObject.GetComponent(DataContainer)

    -- self.useControl = self.dataContainer.GetBool("useControl")
    self.target = self.gameObject.transform
    if self.targets.target then
        self.target = self.targets.target.transform
    end

    local position = self.target.position

    position.y = position.y + 2000
    
    local ray = Physics.Raycast(Ray(position, -Vector3.up), Mathf.Infinity, RaycastTarget.Opaque)

    if ray ~= nil then
        self.target.position = ray.point + Vector3(0, self.dataContainer.GetFloat("yOffset"), 0)
    end
end

-- function SAMMover:Update()
--     if self.useControl and (not (Input.GetKey(KeyCode.LeftControl) or Input.GetKey(KeyCode.RightControl))) or (not self.vehicle.playerIsInside) then
--         return
--     end

--     if not self.useControl and (not (Input.GetKey(KeyCode.LeftAlt) or Input.GetKey(KeyCode.RightAlt))) or (not self.vehicle.playerIsInside) then
--         return
--     end

--     local shift = Input.GetKey(KeyCode.LeftShift) or Input.GetKey(KeyCode.RightShift)

--     if Input.GetKey(KeyCode.UpArrow) then
--         if shift then
--             self.target.Translate(Vector3.up * Time.deltaTime * 2)
--         else
--             self.target.Translate(Vector3.forward * Time.deltaTime * 2)
--         end
--     end

--     if Input.GetKey(KeyCode.DownArrow) then
--         if shift then
--             self.target.Translate(-Vector3.up * Time.deltaTime * 2)
--         else
--             self.target.Translate(-Vector3.forward * Time.deltaTime * 2)
--         end
--     end

--     if Input.GetKey(KeyCode.LeftArrow) then
--         self.target.Translate(Vector3.left * Time.deltaTime * 2)
--     end

--     if Input.GetKey(KeyCode.RightArrow) then
--         self.target.Translate(-Vector3.left * Time.deltaTime * 2)
--     end
-- end
