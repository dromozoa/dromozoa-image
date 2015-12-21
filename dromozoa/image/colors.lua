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

local class = {}

function class.RGB_to_YCbCr(R, G, B)
  local Y = 0.299 * R + 0.587 * G + 0.114 * B
  local Cb = -0.168736 * R - 0.331264 * G + 0.5 * B
  local Cr = 0.5 * R - 0.418688 * G - 0.081312 * B
  return Y, Cb, Cr
end

function class.RGB_to_gray(R, G, B)
  return 0.299 * R + 0.587 * G + 0.114 * B
end

function class.YCbCr_to_RGB(Y, Cb, Cr)
  local R = Y + 1.402 * Cr
  local G = Y - 0.334136 * Cb - 0.714136 * Cr
  local B = Y + 1.772 * Cb
  return R, G, B
end

function class.gray_to_RGB(Y)
  return Y, Y, Y
end

return class
