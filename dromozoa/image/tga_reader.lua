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
local image = require "dromozoa.image.image"

local class = {}

function class.new(this)
  if type(this) == "string" then
    this = string_reader(this)
  end
  return {
    this = this;
  }
end

function class:skip(n)
  return self.this:seek("cur", n)
end

function class:read_uint8(n)
  if n == nil then
    n = 1
  end
  return self.this:read(n):byte(1, n)
end

function class:read_uint16()
  return uint16.read(self.this, 1, "<")
end

function class:read_uint(pixel_depth)
  if pixel_depth == 8 then
    return self:read_uint8(n)
  elseif pixel_depth == 16 then
    return self:read_uint16(n)
  end
end

function class:read_pixel(pixel_depth, channels)
  if pixel_depth == 8 then
    return self:read_uint8()
  elseif pixel_depth == 16 then
    local v = self:read_uint16()
    local b = v % 32
    local v = (v - b) / 32
    local g = v % 32
    local v = (v - g) / 32
    local r = v % 32
    local a = (v - r) / 32 * 31
    if channels == 3 then
      return r, g, b
    else
      return r, g, b, a
    end
  elseif pixel_depth == 24 then
    local b, g, r = self:read_uint8(3)
    return r, g, b
  elseif pixel_depth == 32 then
    local b, g, r, a = self:read_uint8(4)
    return r, g, b, a
  end
end

function class:channels(pixel_depth, alpha_channel_bits)
  if pixel_depth == 8 then
    if alpha_channel_bits == 0 then
      return 1, 255
    end
  elseif pixel_depth == 16 then
    if alpha_channel_bits == 0 then
      return 3, 31
    elseif alpha_channel_bits == 1 then
      return 4, 31
    end
  elseif pixel_depth == 24 then
    if alpha_channel_bits == 0 then
      return 3, 255
    end
  elseif pixel_depth == 32 then
    -- netpbm does not set alpha_channel_bits
    if alpha_channel_bits == 0 or alpha_channel_bits == 8 then
      return 4, 255
    end
  else
    error("unsupported pixel_depth")
  end
  error("unsupported image_descriptor (alpha_channel_bits)")
end

function class:apply()
  local this = self.this

  local id_length = self:read_uint8()

  local color_map_type = self:read_uint8()
  if color_map_type > 1 then
    error("unsupported color_map_type")
  end

  local image_type = self:read_uint8()
  local run_length_encoded = false
  if image_type > 8 then
    run_length_encoded = true
    image_type = image_type - 8
  end
  if image_type < 1 or image_type > 3 then
    error("unsupported image_type")
  end

  local color_map_first_entry_index = self:read_uint16()
  local color_map_length = self:read_uint16()
  local color_map_entry_size = self:read_uint8()

  -- x-origin of image, y-origin of image
  self:skip(4)

  local image_width = self:read_uint16()
  local image_height = self:read_uint16()
  local pixel_depth = self:read_uint8()

  local image_descriptor = self:read_uint8()
  local alpha_channel_bits = image_descriptor % 16
  image_descriptor = (image_descriptor - alpha_channel_bits) / 16
  local right_to_left = image_descriptor % 2
  image_descriptor = (image_descriptor - right_to_left) / 2
  local top_to_bottom = image_descriptor % 2
  image_descriptor = (image_descriptor - top_to_bottom) / 2
  if image_descriptor ~= 0 then
    error("invalid image_descriptor")
  end
  if right_to_left == 1 then
    error("unsupported image_descriptor (right_to_left)")
  end

  -- image id
  if id_length > 0 then
    self:skip(id_length)
  end

  local pixels = sequence()
  local n = image_width * image_height
  local channels
  local max

  if color_map_type == 0 then
    channels, max = self:channels(pixel_depth, alpha_channel_bits)
    if run_length_encoded then
      local i = 1
      while i <= n do
        local header = self:read_uint8()
        if header < 128 then
          -- raw packet
          local length = header + 1
          for j = 1, length do
            pixels:push(self:read_pixel(pixel_depth, channels))
          end
          i = i + length
        else
          -- run length packet
          local length = header - 127
          local a, b, c, d = self:read_pixel(pixel_depth, channels)
          for j = 1, length do
            pixels:push(a, b, c, d)
          end
          i = i + length
        end
      end
    else
      for i = 1, n do
        pixels:push(self:read_pixel(pixel_depth))
      end
    end
  else
    if pixel_depth ~= 8 and pixel_depth ~= 16 then
      error("unsupported pixel_depth")
    end
    channels, max = self:channels(color_map_entry_size, alpha_channel_bits)
    local color_map = {}
    for i = 0, color_map_length - 1 do
      color_map[i + color_map_first_entry_index] = { self:read_pixel(color_map_entry_size, channels) }
    end
    if run_length_encoded then
      local i = 1
      while i <= n do
        local header = self:read_uint8()
        if header < 128 then
          -- raw packet
          local length = header + 1
          for j = 1, length do
            pixels:copy(color_map[self:read_uint(pixel_depth)])
          end
          i = i + length
        else
          -- run length packet
          local length = header - 127
          local v = color_map[self:read_uint(pixel_depth)]
          for j = 1, length do
            pixels:copy(v)
          end
          i = i + length
        end
      end
    else
      for i = 1, n do
        pixels:copy(color_map[self:read_uint(pixel_depth)])
      end
    end
  end

  assert(#pixels == n * channels)

  if top_to_bottom > 0 then
    local m = image_width * channels
    for y = 1, image_height / 2 do
      local a = m * (y - 1)
      local b = m * (image_height - y)
      for x = 1, m do
        local i = x + a
        local j = x + b
        pixels[i], pixels[j] = pixels[j], pixels[i]
      end
    end
  end

  local header = linked_hash_table()
  header.width = image_width
  header.height = image_height
  header.channels = channels
  header.min = 0
  header.max = max
  return image(header, pixels)
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this)
    return setmetatable(class.new(this), metatable)
  end;
})
