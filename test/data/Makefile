# Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
#
# This file is part of dromozoa-image.
#
# dromozoa-image is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# dromozoa-image is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with dromozoa-image.  If not, see <http://www.gnu.org/licenses/>.

LUA = lua

TARGET = test1.pgm test2.pam test3.ppm test4.pam

all: $(TARGET)

clean:
	$(RM) $(TARGET)

test1.pgm: generate1
	$(LUA) $< >$@

test2.pam: generate2
	$(LUA) $< >$@

test3.ppm: generate3
	$(LUA) $< >$@

test4.pam: generate4
	$(LUA) $< >$@
