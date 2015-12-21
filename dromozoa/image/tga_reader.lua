-- Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
--
-- This file is part of dromozoa-image.
--
-- dromozoa-image is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dromozoa-image is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-image.  If not, see <http://www.gnu.org/licenses/>.

local linked_hash_table = require "dromozoa.commons.linked_hash_table"
local sequence = require "dromozoa.commons.sequence"
local string_reader = require "dromozoa.commons.string_reader"
local uint16 = require "dromozoa.commons.uint16"
local unpack = require "dromozoa.commons.unpack"
local image = require "dromozoa.image.image"

local class = {}

function class.new(this)
  if type(this) == "string" then
    this = string_reader(this)
  end
  return {
    this = this;
    debug = true;
  }
end

function class:read_uint8(n)
  if n == nil then
    n = 1
  end
  return self.this:read(n):byte(1, n)
end

function class:read_uint16(n)
  return uint16.read(self.this, n, "<")
end

function class:read_uint(bit_depth, n)
  if bit_depth == 8 then
    return self:read_uint8(n)
  elseif bit_depth == 16 then
    return self:read_uint16(n)
  end
end

function class:read_pixel(pixel_depth)
  if pixel_depth == 8 then
    return self:read_uint8()
  elseif pixel_depth == 24 then
    local b, g, r = self:read_uint8(3)
    return r, g, b
  elseif pixel_depth == 32 then
    local b, g, r, a = self:read_uint8(4)
    return r, g, b, a
  end
end

function class:apply()
  local this = self.this

  local id_length, color_map_type, image_type = self:read_uint8(3)

  if color_map_type > 1 then
    error("unsupported color_map_type")
  end

  -- 0: no image data
  -- 1: uncompressed, color-mapped
  -- 2: uncompressed, true-color
  -- 3: uncompressed, black-and-white
  -- 9: run-length encoded, color-mapped
  -- 10: run-length encoded, true-color
  -- 11: run-length encoded, black-and-white
  local run_length_encoded = false
  if image_type > 8 then
    run_length_encoded = true
    image_type = image_type - 8
  end
  if image_type < 1 or image_type > 3 then
    error("unsupported image_type")
  end

  local first_entry_index, color_map_length = self:read_uint16(2)
  local color_map_entry_size = self:read_uint8()
  local x_origin, y_origin, image_width, image_height = self:read_uint16(4)
  local pixel_depth, image_descriptor = self:read_uint8(2)

  local alpha_channel_bits = image_descriptor % 16
  image_descriptor = (image_descriptor - alpha_channel_bits) / 16
  local right = image_descriptor % 2
  image_descriptor = (image_descriptor - right) / 2
  local top = image_descriptor % 2
  image_descriptor = (image_descriptor - top) / 2
  if image_descriptor > 0 then
    error("invalid image_descriptor")
  end
  if right == 1 then
    error("unsupported image_origin")
  end

  if id_length > 0 then
    this:seek("cur", id_length)
  end

  local pixels = sequence()
  local n = image_width * image_height
  local channels

  if color_map_type == 0 then
    if pixel_depth ~= 8 and pixel_depth ~= 24 and pixel_depth ~= 32 then
      error("unsupported pixel_depth")
    end
    channels = pixel_depth / 8
    if run_length_encoded then
      local i = 0
      while i < n do
        local header = self:read_uint8()
        if header < 128 then
          -- raw packet
          local length = header + 1
          for j = 1, length do
            pixels:push(self:read_pixel(pixel_depth))
          end
          i = i + length
        else
          -- run length packet
          local length = header - 127
          local a, b, c, d = self:read_pixel(pixel_depth)
          for j = 1, length do
            pixels:push(a, b, c, d)
          end
          i = i + length
        end
      end
    else
      for i = 0, n - 1 do
        pixels:push(self:read_pixel(pixel_depth))
      end
    end
  elseif color_map_type == 1 then
    if color_map_entry_size ~= 8 and color_map_entry_size ~= 24 and color_map_entry_size ~= 32 then
      error("unsupported color_map_entry_size")
    end
    channels = color_map_entry_size / 8
    local color_map = {}
    for i = 0, color_map_length - 1 do
      color_map[i + first_entry_index] = { self:read_pixel(color_map_entry_size) }
    end
    if pixel_depth ~= 8 and pixel_depth ~= 16 then
      error("unsupported pixel_depth")
    end
    if run_length_encoded then
      local i = 0
      while i < n do
        local header = self:read_uint8()
        if header < 128 then
          -- raw packet
          local length = header + 1
          for j = 1, length do
            local v = self:read_uint(pixel_depth)
            pixels:push(unpack(color_map[v]))
          end
          i = i + length
        else
          -- run length packet
          local length = header - 127
          local v = self:read_uint(pixel_depth)
          local a, b, c, d = unpack(color_map[v])
          for j = 1, length do
            pixels:push(a, b, c, d)
          end
          i = i + length
        end
      end
    else
      for i = 0, n - 1 do
        local v = self:read_uint(pixel_depth)
        pixels:push(unpack(color_map[v]))
      end
    end
  end

  local header = linked_hash_table()
  header.width = image_width
  header.height = image_height
  header.channels = channels
  header.min = 0
  header.max = 255
  local img = image(header, pixels)
  if top == 0 then
    return img:swap_vertical()
  else
    return img
  end
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this)
    return setmetatable(class.new(this), metatable)
  end;
})
