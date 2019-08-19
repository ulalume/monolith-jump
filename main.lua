package.path = package.path .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?.lua'
package.path = package.path .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?/init.lua'
package.cpath = package.cpath .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?.so'

local monolith = require('monolith.core')
  .new({ windowScale = 4.0, ledColorBits = 2 })

local math2 = require('util.math2')
local mycolor = require('graphics.color')
local shutdownkey = require "util.shutdownkey":new(monolith.input)
local HC = require('hardoncollider')
local suit = require('suit')
local anim8 = require 'anim8'
local images = nil
local slider = {value = 0.5, min = 0, max = 2}
local checkbox_collision = { text = "collision", checked = false }
local players = {}
local grounds = {}
local resetCount = 0


function loadPlayerImages(filepath, colors)
  local srcImageData = love.image.newImageData(filepath)
  local images = {}
  for i, color in ipairs(colors) do
    local imageData = nil
    if i == 1 then
      imageData = srcImageData
    else
      print(colors[1], colors[i])
      imageData = mycolor.swapImageDataColor(
        srcImageData,
        colors[1],
        colors[i])
    end
    table.insert(images, love.graphics.newImage(imageData))
  end
  return images
end

--------------------------------------------------
local Ground = {}
function Ground.new(x, y, width, height)
  local object = {
    collision = HC.rectangle(x, y, width, height),
    offset = math.random() * math.pi * 2,
    value = 1.0,
    registered = true
  }

  return setmetatable(
    object,
    { __index = Ground })
end

function Ground:update(dt)
  self.value = math.sin(monolith:getFrameCount() * 0.01 + self.offset)
  if self.value > 0.5 and not self.registered then
    HC.register(self.collision)
    self.registered = true
  elseif self.value < 0.5 and self.registered then
    HC.remove(self.collision)
    self.registered = false
  end
end

function Ground:draw()
  love.graphics.setColor(mycolor.withGray(self.value):rgb())
  self.collision:draw('fill')
end

function Ground:destroy()
  HC.remove(self.collision)
end

--------------------------------------------------
function move(x, y, dx, dy, area)
  if area == 'bottom' then
    return x + dx, y + dy
  elseif area == 'top' then
    return x - dx, y - dy
  elseif area == 'left' then
    return x - dy, y + dx
  elseif area == 'right' then
    return x + dy, y - dx
  end
  return x, y
end

local Player = {}
function Player.new(index)
  local image = images[index]
  local g = anim8.newGrid(
    10,
    10,
    image:getWidth(),
    image:getHeight())
  local default_position = {}
  if index == 1 then
    default_position.x = 64
    default_position.y = 128 - 32
  elseif index == 2 then
    default_position.x = 64
    default_position.y = 32
  elseif index == 3 then
    default_position.x = 128 - 32
    default_position.y = 64
  else
    default_position.x = 32
    default_position.y = 64
  end
  local object = {
    index = index,
    default_position = default_position,
    x = default_position.x,
    y = default_position.y,
    vel_x = 0,
    vel_y = 0,
    rad = 0,
    jump_count = 0,
    image = image,
    current_animation = nil,
    animations = {
      idle = anim8.newAnimation(g('1-2', 1), 0.2),
      walk = anim8.newAnimation(g('3-4', 1), 0.1),
      death = anim8.newAnimation(g('5-9', 1), 0.1, 'pauseAtEnd'),
    },
    direction = 1,
    area = 'bottom',
    collision = HC.rectangle(0, 0, 6, 8),
    collision_head = HC.rectangle(0, 0, 2, 1),
    collision_legs = HC.rectangle(0, 0, 2, 1),
    is_dead = false,
  }
  object.collision.type = 'body'
  object.collision.player = object
  object.collision_head.type = 'head'
  object.collision_head.player = object
  object.collision_legs.type = 'legs'
  object.collision_legs.player = object
  return setmetatable(
    object,
    { __index = Player })
end


function Player:update(dt)
  if self.is_dead then
    self.current_animation:update(dt)
    return
  end
  if self.current_animation ~= self.animations['death'] then
    if monolith.input:getButton(self.index, 'left') then
      self.current_animation = self.animations['walk']
      self.vel_x = math2.lerp(self.vel_x, -1, 0.9)
      self.direction = -1
    elseif monolith.input:getButton(self.index, 'right') then
      self.current_animation = self.animations['walk']
      self.vel_x = math2.lerp(self.vel_x, 1, 0.9)
      self.direction = 1
    else
      self.current_animation = self.animations['idle']
      self.vel_x = math2.lerp(self.vel_x, 0, 0.9)
    end
    if monolith.input:getButtonDown(self.index, 'a')
      and self.jump_count < 1 then
      self.vel_y = -2
      self.jump_count = self.jump_count + 1
      musicSystem:playAllPlayer("jump")
    end
  end

  -- gravity
  local new_rad = math.atan2(self.y - 64, self.x - 64)
  while new_rad > math.pi * 2 do
    new_rad = new_rad - (math.pi * 2)
  end
  while new_rad < 0 do
    new_rad = new_rad + (math.pi * 2)
  end

  local new_area = nil
  if new_rad > (math.pi * 1 / 4) and new_rad < (math.pi * 3 / 4) then
    new_area = 'bottom'
  elseif new_rad > (math.pi * 3 / 4) and new_rad < (math.pi * 5 / 4) then
    new_area = 'left'
  elseif new_rad > (math.pi * 5 / 4) and new_rad < (math.pi * 7 / 4) then
    new_area = 'top'
  else
    new_area = 'right'
  end

  if new_area == 'bottom' then
    new_rad = math.pi * 0.0
  elseif new_area == 'left' then
    new_rad = math.pi * 0.5
  elseif new_area == 'top' then
    new_rad = math.pi * 1.0
  elseif new_area == 'right' then
    new_rad = math.pi * 1.5
  end
  if math.abs(self.rad - new_rad) > math.pi then
    if new_rad < self.rad then
      new_rad = new_rad + math.pi * 2
    else
      new_rad = new_rad - math.pi * 2
    end
  end
  self.collision:setRotation(new_rad)
  self.collision_head:setRotation(new_rad)
  self.collision_legs:setRotation(new_rad)
  self.rad = math2.lerp(self.rad, new_rad, 0.85)

  if self.area ~= new_area then
    local v = 1
    if self.vel_x < 0 then
      v = -1
    end
    local temp = vel_y
    self.vel_y = self.vel_x * v
    self.vel_x = self.vel_y * v
    self.area = new_area
  end

  self.vel_y = self.vel_y * 0.95 + 1.0 * 0.05
  self.x, self.y = move(
    self.x,
    self.y,
    self.vel_x,
    self.vel_y,
    self.area)
  self.collision:moveTo(self.x, self.y)

  local rad = self.collision_head:rotation() - math.pi * 0.5
  self.collision_head:moveTo(
    self.x + math.cos(rad) * 4,
    self.y + math.sin(rad) * 4)
  rad = self.collision_head:rotation() + math.pi * 0.5
  self.collision_legs:moveTo(
    self.x + math.cos(rad) * 4,
    self.y + math.sin(rad) * 4)

  for shape, delta in pairs(HC.collisions(self.collision)) do
    if shape.player ~= self then
      self.x = self.x + delta.x
      self.y = self.y + delta.y
    end
  end
  for shape, delta in pairs(HC.collisions(self.collision_legs)) do
    if shape.player ~= self then
      if shape.player ~= nil and shape.player ~= self then
        shape.player:kill()
        self.vel_y = -2
      end
      self.jump_count = 0
    end
  end

  self.current_animation:update(dt)
end

function Player:draw()
  love.graphics.setColor(255, 255, 255)
  self.current_animation:draw(
    self.image,
    math.floor(self.x),
    math.floor(self.y),
    self.rad,
    self.direction,
    1,
    5,
    5)
  if checkbox_collision.checked and not self.is_dead then
    self.collision:draw('line')
    love.graphics.setColor(255, 0, 255)
    self.collision_head:draw('fill')
    love.graphics.setColor(0, 255, 255)
    self.collision_legs:draw('fill')
  end
end

function Player:kill()
  if self.current_animation == self.animations['death'] then
    return
  end
  self.animations['death']:gotoFrame(1)
  self.animations['death']:resume()
  self.current_animation = self.animations['death']
  HC.remove(self.collision)
  HC.remove(self.collision_head)
  HC.remove(self.collision_legs)

  musicSystem:playAllPlayer("death")
  self.is_dead = true
end

function Player:destroy()
  HC.remove(self.collision)
end

--------------------------------------------------
local wallThickness = 1
local walls = {
  -- top
  HC.rectangle(0, 0, monolith:getWidth() - 1, wallThickness),
  -- bottom
  HC.rectangle(0, monolith:getHeight() - 1, monolith:getWidth(), wallThickness),
  -- left
  HC.rectangle(1, 0, wallThickness, monolith:getHeight()),
  -- right
  HC.rectangle(monolith:getWidth() - 1, 0, wallThickness, monolith:getHeight()),
}

function restart()
  for _, player in ipairs(players) do
    player:destroy()
  end
  for _, ground in ipairs(grounds) do
    ground:destroy()
  end

  for i, b in ipairs(activeControllers) do
    if b then
      table.insert(players, Player.new(i))
    end
  end

  grounds = {
    Ground.new(24, 12, 12, 2),
    Ground.new(48, 12, 12, 2),
    Ground.new(72, 12, 12, 2),
    Ground.new(96, 12, 12, 2),

    Ground.new(24 + 12, 12 + 12, 12, 2),
    Ground.new(48 + 12, 12 + 12, 12, 2),
    Ground.new(72 + 12, 12 + 12, 12, 2),

    Ground.new(12, 24, 2, 12),
    Ground.new(12, 48, 2, 12),
    Ground.new(12, 72, 2, 12),
    Ground.new(12, 96, 2, 12),

    Ground.new(12 + 12, 24 + 12, 2, 12),
    Ground.new(12 + 12, 48 + 12, 2, 12),
    Ground.new(12 + 12, 72 + 12, 2, 12),

    Ground.new(24, 112, 12, 2),
    Ground.new(48, 112, 12, 2),
    Ground.new(72, 112, 12, 2),
    Ground.new(96, 112, 12, 2),

    Ground.new(48 - 12, 112 - 12, 12, 2),
    Ground.new(72 - 12, 112 - 12, 12, 2),
    Ground.new(96 - 12, 112 - 12, 12, 2),

    Ground.new(112, 24, 2, 12),
    Ground.new(112, 48, 2, 12),
    Ground.new(112, 72, 2, 12),
    Ground.new(112, 96, 2, 12),

    Ground.new(112 - 12, 48 - 12, 2, 12),
    Ground.new(112 - 12, 72 - 12, 2, 12),
    Ground.new(112 - 12, 96 - 12, 2, 12),
  }
end

--------------------------------------------------
function love.load(arg)
  activeControllers = require "util.parse_arguments" (arg).activeControllers
  if require "util.osname" == "Linux" then
    for i,inp in ipairs(require "config.linux_input_settings") do monolith.input:setUserSetting(i, inp) end
  else
    for i,inp in ipairs(require "config.input_settings") do
      monolith.input:setUserSetting(i, inp)
    end
  end

  local devices, musicPathTable, priorityTable = unpack(require "config.music_data")
  musicSystem = require("music.music_system"):new(activeControllers, devices, musicPathTable, priorityTable)

  love.graphics.setDefaultFilter('nearest', 'nearest', 1)
  love.graphics.setLineStyle('rough')
  images = loadPlayerImages(
    'assets/player.png',
    {
      mycolor.withRgbHex(0x99, 0xe5, 0x50),
      mycolor.withRgbHex(0xF2, 0x7b, 0xd3),
      mycolor.withRgbHex(0x7e, 0xe5, 0xf8),
      mycolor.withRgbHex(0xec, 0xf2, 0x84),
    }
    )
  restart()
end

--------------------------------------------------
function love.update(dt)
  musicSystem:update(dt)
  shutdownkey:update(dt)

  suit.layout:reset(30, 30)
  if suit.Button("Restart", suit.layout:row(100, 20)).hit then
    restart()
  end
  suit.Checkbox(checkbox_collision, suit.layout:row())
  suit.Slider(slider, suit.layout:row())

  local aliveCount = 0
  for _, player in ipairs(players) do
    player:update(dt)
    if not player.is_dead then
      aliveCount = aliveCount + 1
    end
  end
  for _, ground in ipairs(grounds) do
    ground:update(dt)
  end

  if aliveCount <= 1 then
    resetCount = resetCount + 1
  end
  if resetCount > 300 then
    love.event.quit(0)
  end

end

--------------------------------------------------
function love.draw()
  monolith:beginDraw()

  -- draw collision
  love.graphics.setColor(255, 255, 255)
  for _, ground in ipairs(grounds) do
    ground:draw()
  end
  for _, player in ipairs(players) do
    player:draw()
  end
  monolith:endDraw()
  suit.draw()
end

--------------------------------------------------
function love.quit()
  musicSystem:gc()
  require "util.open_launcher"()
end
