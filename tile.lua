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
    data = spotify_json
end




function M.task(starts, ends, config, x1, y1, x2, y2) -- render child node


    local function linearRGB(c)
        if (c <= 0.03928) then
            return c/12.92
        else
            return ((c+0.055)/1.055)^2.4
        end
    end

    local function luminance(r, g, b)
        return 0.2126 * linearRGB(r) + 0.7152 * linearRGB(g) + 0.0722 * linearRGB(b)
    end

    print("start en end", starts, ends)
    print("SPOTIFY: account_name from config", config.account_name_tile)

    local width = x2 - x1
    local height = y2 - y1

    local spotify_logo

    local cover
    local font
    local fallback_asset
    local bg_color
    local font_color


    local spotify_logo_ratio = 2326/704
    local logo_size_height = height*0.075

    local image_size = height/2
        
    local margin_x = width*0.075 + x1
    local margin_y = (height - image_size)/2 + y1


    local margin_x_content = margin_x+image_size+width*0.05
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

            if account_options.use_artwork_color then
                bg_color = {
                    ["r"] = data["cover_image_color"][1]/255,
                    ["g"] = data["cover_image_color"][2]/255,
                    ["b"] = data["cover_image_color"][3]/255,
                    ["a"] = 1
                }

                if luminance(bg_color.r, bg_color.g, bg_color.b) > 0.179  then -- black
                    font_color ={
                        ["r"] = 0,
                        ["g"] = 0,
                        ["b"] = 0,
                        ["a"] = 1
                    }
                    spotify_logo = resource.load_image {
                        file = api.localized("Spotify_Logo_RGB_Black.png"),
                        mipmap = true
                    }
                else -- white
                    font_color ={
                        ["r"] = 1,
                        ["g"] = 1,
                        ["b"] = 1,
                        ["a"] = 1
                    }
                
                    spotify_logo = resource.load_image {
                        file = api.localized("Spotify_Logo_RGB_White.png"),
                        mipmap = true
                    }
                end
            else --fallback option
                bg_color = account_options.bg_color
                font_color = account_options.font_color

                spotify_logo = resource.load_image {
                    file = api.localized("Spotify_Logo_RGB_White.png"),
                    mipmap = true
                }
            end
            
            print("bg color:",bg_color.r, bg_color.g, bg_color.b)
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


    local font_size = math.floor(height*0.075)
    for now in api.frame_between(starts, ends) do
        --local event = event_gen.next()

        api.screen.set_scissor(x1, y1, x2, y2)

        gl.clear(bg_color.r, bg_color.g, bg_color.b, bg_color.a)

        cover:draw(margin_x, margin_y, margin_x+image_size, margin_y+image_size)

        spotify_logo:draw(margin_x_content, margin_y, margin_x_content+logo_size_height*spotify_logo_ratio, margin_y+logo_size_height)
        font:write(margin_x_content, margin_y+logo_size_height+height*0.1, track_title,font_size,font_color.r,font_color.g,font_color.b,font_color.a)
        font:write(margin_x_content, margin_y+logo_size_height+height*0.1+font_size+font_size*0.3, artists,font_size*0.6,font_color.r,font_color.g,font_color.b,font_color.a)

        api.screen.set_scissor()
    end

    -- clean up
    print("cleaning up", starts, ends, sys.now())
    api.wait_t(ends + 5)
    print("cleaning up after", starts, ends, sys.now())

    -- -- fallback_asset:dispose()
    spotify_logo:dispose()
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
