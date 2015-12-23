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
local read_file = require "dromozoa.commons.read_file"

local class = {}

class.support = shell.exec("convert -version >/dev/null 2>&1")

function class.new(this, that)
  return {
    this = this;
    that = that;
  }
end

function class:apply(format)
  local this = self.this
  local that = self.that

  local commands = sequence():push("convert")

  local tmpin = os.tmpname()
  this:write_pam(assert(io.open(tmpin, "wb"))):close()
  commands:push(shell.quote(tmpin))

  local tmpout = os.tmpname()
  commands:push(shell.quote(format .. ":" .. tmpout))

  local command = commands:concat(" ") .. " >/dev/null 2>&1"
  local result, what, code = shell.exec(command)

  os.remove(tmpin)
  if result == nil then
    os.remove(tmpout)
    return nil, what, code
  else
    that:write(assert(read_file(tmpout)))
    os.remove(tmpout)
    return that
  end
end

local metatable = {
  __index = class;
}

return setmetatable(class, {
  __call = function (_, this, that)
    return setmetatable(class.new(this, that), metatable)
  end;
})
