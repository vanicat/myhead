-- Copyright 2010 by Renée Ahrens, Olof Frahm, Jens Kluttig, Matthias Schulz, Stephan Schuster
-- Copyright 2011 by Jannis Pohlmann
--
-- This file may be distributed an/or modified
--
-- 1. under the LaTeX Project Public License and/or
-- 2. under the GNU Public License
--
-- See the file doc/generic/pgf/licenses/LICENSE for more information

-- @release $Header: /cvsroot/pgf/pgf/generic/pgf/graphdrawing/core/lualayer/pgflibrarygraphdrawing-interface.lua,v 1.6 2011/05/15 14:15:45 jannis-pohlmann Exp $

-- This file defines the Interface global object, which is used as a
-- simplified frontend in the TeX part of the library.

pgf.module("pgf.graphdrawing")



--- Sits between the TikZ/TeX side and Lua.
Interface = {
  graphStack = {},
  defaultGraphParameters = {}
}
Interface.__index = Interface



--- Creates a new graph and adds it to the graph stack.
--
-- The options string consisting of |{key}{value}| pairs is parsed and 
-- assigned to the graph. These options are used to configure the different
-- graph drawing algorithms shipped with \tikzname.
--
-- @see finishGraph
--
-- @param options A string containing |{key}{value}| pairs of 
--                \tikzname\ options.
--
function Interface:newGraph(options)
  self.graph = Graph:new()
  table.insert(self.graphStack, self.graph)
  Sys:log("GD:INT: options = " .. options)
  self.graph:mergeOptions(string.parse_braces(options))
end



--- Sets the graph option \meta{name} to \meta{value}. Only affects the current graph.
--
-- @param name  The name of the option to set.
-- @param value New value for the option.
--
function Interface:setOption(name, value)
  self.graph:setOption(name, value)
end



--- Returns the value of the graph option \meta{name}.
--
-- @param name Name of the option.
--
-- @return The value of the \meta{name} option or |nil|.
--
function Interface:getOption(name)
  return self.graph:getOption(name)
end



--- Adds a new node to the graph.
--
-- The options string of |{key}{value}| pairs is parsed and assigned
-- to the node. Graph drawing algorithms may use these options to treat
-- the node in special ways.
--
-- @param name    Name of the node.
-- @param xMin    Minimum x point of the bouding box.
-- @param yMin    Minimum y point of the bouding box.
-- @param xMax    Maximum x point of the bouding box.
-- @param yMax    Maximum y point of the bouding box.
-- @param options Options for the node.
--
function Interface:addNode(name, xMin, yMin, xMax, yMax, options)
  assert(self.graph, "no graph created")
  local tex = {
    texNode = TeXBoxRegister:insertBox(Sys:getTeXBox()), 
    maxX = xMax,
    minX = xMin,
    maxY = yMax,
    minY = yMin
  }
  local node = Node:new{
    name = Sys:unescapeTeXNodeName(name), 
    tex = tex, 
    options = string.parse_braces(options)
  }
  self.graph:addNode(node)
  Sys:log("GD:INT: addNode(" .. node.name ..", " .. "maxX = " .. node.tex.maxX .. ", minX = " .. node.tex.minX .. ", maxY = " .. node.tex.maxY.. ", minY = " .. node.tex.minY .. ",...)")
end



--- Adds an edge from one node to another by name.  
--
-- Both parameters are node names and have to exist before an edge can be
-- created between them.
--
-- @see addNode
--
-- @param from         Name of the node the edge begins at.
-- @param to           Name of the node the edge ends at.
-- @param direction    Direction of the edge (e.g. |--| for an undirected edge 
--                     or |->| for a directed edge from the first to the second 
--                     node).
-- @param parameters   A string of parameters pairs of edge options that are
--                     relevant to graph drawing algorithms.
-- @param tikz_options A string that should be passed back to \pgfgddraw unmodified.
-- @param aux          Another string that should be passed back to \pgfgddraw unmodified.
--
function Interface:addEdge(from, to, direction, parameters, tikz_options, aux)
  assert(self.graph, "no graph created")
  Sys:log("GD:INT: Edge " .. tostring(from) .. " " .. tostring(direction) .. " " .. tostring(to))
  from = self.graph:findNode(from)
  to = self.graph:findNode(to)
  assert(from and to, "at least one node doesn't exist yet")
  if direction == Edge.NONE then
    self.graph:deleteEdgeBetweenNodes(from, to)
  else
    self.graph:createEdge(from, to, direction, aux, string.parse_braces(parameters), tikz_options)
  end
end



--- Attempts to load the algorithm with the given \meta{name}.
--
-- This function tries to look up the corresponding algorithm file
-- |pgflibrarygraphdrawing-algorithms-name.lua| and attempts to
-- look up the main function for calling the algorithm.
--
-- @param name Name of the algorithm.
--
-- @return The algorithm function or nil.
--
function Interface:loadAlgorithm(name)
  local function_name = 'drawGraphAlgorithm_' .. name
  
  -- substitute special characters in the function name with
  -- something that Lua can handle
  local substitutions = { ['-'] = '_' }
  for char, replacement in pairs(substitutions) do
    function_name = function_name:gsub(char, replacement)
  end
  
  Sys:log('function_name = ' .. function_name)
  Sys:log('name = ' .. name)
  
  -- try to load the algorithm file
  -- delete the following after renaming of all files
  local filename = "pgfgd-algorithm-" .. name .. ".lua"
  pgf.load(filename, "tex", false, "pgflibrarygraphdrawing-algorithms-" .. name .. ".lua")

  -- look up the main algorithm function
  return pgf.graphdrawing[function_name]
end



--- Arranges the current graph using the specified algorithm. 
--
-- The algorithm is derived from the graph options and is loaded on
-- demand from the corresponding algorithm file. For a fictitious algorithm 
-- |simple| this file is per convention called 
-- |pgflibrarygraphdrawing-algorithms-simple.lua|. It is required to define
-- at least one function as an entry point to the algorithm. The name of the
-- function is again predetermined as |drawGraphAlgorithm_simple|.
-- When a graph is to be layed out, this function is called with the graph
-- as its only parameter.
--
function Interface:drawGraph()
  if #self.graph.nodes == 0 then
    Sys:log("GD:INT: no nodes, aborting")
    return
  end

  local name = self:getOption("/graph drawing/algorithm"):gsub('%s', '-')
  local functionName = "drawGraphAlgorithm_" .. name:gsub('-', '_')
  local algorithm = pgf.graphdrawing[functionName]
  
  -- if not defined, try to load the corresponding file
  if not algorithm then
    algorithm = self:loadAlgorithm(name)
  end
  
  assert(algorithm, "the algorithm is nil, e.g. a function named "
                    .. functionName .. " doesn't exist in the pgf.graphdrawing "
                    .. "module")
  local start = os.clock()
  algorithm(self.graph)
  local stop = os.clock()
  Sys:log(string.format("GD:INT: algorithm took %.2f seconds", stop - start))
  Sys:log(' ')
end



--- Passes the current graph back to the \TeX\ layer and removes it from the stack.
--
function Interface:finishGraph()
  assert(self.graph, "no graph created")
  Sys:beginShipout()
  local graph = table.remove(self.graphStack)
  self.graph = self.graphStack[#self.graphStack]
  
  Sys:log("GD:INT: graph = " .. tostring(graph))
  
  for node in table.value_iter(graph.nodes) do
    Sys:log("GD:INT: node = " .. tostring(node))
    self:drawNode(node)
  end
  
  for edge in table.value_iter(graph.edges) do
    Sys:log("GD:INT: edge = " .. tostring(edge))
    self:drawEdge(edge)
  end
  
  Sys:endShipout()
end



--- Passes a node back to the \TeX\ layer.
--
-- @param node The node to pass back to the \TeX\ layer.
--
function Interface:drawNode(node)
  Sys:putTeXBox(node,
                node.tex.texNode,
                node.tex.minX,
                node.tex.minY,
                node.tex.maxX,
                node.tex.maxY,
                node.pos:x(),
                node.pos:y())
end



--- Passes an edge back to the \TeX\ layer.
--
-- Edges with a direction of |Edge.NONE| are skipped and not passed
-- back to \TeX.
--
-- @param edge The edge to pass back to the \TeX\ layer.
--
function Interface:drawEdge(edge)
  if edge.direction ~= Edge.NONE then
    Sys:putEdge(edge)
  end
end



--- Defines a default value for a graph parameter. 
--
-- Whenever a graph parameter has not been set by the user explicitly,
-- the value that was last set using this function is used instead.
--
-- @param key The commplete path of the to-be-defined key
-- @param value A string containing the value
--
function Interface:setGraphParameterDefault(key,value)
  self.defaultGraphParameters[key] = value
end
