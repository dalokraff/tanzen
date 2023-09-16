local mod = get_mod("tanzen")

-- Your mod code goes here.
-- https://vmf-docs.verminti.de

mod.tanzerin = {}


mod:hook(UnitSpawner, "spawn_local_unit", function(func, self, unit_name, position, rotation, material)
    local unit = func(self, unit_name, position, rotation, material)

    if unit_name == "units/beings/enemies/chaos_spawn/chr_chaos_spawn" then
        local root2root = {
            {
                target = 0,
                source = 0,
            },
        }

        local pos = Unit.world_position(unit, 0)
        local light_unit1 = Managers.state.unit_spawner:spawn_local_unit("units/light")
        local light_unit2 = Managers.state.unit_spawner:spawn_local_unit("units/light")
        local light_unit3 = Managers.state.unit_spawner:spawn_local_unit("units/light")

        local light_unit4 = Managers.state.unit_spawner:spawn_local_unit("units/light")
        local light_unit5 = Managers.state.unit_spawner:spawn_local_unit("units/light")
        local light_unit6 = Managers.state.unit_spawner:spawn_local_unit("units/light")
        local light_unit7 = Managers.state.unit_spawner:spawn_local_unit("units/light")

        AttachmentUtils.link(self.world, unit, light_unit1, root2root)
        AttachmentUtils.link(self.world, unit, light_unit2, root2root)
        AttachmentUtils.link(self.world, unit, light_unit3, root2root)

        AttachmentUtils.link(self.world, unit, light_unit4, root2root)
        AttachmentUtils.link(self.world, unit, light_unit5, root2root)
        AttachmentUtils.link(self.world, unit, light_unit6, root2root)
        AttachmentUtils.link(self.world, unit, light_unit7, root2root)

        Unit.set_local_position(light_unit1, 0, Vector3(-1,1,2))
        Unit.set_local_position(light_unit2, 0, Vector3(1,1,1.5))
        Unit.set_local_position(light_unit3, 0, Vector3(1,-1,1))

        Unit.set_local_position(light_unit4, 0, Vector3(1.5,-1.5,3))
        Unit.set_local_position(light_unit5, 0, Vector3(1.5,-1.5,3))
        Unit.set_local_position(light_unit6, 0, Vector3(-1.5,-1.5,3))
        Unit.set_local_position(light_unit7, 0, Vector3(-1.5,1.5,3))

        local wwise_world = Wwise.wwise_world(self.world)
        local sound_id
        local wwise_source_id
        sound_id, wwise_source_id = WwiseWorld.trigger_event(wwise_world, "tanzen", unit)

        mod.tanzerin[unit] = {
            lights = {
                light_unit1,
                light_unit2,
                light_unit3,
                light_unit4,
                light_unit5,
                light_unit6,
                light_unit7,
            },
            sound_id = sound_id,
            wwise_source_id = wwise_source_id
        }

        mod:echo("Sound Id: "..tostring(sound_id))
    end

    return unit
end)

math.randomseed(os.time())
local time = 0
mod.update = function(dt)
    if time > 0.25 then
        for unit, tanz_data in pairs(mod.tanzerin) do
            if Unit.alive(unit) then 
                if Managers.world:has_world("level_world") then
                    for _, light_unit in pairs(tanz_data.lights) do
                        local light = Unit.light(light_unit, "omni")
                        local light_color = Vector3(0,0,0)
                        Vector3.set_element(light_color, math.random(3)%3+1, math.random())
                        Light.set_color(light, light_color)
                    end

                
                    local world = Managers.world:world("level_world")
                    local wwise_world = Wwise.wwise_world(world)
                    if not WwiseWorld.is_playing(wwise_world, tanz_data.sound_id) then
                        local sound_id
                        local wwise_source_id
                        sound_id, wwise_source_id = WwiseWorld.trigger_event(wwise_world, "tanzen", unit)
                        mod.tanzerin[unit].sound_id = sound_id
                        mod.tanzerin[unit].wwise_source_id = wwise_source_id
                    end
                end
            else
                for _, light_unit in pairs(tanz_data.lights) do
                    if Unit.alive(light_unit) then
                        Managers.state.unit_spawner:mark_for_deletion(light_unit)
                    end
                end

                if Managers.world:has_world("level_world") then
                    local world = Managers.world:world("level_world")
                    local wwise_world = Wwise.wwise_world(world)
                    WwiseWorld.stop_event(wwise_world, tanz_data.sound_id)
                    WwiseWorld.destroy_manual_source(wwise_world, tanz_data.wwise_source_id)
                    mod:echo("Sound Id: "..tostring(tanz_data.sound_id))
                end

                mod.tanzerin[unit] = nil
            end
        end
        time = 0
    else
        time = time + dt
    end
end
