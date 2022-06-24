--View

--[[
    Everything related to drawing
]]
Item = {}
    --[[
    A simple class that can self-draw
    ]]
 function Item:new(x, y) -- x(int), y(int)
    local obj = {}
    self.__index = self
    obj.x = x or 0
    obj.y = y or 0
    obj.height = 4
    obj.widht = 4
    obj.size_on_pixel = 8

    function obj:on_area(x, y) -- x(int), y(int) --> bool
        if (obj.x <= x and x <= obj.x + obj.size_on_pixel* obj.widht) then
            if (obj.y <= y and y <= obj.y + obj.size_on_pixel* obj.height) then 
                return true
            else 
                return false
            end
        else 
            return false
        end
    end

    setmetatable(obj, self)
    return obj
 end


 Button = Item:new() 
    --[[
    Button is player's interaction with the game, can change the m_cursor
    ]]
 function Button:new(x, y, icon, m_cursor, mouse_obj) -- x(int), y(int), icon(int) --sprite, m_cursor(int) --sprite, mouse_obj(table)
    local obj = Item:new(x, y)   
    self.__index = self
    obj.sprites = Storage_sprite:new()
    obj.icon                = icon or 0     --sprite
    obj.m_cursor            = m_cursor or 0   --sprite
    obj.permanent_x         = obj.x
    obj.permanent_y         = obj.y
    obj.body                = 1             --sprite
    obj.press               = false
    obj.volumetric_sprite   = {
            right_up        = obj.press and 23 or 54,
            right           = obj.press and 22 or 21,
            down_left       = obj.press and 7 or 55,
            down            = obj.press and 6 or 5,
            down_right      = obj.press and 39 or 37
                            }

    function obj:on_press() --> nil
        obj.press = true
        obj.x += 1 --pixel
        obj.y += 1
        sfx(20)
    end

    function obj:on_release() --> nil   
        obj.x = obj.permanent_x --return position
        obj.y = obj.permanent_y
        obj.press = false 
    end

    function obj:press_draw() --> nil
        --[[
            Draw a three-dimensional button depending on its height and width
        ]]
        spr(obj.volumetric_sprite.right_up, obj.x + obj.size_on_pixel* obj.widht, obj.y)
        for i = obj.y + obj.size_on_pixel, obj.y + obj.size_on_pixel* (obj.height - 1), obj.size_on_pixel
            do
                spr(obj.volumetric_sprite.right, obj.x + obj.size_on_pixel* obj.widht, i)
            end
        spr(obj.volumetric_sprite.down_left, obj.x, obj.y + obj.size_on_pixel* obj.height)
        for i = obj.x + obj.size_on_pixel, obj.x + obj.size_on_pixel* (obj.widht - 1), obj.size_on_pixel
            do
                spr(obj.volumetric_sprite.down, i, obj.y  + obj.size_on_pixel* obj.height)
            end
        spr(obj.volumetric_sprite.down_right, obj.x + obj.size_on_pixel* obj.widht, obj.y  + obj.size_on_pixel* obj.height)
    end


    function obj:update() --> nil
        obj.volumetric_sprite   = {
            right_up        = obj.press and 23 or 54,
            right           = obj.press and 22 or 21,
            down_left       = obj.press and 7 or 55,
            down            = obj.press and 6 or 5,
            down_right      = obj.press and 39 or 37
                            }
        obj:on_release()
    end

    function obj:draw() --> nil
        spr(obj.body, obj.x, obj.y, obj.widht, obj.height)
        obj:press_draw()
        spr(obj.icon, obj.x, obj.y, obj.widht, obj.height)
    end

    function obj:cursor(x, y) -- x(int), y(int) --> int
        if obj:on_area(x, y) then
            return m_cursor
        end
    end

    setmetatable(obj, self)
    return obj
 end

Text = Item:new()
--[[
    Text with shadow
]]
function Text:new(x, y) --x(int), y(int)
    local obj = Item:new(x, y)
    self.__index = self
    obj.text = "let's the game begin!!!" --Default text
    obj.half_width = #obj.text *2 -- The width of one character is 4 pixels, it is necessary to divide the number of characters in the text in half


    function obj:set_text(text) --> nil
        print(text)
        obj.text = text
        obj.half_width = #text *2 -- Update half of text width when text is updated
    end
    
    function obj:update() --> nil
        obj.half_width = #obj.text *2 --Updating half the width of the text in case the text is updated directly into an attribute
    end

    function obj:draw() --> nil
        print(obj.text, obj.x - obj.half_width + 1, obj.y + 1, 12) -- Shadow drop 1 and 1 pixel on x and y
        print(obj.text, obj.x - obj.half_width, obj.y, 1)
    end

    setmetatable(obj, self)
    return obj
end

Monitor = Item:new()
--[[
    A monitor that shows the choice of player or opponent
]]
function Monitor:new(x, y, body, icon) --x(int), y(int), body(int) --sprite, icon(int) --sprite
    local obj = Item:new(x, y)
    self.__index = self
    obj.icon = icon or nil --(int) --sprite or nil
    obj.body = body
    obj.size = 4
    obj.height = 60
    obj.widht = 60
    
    function obj:set_icon(icon) --icon(int) --> nil
        obj.icon = icon
    end

    function obj:draw() --> nil
        sspr(
            obj.body*obj.size_on_pixel, -- left_up_point sprite position - x on sprite_sheet
            obj.body*0,                 -- left_up_point sprite position - y
            obj.size*obj.size_on_pixel, -- right_down_point sprite position - x
            obj.size*obj.size_on_pixel, -- right_down_point sprite position - y
            obj.x,                      -- x on display
            obj.y,                      -- y on display
            obj.widht,                  -- widht on display in pixels
            obj.height                  -- widht on display in pixels
            )
        if obj.icon then
            sspr(
                (obj.icon-64)*obj.size_on_pixel, 
                32, 
                obj.size*obj.size_on_pixel, 
                obj.size*obj.size_on_pixel, 
                obj.x, 
                obj.y, 
                obj.widht, 
                obj.height
                )
        end
    end

    setmetatable(obj, self)
    return obj
end

--mouse

Mouse = {}
--[[
    Mouse implemented according to the implementation of 1Srgy, thanks to him
]]
function Mouse:new(m_cursor)
    local obj = {}
    self.__index = self    
    obj.m_cursor = m_cursor or 0
    obj.defeat_cursor = m_cursor
    obj.x = 0
    obj.y = 0
    obj.btns = stat(34)
    obj.btn1 = false
    obj.btn2 = false
    obj.btn3 = false

    function obj:update() --> nil
        obj.x = stat(32) --(int)
        obj.y = stat(33) --(int)
        obj.btns = stat(34)
        obj.btn1 = obj.btns == 1 --Left_mouse button (1 is btn code)
        obj.btn2 = obj.btns == 2 --Right_mouse button (2 is btn code)
        obj.btn3 = obj.btns == 4 --Middle_mouse button  (4 is btn code)
    end

    function obj:draw() --> nil
        spr(obj.m_cursor, obj.x, obj.y)
    end

    setmetatable(obj, self)
    poke(0x5f2d, 1) --Memory magic for use stat(32) and stat(33)
    return obj
 end

Storage_sprite = {}
--[[
sprite data
]]
function Storage_sprite:new()
    local obj = {}
    self.__index = self
    obj.m_cursor = {
        idle        = 53,
        rock        = 48,
        scissors    = 32,
        paper       = 16
    }
    obj.button = 1
    obj.monitor ={
        player  = 8,
        ai      = 12
    }
    obj.icon = {
        rock        = 68,
        scissors    = 64,
        paper       = 72
    }

    setmetatable(obj, self)
    return obj
end

 --Model

 --[[
    Everything related to business logic
 ]]

Game_model = {}
function Game_model:new()
    local obj = {}
    self.__index = self
    obj.spr = Storage_sprite:new()
    obj.choice_ai = 3
    obj.choice_pl = 3
    obj.size = 128

    obj.fps = 0
    obj.fps_last = 0


    function obj:is_win(pl, ai) --bool is victory?
        if pl == "rock" and ai == "scissors" or pl == "scissors" and ai == "paper" or pl == "paper" and ai == "rock"
            then return true
        else return false
        end
    end

    function obj:is_draw(pl, ai) --bool is draw?
        return pl == ai
    end

    function obj:is_lose(pl, ai) --bool is lose?
        if pl == 1 and ai == "rock" or pl == "paper" and ai == "scissors" or pl == "rock" and ai == "paper"
            then return true
        else return false
        end
    end

    function obj:set_icon_on_monitor_pl(entety) --nil
        obj.mon_pl:set_icon(obj.spr.icon[entety] or nil)
    end

    function obj:set_icon_on_monitor_ai(entety) --nil
        obj.mon_ai:set_icon(obj.spr.icon[entety] or nil)
    end

    function obj:start() --nil
        if obj:is_win(obj.choice_pl, obj.choice_ai)
        then obj.label:set_text(rnd({"victory!", "you won!", "you won again", "victory is yours"}))
        elseif obj:is_lose(obj.choice_pl, obj.choice_ai)
        then obj.label:set_text(rnd({"checkmate", "is defeat :(", "you lose", "lucky next time"}))
        elseif obj:is_draw(obj.choice_pl, obj.choice_ai)
        then obj.label:set_text(rnd({"draw", "this game is a draw", "forces are equal!"}))
        end
    end
    
    function obj:do_choice_ai() --random from ai
        obj.choice_ai = rnd({"rock", "paper", "scissors"})
    end

    function obj:do_chioce_pl(value) --value(string)
        obj.choice_pl = value -- -1 < value < 3
    end

    function obj:button_mouse() --> nil
        if obj.mouse.btn1 then
            if obj.fps > obj.fps_last then
                if obj.rock_b:on_area(obj.mouse.x, obj.mouse.y) then
                    obj.rock_b:on_press()
                    obj:do_chioce_pl("rock")
                    obj:do_choice_ai()
                    obj:start()
                    obj.fps_last = obj.fps + 15 --timer
                elseif obj.scissors_b:on_area(obj.mouse.x, obj.mouse.y) then 
                    obj.scissors_b:on_press()
                    obj:do_chioce_pl("scissors")
                    obj:do_choice_ai()
                    obj:start()
                    obj.fps_last = obj.fps + 15
                elseif obj.paper_b:on_area(obj.mouse.x, obj.mouse.y) then
                    obj.paper_b:on_press()
                    obj:do_chioce_pl("paper")
                    obj:do_choice_ai()
                    obj:start()
                    obj.fps_last = obj.fps + 15
                end
            end
        end
    end

    function obj:change_cursor() --> nil
        if obj.rock_b:on_area(obj.mouse.x, obj.mouse.y) then
            obj.mouse.m_cursor = obj.spr.m_cursor["rock"]
        elseif obj.scissors_b:on_area(obj.mouse.x, obj.mouse.y) then
            obj.mouse.m_cursor = obj.spr.m_cursor["scissors"]
        elseif obj.paper_b:on_area(obj.mouse.x, obj.mouse.y) then
            obj.mouse.m_cursor = obj.spr.m_cursor["paper"]
        else obj.mouse.m_cursor = obj.mouse.defeat_cursor
        end
    end

    function obj:init()
        obj.mouse =         Mouse:new(obj.spr.m_cursor["idle"])
        obj.label =         Text:new(obj.size/2, obj.size/2 + 8)
        obj.mon_pl =        Monitor:new(2, 2, 8)
        obj.mon_ai =        Monitor:new(obj.size/2 + 2, 2, 12)
        obj.rock_b =        Button:new(2, obj.size - 38, 68, 0, 48) -- (x, y, icon, name, m_cursor)
        obj.scissors_b =    Button:new(obj.size/2 -18, obj.size - 38, 64, 1, 32)
        obj.paper_b =       Button:new(obj.size -38, obj.size - 38, 72, 2, 16)
        music()
    end

    function obj:update()
        obj.fps += 1
        obj.rock_b:update()
        obj.scissors_b:update()
        obj.paper_b:update()
        obj:set_icon_on_monitor_pl(obj.choice_pl)
        obj:set_icon_on_monitor_ai(obj.choice_ai)
        obj:button_mouse()
        obj.mouse:update()
        obj:change_cursor()
        
    end

    function obj:draw()
        obj.label:draw()
        obj.mon_pl:draw()
        obj.mon_ai:draw()
        obj.rock_b:draw()
        obj.scissors_b:draw()
        obj.paper_b:draw()
        obj.mouse:draw()
    end

    setmetatable(obj, self)
    return obj
end

 Storage_sound = {}
 --[[
    sound data
 ]]
 function Storage_sound:new()
    local obj = {}
    self.__index = self
    obj.m_cursor = {
        idle        = 53,
        rock        = 48,
        scissors    = 32,
        paper       = 16
    }
    obj.button = 1
    obj.monitor ={
        player  = 8,
        ai      = 12
    }
    obj.icon = {
        rock        = 68,
        scissors    = 64,
        paper       = 72
    }

    setmetatable(obj, self)
    return obj
 end