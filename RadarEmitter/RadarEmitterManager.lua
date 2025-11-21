behaviour("RadarEmitterManager") --v1.0.0

function RadarEmitterManager:Awake()
    self.DebilRadarEmitters = {}
end

function RadarEmitterManager:Add(new)
    for i, emitter in pairs(self.DebilRadarEmitters) do
        if emitter == nil then
            self.DebilRadarEmitters[i] = new
            return
        end
    end

    self.DebilRadarEmitters[#self.DebilRadarEmitters + 1] = new
end