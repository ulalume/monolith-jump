local INPUT_UP    = 'up'
local INPUT_LEFT  = 'left'
local INPUT_DOWN  = 'down'
local INPUT_RIGHT = 'right'
local INPUT_A     = 'a'
local INPUT_B     = 'b'

return {
  -- user1
  {
    type    = 'joystick',
    mapping = {
      [INPUT_UP]    = { index = 1, type = 'button' },
      [INPUT_LEFT]  = { index = 2, type = 'button' },
      [INPUT_DOWN]  = { index = 4, type = 'button' },
      [INPUT_RIGHT] = { index = 3, type = 'button' },
      [INPUT_A]     = { index = 5, type = 'button' },
      [INPUT_B]     = { index = 6, type = 'button' },
    },
    options = {
      guid = '',
      name = 'Unknown MONOLITH CONTROLLER#1',
    },
  },
  -- user2
  {
    type    = 'joystick',
    mapping = {
      [INPUT_UP]    = { index = 1, type = 'button' },
      [INPUT_LEFT]  = { index = 2, type = 'button' },
      [INPUT_DOWN]  = { index = 4, type = 'button' },
      [INPUT_RIGHT] = { index = 3, type = 'button' },
      [INPUT_A]     = { index = 5, type = 'button' },
      [INPUT_B]     = { index = 6, type = 'button' },
    },
    options = {
      guid = '',
      name = 'Unknown MONOLITH CONTROLLER#2',
    },
  },
  -- user3
  {
    type    = 'joystick',
    mapping = {
      [INPUT_UP]    = { index = 1, type = 'button' },
      [INPUT_LEFT]  = { index = 2, type = 'button' },
      [INPUT_DOWN]  = { index = 4, type = 'button' },
      [INPUT_RIGHT] = { index = 3, type = 'button' },
      [INPUT_A]     = { index = 5, type = 'button' },
      [INPUT_B]     = { index = 6, type = 'button' },
    },
    options = {
      guid = '',
      name = 'Unknown MONOLITH CONTROLLER#3',
    },
  },
  -- user4
  {
    type    = 'joystick',
    mapping = {
      [INPUT_UP]    = { index = 1, type = 'button' },
      [INPUT_LEFT]  = { index = 2, type = 'button' },
      [INPUT_DOWN]  = { index = 4, type = 'button' },
      [INPUT_RIGHT] = { index = 3, type = 'button' },
      [INPUT_A]     = { index = 5, type = 'button' },
      [INPUT_B]     = { index = 6, type = 'button' },
    },
    options = {
      guid = '',
      name = 'Unknown MONOLITH CONTROLLER#4',
    },
  },
--[[
  -- user3
  {
    type    = 'joystick',
      mapping = {
          [INPUT_UP]    = { index = 2, type = 'axis', reverse = false },
          [INPUT_DOWN]    = { index = 2, type = 'axis', reverse = true },
          [INPUT_LEFT]    = { index = 1, type = 'axis', reverse = true },
          [INPUT_RIGHT]    = { index = 1, type = 'axis', reverse = false },
          [INPUT_A]     = { index = 1, type = 'button' },
          [INPUT_B]     = { index = 2, type = 'button' },
      },
    options = {
      guid = '03000000c82d00000130000011010000',
      name = '8Bitdo SF30 Wireless Controller',
    },
  },
  -- user4
  {
      type    = 'joystick',
      mapping = {
          [INPUT_UP]    = { index = 2, type = 'axis', reverse = false },
          [INPUT_DOWN]    = { index = 2, type = 'axis', reverse = true },
          [INPUT_LEFT]    = { index = 1, type = 'axis', reverse = true },
          [INPUT_RIGHT]    = { index = 1, type = 'axis', reverse = false },
          [INPUT_A]     = { index = 1, type = 'button' },
          [INPUT_B]     = { index = 2, type = 'button' },
      },
      options = {
          guid = '03000000730700000601000010010000',
          name = 'USB  GAMEPAD        ',
      },
  },
--]]
}
