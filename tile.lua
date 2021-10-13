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

local json_data
function M.updated_spotify_json(spotify_json) json_data = spotify_json end

function M.task(starts, ends, config, x1, y1, x2, y2) -- render child node

    local function linearRGB(c)
        if (c <= 0.03928) then
            return c / 12.92
        else
            return ((c + 0.055) / 1.055) ^ 2.4
        end
    end

    local function luminance(r, g, b)
        return 0.2126 * linearRGB(r) + 0.7152 * linearRGB(g) + 0.0722 *
                   linearRGB(b)
    end

    print("start en end", starts, ends)
    print("SPOTIFY: account_name from config", config.account_name_tile)

    local width = x2 - x1
    local height = y2 - y1

    local spotify_logo

    local data

    local cover
    local font
    local fallback_asset
    local bg_color
    local font_color

    local logo_size_height
    local image_size
    local margin_x
    local font_size
    local content_margin_y

    local track_title
    local artists

    local margin_x_content
    local spotify_logo_ratio = 2326 / 704

    if config.widget then
        logo_size_height = height * 0.2
        image_size = height * 0.8
        font_size = math.floor(height * 0.2)
        margin_x = x1 + height * 0.1
        content_margin_y = 0
    else -- full screen
        logo_size_height = height * 0.05
        image_size = height / 2
        font_size = math.floor(height * 0.075)
        margin_x = x1 + width * 0.075
        content_margin_y = height * 0.15
    end

    local margin_y = (height - image_size) / 2 + y1
    margin_x_content = margin_x + image_size + width * 0.05

    local no_data = false

    for key, account_options in pairs(accounts) do
        print(account_options.account_name)
        if account_options.account_name == config.account_name_tile then
            -- if not pcall(function()
            --     local x = data[config.account_name_tile]
            -- end) then -- data doesn't exist (probably offline)
            --     no_data = true
            --     bg_color = account_options.bg_color
            -- else -- no error
            data = json_data[config.account_name_tile]

            -- fallback_asset =
            --     resource.load_image {
            --     file = api.localized(account_options.fallback_asset.asset_name),
            --     mipmap = true
            -- }

            font = resource.load_font(api.localized(
                                          account_options.font.asset_name))

            if config.widget then
                cover = resource.load_image {
                    file = api.localized(data.cover_image_64),
                    mipmap = true
                }
            else
                cover = resource.load_image {
                    file = api.localized(data.cover_image_640),
                    mipmap = true
                }
            end

            track_title = data.item.name
            -- local album_title = data.item.album.name
            print(track_title)

            local t = {}
            for k, artist in pairs(data.item.artists) do
                print(artist.name)
                t[#t + 1] = artist.name
            end
            artists = table.concat(t, ", ")

            if not config.widget_use_artwork_color and config.widget then
                -- TODO fix transparancy
                bg_color = {["r"] = 0, ["g"] = 0, ["b"] = 0, ["a"] = 0.25}
                font_color = {["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 1}

                spotify_logo = resource.load_image {
                    file = api.localized("Spotify_Logo_RGB_White.png"),
                    mipmap = true
                }
            else
                if account_options.use_artwork_color then
                    bg_color = {
                        ["r"] = data["cover_image_color"][1] / 255,
                        ["g"] = data["cover_image_color"][2] / 255,
                        ["b"] = data["cover_image_color"][3] / 255,
                        ["a"] = 1
                    }

                    if luminance(bg_color.r, bg_color.g, bg_color.b) > 0.179 then -- black
                        font_color = {
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
                        font_color = {
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
                else -- fallback option
                    bg_color = account_options.bg_color
                    font_color = account_options.font_color

                    spotify_logo = resource.load_image {
                        file = api.localized("Spotify_Logo_RGB_White.png"),
                        mipmap = true
                    }
                end
            end

            print("bg color:", bg_color.r, bg_color.g, bg_color.b)
            break

        end
    end

    api.wait_t(starts - 10)

    if no_data then
        gl.clear(bg_color.r, bg_color.g, bg_color.b, bg_color.a)
    else

        for now in api.frame_between(starts, ends) do
            -- local event = event_gen.next()

            api.screen.set_scissor(x1, y1, x2, y2)

            gl.clear(bg_color.r, bg_color.g, bg_color.b, bg_color.a)
            cover:draw(margin_x, margin_y, margin_x + image_size,
                       margin_y + image_size)

            spotify_logo:draw(margin_x_content, margin_y + content_margin_y,
                              margin_x_content + logo_size_height *
                                  spotify_logo_ratio,
                              margin_y + content_margin_y + logo_size_height)
            font:write(margin_x_content, margin_y + content_margin_y +
                           logo_size_height + font_size * 0.3, track_title,
                       font_size, font_color.r, font_color.g, font_color.b,
                       font_color.a)
            font:write(margin_x_content,
                       margin_y + content_margin_y + logo_size_height +
                           font_size * 0.3 + font_size + font_size * 0.3,
                       artists, font_size * 0.6, font_color.r, font_color.g,
                       font_color.b, font_color.a)

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
end

function M.unload() print "sub module is unloaded" end

function M.content_update(name) print("sub module content update", name) end

function M.content_remove(name) print("sub module content delete", name) end

return M
