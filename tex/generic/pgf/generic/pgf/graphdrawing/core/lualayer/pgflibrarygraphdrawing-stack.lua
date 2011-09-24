-- Copyright 2011 by Jannis Pohlmann
--
-- This file may be distributed an/or modified
--
-- 1. under the LaTeX Project Public License and/or
-- 2. under the GNU Public License
--
-- See the file doc/generic/pgf/licenses/LICENSE for more information

-- @release $Header: /cvsroot/pgf/pgf/generic/pgf/graphdrawing/core/lualayer/pgflibrarygraphdrawing-stack.lua,v 1.1 2011/07/14 13:16:25 jannis-pohlmann Exp $

--- TODO Jannis: Add documentation.

pgf.module("pgf.graphdrawing")



Stack = {}
Stack.__index = Stack



function Stack:new()
  local stack = {
    elements = {},
  }
  setmetatable(stack, Stack)
  return stack
end



function Stack:push(data)
  table.insert(self.elements, data)
end



function Stack:peek()
  return self.elements[#self.elements]
end



function Stack:pop()
  return table.remove(self.elements, #self.elements)
end



function Stack:getSize()
  return #self.elements
end
