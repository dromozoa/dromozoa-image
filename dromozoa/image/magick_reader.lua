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

local sequence = require "dromozoa.commons.sequence"
local shell = require "dromozoa.commons.shell"
local string_reader = require "dromozoa.commons.string_reader"
local write_file = require "dromozoa.commons.write_file"
local pnm_reader = require "dromozoa.image.pnm_reader"

local class = {}

class.support = shell.exec("convert -version >/dev/null 2>&1")

function class.new(this)
  if type(this) == "string" then
    this = string_reader(this)
  end
  return {
    this = this;
  }
end

function class:apply()
  local this = self.this

  local commands = sequence():push("convert")

  local tmpin = os.tmpname()
  assert(write_file(tmpin, this:read("*a")))
  commands:push(shell.quote(tmpin))

  local tmpout = os.tmpname()
  commands:push(shell.quote("pam:" .. tmpout))

  local command = commands:concat(" ") -- .. " >/dev/null 2>&1"
  local result, what, code = shell.exec(command)

  os.remove(tmpin)
  if result == nil then
    os.remove(tmpout)
    return nil, what, code
  else
    local handle = assert(io.open(tmpout, "rb"))
    os.remove(tmpout)
    return pnm_reader(handle):apply()
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
