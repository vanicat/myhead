-- Copyright 2011 by Jannis Pohlmann
--
-- This file may be distributed an/or modified
--
-- 1. under the LaTeX Project Public License and/or
-- 2. under the GNU Public License
--
-- See the file doc/generic/pgf/licenses/LICENSE for more information

-- @release $Header: /cvsroot/pgf/pgf/generic/pgf/graphdrawing/core/lualayer/pgflibrarygraphdrawing-depth-first-search.lua,v 1.3 2011/07/14 13:16:49 jannis-pohlmann Exp $

--- TODO Jannis: Add documentation.

pgf.module("pgf.graphdrawing")



DepthFirstSearch = {}
DepthFirstSearch.__index = DepthFirstSearch



function DepthFirstSearch:new(init_func, visit_func, complete_func)
  local dfs = {
    init_func = init_func,
    visit_func = visit_func,
    complete_func = complete_func,

    stack = Stack:new(),
    discovered = {},
    visited = {},
    completed = {},
  }
  setmetatable(dfs, DepthFirstSearch)
  return dfs
end



function DepthFirstSearch:run()
  self:reset()
  self.init_func(self)

  while self.stack:getSize() > 0 do
    local data = self.stack:peek()

    if not self:getVisited(data) then
      if self.visit_func then
        self.visit_func(self, data)
      end
    else
      if self.complete_func then
        self.complete_func(self, data)
      end
      self:setCompleted(data, true)
      self.stack:pop()
    end
  end
end



function DepthFirstSearch:reset()
  self.discovered = {}
  self.visited = {}
  self.completed = {}
  self.stack = Stack:new()
end



function DepthFirstSearch:setDiscovered(data, discovered)
  self.discovered[data] = discovered
end



function DepthFirstSearch:getDiscovered(data)
  return self.discovered[data]
end



function DepthFirstSearch:setVisited(data, visited)
  self.visited[data] = visited
end



function DepthFirstSearch:getVisited(data)
  return self.visited[data]
end



function DepthFirstSearch:setCompleted(data, completed)
  self.completed[data] = completed
end



function DepthFirstSearch:getCompleted(data)
  return self.completed[data]
end



function DepthFirstSearch:push(data)
  self.stack:push(data)
end
