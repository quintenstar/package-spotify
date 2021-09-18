local api, CHILDS, CONTENTS = ...

-- local json = require "json"

local M = {}
-- local font
-- local image


-- local fallback_asset
-- local bg_color
local accounts

function M.updated_config_json(config) -- if page child settings are updated
    accounts = config.accounts


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
    print("spotify_json", spotify_json)
    data = spotify_json
end


function M.task(starts, ends, config, x1, y1, x2, y2) -- render child node
    print("start en end", starts, ends)
    print("account_name from config", config.account_name_tile)

    local width = x2 - x1
    local height = y2 - y1

    local cover
    local font
    local fallback_asset
    local bg_color
    local font_color
    for key, account_options in pairs(accounts) do
        print(account_options.account_name)
        if account_options.account_name == config.account_name_tile then
            -- fallback_asset =
            --     resource.load_image {
            --     file = api.localized(account_options.fallback_asset.asset_name),
            --     mipmap = true
            -- }
            cover = resource.load_image {
                file = api.localized(data.cover_image_640),
                mipmap = true
            }

            font = resource.load_font(api.localized(account_options.font.asset_name))
            bg_color = account_options.bg_color
            font_color = account_options.font_color
            break
        end
    end



    api.wait_t(starts - 10)

    local track_title = data.item.name
    local album_title = data.item.album.name
    print(track_title)


    local t = {}
    for k, artist in pairs(data.item.artists) do
        print(artist.name)
        t[#t+1] = artist.name
    end
    local artists = table.concat(t,", ")

    for now in api.frame_between(starts, ends) do
        --local event = event_gen.next()

        api.screen.set_scissor(x1, y1, x2, y2)
        gl.clear(bg_color.r, bg_color.g, bg_color.b, bg_color.a) -- green

        
        local image_size = 640
        
        local margin = (NATIVE_HEIGHT - 640)/2


        cover:draw(margin+x1, margin+y1, margin+x1+image_size, margin+y1+image_size)




        font:write(margin+x1+image_size+100, margin+y1+150, track_title,80,font_color.r,font_color.g,font_color.b,font_color.a)
        font:write(margin+x1+image_size+100, margin+y1+250, artists,50,font_color.r,font_color.g,font_color.b,font_color.a)

        api.screen.set_scissor()
    end

    -- clean up
    print("cleaning up", starts, ends, sys.now())
    api.wait_t(ends + 5)
    print("cleaning up after", starts, ends, sys.now())

    -- fallback_asset:dispose()
    cover:dispose()
    font:dispose()
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
