local api, CHILDS, CONTENTS = ...

-- local json = require "json"

local M = {}
-- local font
-- local image


-- local fallback_asset
-- local bg_color
local pages

function M.updated_config_json(config) -- if page child settings are updated
    -- accounts = config.accounts


    -- font = resource.load_font(api.localized(config.font.asset_name))
    -- image =
    --     resource.load_image {
    --     file = api.localized(config.default_image.asset_name),
    --     mipmap = true
    -- }

    -- bg_color = config.background_color

    node.gc() -- force garbace collection on node
end

local data
function M.updated_spotify_json(spotify_json)
    data = spotify_json
end


function M.task(starts, ends, config, x1, y1, x2, y2) -- render child node
    print("start en end", starts, ends)
    print("account_name from config", config.account_name)

    local width = x2 - x1
    local height = y2 - y1

    local 
    local bg_color
    for key, account_options in pairs(config.accounts) do
        if accounts_options.account_name == config.account_name_tile then
            fallback_asset =
                resource.load_image {
                file = api.localized(accounts_options.fallback_asset.asset_name),
                mipmap = true
            }
            bg_color = account_options.bg_color
            break
        end
    end


    api.wait_t(starts - 10)

    for now in api.frame_between(starts, ends) do
        --local event = event_gen.next()

            api.screen.set_scissor(x1, y1, x2, y2)
            gl.clear(bg_color.r, bg_color.g, bg_color.b, bg_color.a) -- green

            fallback_asset:draw(x1, y1, x2, y2)
            end
            api.screen.set_scissor()
        end

        -- clean up
        print("cleaning up", starts, ends, sys.now())
        api.wait_t(ends + 5)
        print("cleaning up after", starts, ends, sys.now())

        fallback_asset:dispose()
    end
end

function M.unload()
    print "sub module is unloaded"
end

function M.content_update(name)
    print("sub module content update", name)
end

function M.content_remove(name)
    print("sub module content delete", name)
end

return M
