-- Copyright 2011 by Jannis Pohlmann
--
-- This file may be distributed and/or modified
--
-- 1. under the LaTeX Project Public License and/or
-- 2. under the GNU Public License
--
-- See the file doc/generic/pgf/licenses/LICENSE for more information

-- @release $Header: /cvsroot/pgf/pgf/generic/pgf/graphdrawing/algorithms/force/pgfgd-algorithm-Hu2006-spring-electrical.lua,v 1.3 2011/07/20 21:01:27 jannis-pohlmann Exp $

pgf.module("pgf.graphdrawing")



Hu2006SpringElectrical = {}
Hu2006SpringElectrical.__index = Hu2006SpringElectrical



--- Implementation of a spring-electrical graph drawing algorithm.
-- 
-- This implementation is based on the paper 
--
--   "Efficient and High Quality Force-Directed Graph Drawing"
--   Yifan Hu, 2006
--
-- Modifications compared to the original algorithm are explained in the manual.
--
function drawGraphAlgorithm_Hu2006_spring_electrical(graph)
  local hu = Hu2006SpringElectrical:new(graph)

  Sys:log('Hu2006 spring electrical: random_seed = ' .. hu.random_seed)
  Sys:log('Hu2006 spring electrical: ')
  Sys:log('Hu2006 spring electrical: iterations = ' .. hu.iterations)
  Sys:log('Hu2006 spring electrical: cooling_factor = ' .. hu.cooling_factor)
  Sys:log('Hu2006 spring electrical: initial_step_length = ' .. hu.initial_step_length)
  Sys:log('Hu2006 spring electrical: convergence_tolerance = ' .. hu.convergence_tolerance)
  Sys:log('Hu2006 spring electrical: ')
  Sys:log('Hu2006 spring electrical: natural_spring_length = ' .. hu.natural_spring_length)
  Sys:log('Hu2006 spring electrical: spring_constant = ' .. hu.spring_constant)
  Sys:log('Hu2006 spring electrical: ')
  Sys:log('Hu2006 spring electrical: approximate_repulsive_forces = ' .. tostring(hu.approximate_repulsive_forces))
  Sys:log('Hu2006 spring electrical: repulsive_force_order = ' .. hu.repulsive_force_order)
  Sys:log('Hu2006 spring electrical: ')
  Sys:log('Hu2006 spring electrical: coarsen = ' .. tostring(hu.coarsen))
  Sys:log('Hu2006 spring electrical: downsize_ratio = ' .. hu.downsize_ratio)
  Sys:log('Hu2006 spring electrical: minimum_graph_size = ' .. hu.minimum_graph_size)

  hu:initialize()
  hu:run()

  orientation.adjust(graph)
end



function Hu2006SpringElectrical:new(graph)
  local hu = {
    random_seed = tonumber(graph:getOption('/graph drawing/spring electrical layout/random seed')),

    iterations = tonumber(graph:getOption('/graph drawing/spring electrical layout/iterations')),
    cooling_factor = tonumber(graph:getOption('/graph drawing/spring electrical layout/cooling factor')),
    initial_step_length = tonumber(graph:getOption('/graph drawing/spring electrical layout/initial step dimension')),
    convergence_tolerance = tonumber(graph:getOption('/graph drawing/spring electrical layout/convergence tolerance')),

    natural_spring_length = tonumber(graph:getOption('/graph drawing/spring electrical layout/natural spring dimension')),
    spring_constant = tonumber(graph:getOption('/graph drawing/spring electrical layout/spring constant')),

    approximate_repulsive_forces = graph:getOption('/graph drawing/spring electrical layout/approximate repulsive forces') == 'true',
    repulsive_force_order = tonumber(graph:getOption('/graph drawing/spring electrical layout/repulsive force order')),

    coarsen = graph:getOption('/graph drawing/spring electrical layout/coarsen') == 'true',
    downsize_ratio = math.max(0, math.min(1, tonumber(graph:getOption('/graph drawing/spring electrical layout/coarsening/downsize ratio')))),
    minimum_graph_size = tonumber(graph:getOption('/graph drawing/spring electrical layout/coarsening/minimum graph size')),

    graph = graph,
    graph_size = #graph.nodes,
    graph_density = (2 * #graph.edges) / (#graph.nodes * (#graph.nodes - 1))
  }
  setmetatable(hu, Hu2006SpringElectrical)

  -- validate input parameters
  assert(hu.iterations >= 0, 'iterations (value: ' .. hu.iterations .. ') need to be greater than 0')
  assert(hu.cooling_factor >= 0 and hu.cooling_factor <= 1, 'the cooling factor (value: ' .. hu.cooling_factor .. ') needs to be between 0 and 1')
  assert(hu.initial_step_length >= 0, 'the initial step dimension (value: ' .. hu.initial_step_length .. ') needs to be greater than or equal to 0')
  assert(hu.convergence_tolerance >= 0, 'the convergence tolerance (value: ' .. hu.convergence_tolerance .. ') needs to be greater than or equal to 0')
  assert(hu.natural_spring_length >= 0, 'the natural spring dimension (value: ' .. hu.natural_spring_length .. ') needs to be greater than or equal to 0')
  assert(hu.spring_constant >= 0, 'the spring constant (value: ' .. hu.spring_constant .. ') needs to be greater or equal to 0')
  assert(hu.downsize_ratio >= 0 and hu.downsize_ratio <= 1, 'the downsize ratio (value: ' .. hu.downsize_ratio .. ') needs to be between 0 and 1')
  assert(hu.minimum_graph_size >= 2, 'the minimum graph size of coarse graphs (value: ' .. hu.minimum_graph_size .. ') needs to be greater than or equal to 2')

  return hu
end



function Hu2006SpringElectrical:initialize()
  -- apply the random seed specified by the user (only if it is non-zero)
  if self.random_seed ~= 0 then
    math.randomseed(self.random_seed)
  end

  -- initialize node weights
  for node in table.value_iter(self.graph.nodes) do
    node.weight = tonumber(node:getOption('/graph drawing/spring electrical layout/electric charge'))
  end

  -- initialize edge weights
  for edge in table.value_iter(self.graph.edges) do
    edge.weight = 1
  end
end



function Hu2006SpringElectrical:run()
  -- initialize the coarse graph data structure. note that the algorithm
  -- is the same regardless whether coarsening is used, except that the 
  -- number of coarsening steps without coarsening is 0
  local coarse_graph = CoarseGraph:new(self.graph)

  -- check if the multilevel approach should be used
  if self.coarsen then
    -- coarsen the graph repeatedly until only minimum_graph_size nodes 
    -- are left or until the size of the coarse graph was not reduced by 
    -- at least the downsize ratio configured by the user
    while coarse_graph:getSize() > self.minimum_graph_size 
      and coarse_graph:getRatio() <= (1 - self.downsize_ratio) 
    do
      --self:dumpGraph(coarse_graph.graph, 'coarse graph before next coarsening step')
      coarse_graph:coarsen()
    end

    --self:dumpGraph(coarse_graph.graph, 'coarse graph after the last coarsening step')
  end

  if self.coarsen then
    -- use the natural spring length as the initial natural spring length
    local spring_length = self.natural_spring_length

    -- compute a random initial layout for the coarsest graph
    self:computeInitialLayout(coarse_graph.graph, spring_length)

    -- set the spring length to the average edge length of the initial layout
    spring_length = table.combine_values(coarse_graph.graph.edges, function (sum, edge)
      return sum + edge.nodes[1].pos:minus(edge.nodes[2].pos):norm()
    end, 0)
    spring_length = spring_length / #coarse_graph.graph.edges

    -- additionally improve the layout with the force-based algorithm
    -- if there are more than two nodes in the coarsest graph
    if coarse_graph:getSize() > 2 then
      self:computeForceLayout(coarse_graph.graph, spring_length, Hu2006SpringElectrical.adaptive_step_update)
    end

    -- undo coarsening step by step, applying the force-based sub-algorithm
    -- to every intermediate coarse graph as well as the original graph
    while coarse_graph:getLevel() > 0 do
      --self:dumpGraph(coarse_graph.graph, 'coarse graph before reverting one step')

      -- compute the diameter of the parent coarse graph
      local parent_diameter = coarse_graph.graph:getPseudoDiameter()

      -- interpolate the previous coarse graph from its parent
      coarse_graph:interpolate()

      --self:dumpGraph(coarse_graph.graph, 'coarse graph after reverting one step')

      -- compute the diameter of the current coarse graph
      local current_diameter = coarse_graph.graph:getPseudoDiameter()

      -- scale node positions by the quotient of the pseudo diameters
      for node in table.value_iter(coarse_graph.graph) do
        node.pos:update(function (n, value)
          return value * (current_diameter / parent_diameter)
        end)
      end

      -- compute forces in the graph
      self:computeForceLayout(coarse_graph.graph, spring_length, Hu2006SpringElectrical.conservative_step_update)
    end
  else
    -- compute a random initial layout for the coarsest graph
    self:computeInitialLayout(coarse_graph.graph, self.natural_spring_length)

    -- set the spring length to the average edge length of the initial layout
    spring_length = table.combine_values(coarse_graph.graph.edges, function (sum, edge)
      return sum + edge.nodes[1].pos:minus(edge.nodes[2].pos):norm()
    end, 0)
    spring_length = spring_length / #coarse_graph.graph.edges

    -- improve the layout with the force-based algorithm
    self:computeForceLayout(coarse_graph.graph, spring_length, Hu2006SpringElectrical.conservative_step_update)
  end
end



function Hu2006SpringElectrical:computeInitialLayout(graph, spring_length)
  -- TODO how can supernodes and fixed nodes go hand in hand? 
  -- maybe fix the supernode if at least one of its subnodes is 
  -- fixated?

  -- fixate all nodes that have a 'desired at' option. this will set the
  -- node.fixed member to true and also set node.pos:x() and node.pos:y()
  self:fixateNodes(graph)

  if #graph.nodes == 2 then
    if not (graph.nodes[1].fixed and graph.nodes[2].fixed) then
      local fixed_index = graph.nodes[2].fixed and 2 or 1
      local loose_index = graph.nodes[2].fixed and 1 or 2

      if not graph.nodes[1].fixed and not graph.nodes[2].fixed then
        -- both nodes can be moved, so we assume node 1 is fixed at (0,0)
        graph.nodes[1].pos:set{x = 0, y = 0}
      end

      -- position the loose node relative to the fixed node, with
      -- the displacement (random direction) matching the spring length
      local direction = Vector:new{x = math.random(1, spring_length), y = math.random(1, spring_length)}
      local distance = self.graph_density * 3 * spring_length * (math.sqrt(self.graph_size) - 1) / (2 * math.cos(math.pi / 4))
      local displacement = direction:normalized():timesScalar(distance)

      Sys:log('Hu2006SpringElectrical: distance = ' .. distance)

      graph.nodes[loose_index].pos = graph.nodes[fixed_index].pos:plus(displacement)
    else
      -- both nodes are fixed, initial layout may be far from optimal
    end
  else
    -- function to filter out fixed nodes
    local function nodeNotFixed(node) return not node.fixed end

    -- use the random positioning technique
    local positioning_func = positioning.technique('random', self.graph_size, self.graph_density, spring_length)

    -- compute initial layout based on the random positioning technique
    for node in iter.filter(table.value_iter(graph.nodes), nodeNotFixed) do
      node.pos:set{x = positioning_func(1), y = positioning_func(2)}
    end
  end
end



function Hu2006SpringElectrical:computeForceLayout(graph, spring_length, step_update_func)
  -- global (=repulsive) force function
  function accurate_repulsive_force(distance, weight)
    -- note: the weight is taken into the equation here. unlike in the original
    -- algorithm different electric charges are allowed for each node in this
    -- implementation
    return - weight * self.spring_constant * math.pow(spring_length, self.repulsive_force_order + 1) / math.pow(distance, self.repulsive_force_order)
  end

  -- global (=repulsive, approximated) force function
  function approximated_repulsive_force(distance, mass)
    return - mass * self.spring_constant * math.pow(spring_length, self.repulsive_force_order + 1) / math.pow(distance, self.repulsive_force_order)
  end

  -- local (spring) force function
  function attractive_force(distance)
    -- TODO HU does not subtract k here but this probably makes sense 
    -- because the force should be repulsive if the edge is compressed and
    -- attractive if the edge is longer than its natural length
    return (distance * distance - spring_length) / spring_length
  end

  -- define the Barnes-Hut opening criterion
  function barnes_hut_criterion(cell, particle)
    local distance = particle.pos:minus(cell.centre_of_mass):norm()
    return cell.width / distance <= 1.2
  end

  -- adjust the initial step length automatically if desired by the user
  local step_length = self.initial_step_length == 0 and spring_length or self.initial_step_length
 
  -- convergence criteria etc.
  local converged = false
  local energy = math.huge
  local iteration = 0
  local progress = 0

  while not converged and iteration < self.iterations do
    -- remember old node positions
    local old_positions = table.map_pairs(graph.nodes, function (n, node)
      return node, node.pos:copy()
    end)

    -- remember the old system energy and reset it for the current iteration
    local old_energy = energy
    energy = 0

    -- build the quadtree for approximating repulsive forces, if desired
    local quadtree = nil
    if self.approximate_repulsive_forces then
      quadtree = self:buildQuadtree(graph)
    end

    local function nodeNotFixed(node) return not node.fixed end

    for v in iter.filter(table.value_iter(graph.nodes), nodeNotFixed) do
      -- vector for the displacement of v
      local d = Vector:new(2)

      -- compute repulsive forces
      if self.approximate_repulsive_forces then
        -- determine the cells that have a repulsive influence on v
        local cells = quadtree:findInteractionCells(v, barnes_hut_criterion)

        -- compute the repulsive force between these cells and v
        for cell in table.value_iter(cells) do
          -- check if the cell is a leaf
          if #cell.subcells == 0 then
            -- compute the forces between the node and all particles in the cell
            for particle in table.value_iter(cell.particles) do
              local real_particles = table.custom_copy(particle.subparticles)
              table.insert(real_particles, particle)

              for real_particle in table.value_iter(real_particles) do
                local delta = real_particle.pos:minus(v.pos)
            
                -- enforce a small virtual distance if the node and the cell's 
                -- centre of mass are located at (almost) the same position
                if delta:norm() < 0.1 then
                  delta:update(function (n, value) return 0.1 + math.random() * 0.1 end)
                end

                -- compute the repulsive force vector
                local repulsive_force = approximated_repulsive_force(delta:norm(), real_particle.mass)
                local force = delta:normalized():timesScalar(repulsive_force)

                -- move the node v accordingly
                d = d:plus(force)
              end
            end
          else
            -- compute the distance between the node and the cell's centre of mass
            local delta = cell.centre_of_mass:minus(v.pos)

            -- enforce a small virtual distance if the node and the cell's 
            -- centre of mass are located at (almost) the same position
            if delta:norm() < 0.1 then
              delta:update(function (n, value) return 0.1 + math.random() * 0.1 end)
            end

            -- compute the repulsive force vector
            local repulsive_force = approximated_repulsive_force(delta:norm(), cell.mass)
            local force = delta:normalized():timesScalar(repulsive_force)
            
            -- move the node v accordingly
            d = d:plus(force)
          end
        end
      else
        for u in table.value_iter(graph.nodes) do
          if v ~= u then
            -- compute the distance between u and v
            local delta = u.pos:minus(v.pos)

            -- enforce a small virtual distance if the nodes are
            -- located at (almost) the same position
            if delta:norm() < 0.1 then
              delta:update(function (n, value) return 0.1 + math.random() * 0.1 end)
            end

            -- compute the repulsive force vector
            local repulsive_force = accurate_repulsive_force(delta:norm(), u.weight)
            local force = delta:normalized():timesScalar(repulsive_force)

            -- move the node v accordingly
            d = d:plus(force)
          end
        end
      end

      -- compute attractive forces between v and its neighbours
      for edge in table.value_iter(v.edges) do
        local u = edge:getNeighbour(v)

        -- compute the distance between u and v
        local delta = u.pos:minus(v.pos)

        -- enforce a small virtual distance if the nodes are
        -- located at (almost) the same position
        if delta:norm() < 0.1 then
          delta:update(function (n, value) return 0.1 + math.random() * 0.1 end)
        end
    
        -- compute the spring force vector between u and v
        local attr_force = attractive_force(delta:norm())
        local force = delta:normalized():timesScalar(attr_force)

        -- move the node v accordingly
        d = d:plus(force)
      end

      -- really move the node now
      -- TODO note how all nodes are moved by the same amount  (step_length)
      -- while Walshaw multiplies the normalized force with min(step_length, 
      -- d:norm()). could that improve this algorithm even further?
      v.pos = v.pos:plus(d:normalized():timesScalar(step_length))

      -- update the energy function
      energy = energy + math.pow(d:norm(), 2)
    end

    -- update the step length and progress counter
    step_length, progress = step_update_func(step_length, self.cooling_factor, energy, old_energy, progress)

    -- compute the maximum node movement in this iteration
    local max_movement = table.combine_values(graph.nodes, function (max, x)
      local delta = x.pos:minus(old_positions[x])
      if delta:norm() > max then
        return delta:norm()
      else
        return max
      end
    end, 0)
    
    -- the algorithm will converge if the maximum movement is below a 
    -- threshold depending on the spring length and the convergence 
    -- tolerance
    if max_movement < spring_length * self.convergence_tolerance then
      converged = true
    end

    -- increment the iteration counter
    iteration = iteration + 1
  end
end



--- Fixes nodes at their specified positions.
--
function Hu2006SpringElectrical:fixateNodes(graph)
  for node in table.value_iter(graph.nodes) do
    -- read the 'desired at' option of the node
    local coordinate = node:getOption('/graph drawing/desired at')

    if coordinate then
      -- parse the coordinate
      local coordinate_pattern = '{([%d.-]+)}{([%d.-]+)}'
      local x, y = coordinate:gmatch(coordinate_pattern)()
      
      -- apply the coordinate
      node.pos:set{x = tonumber(x), y = tonumber(y)}

      -- mark the node as fixed
      node.fixed = true
    end
  end
end



function Hu2006SpringElectrical:buildQuadtree(graph)
  -- compute the minimum x and y coordinates of all nodes
  local min_pos = table.combine_values(graph.nodes, function (min_pos, node)
    return Vector:new(2, function (n) 
      return math.min(min_pos:get(n), node.pos:get(n))
    end)
  end, graph.nodes[1].pos)

  -- compute maximum x and y coordinates of all nodes
  local max_pos = table.combine_values(graph.nodes, function (max_pos, node)
    return Vector:new(2, function (n) 
      return math.max(max_pos:get(n), node.pos:get(n))
    end)
  end, graph.nodes[1].pos)

  -- make sure the maximum position is at least a tiny bit
  -- larger than the minimum position
  if min_pos:equals(max_pos) then
    max_pos = max_pos:plus(Vector:new(2, function (n)
      return 0.1 + math.random() * 0.1
    end))
  end

  -- make sure to make the quadtree area slightly larger than required
  -- in theory; for some reason Lua will otherwise think that nodes with
  -- min/max x/y coordinates are outside the box... weird? yes.
  min_pos = min_pos:minusScalar(1)
  max_pos = max_pos:plusScalar(1)

  -- create the quadtree
  quadtree = QuadTree:new(min_pos:x(), min_pos:y(),
                          max_pos:x() - min_pos:x(),
                          max_pos:y() - min_pos:y())

  -- insert nodes into the quadtree
  for node in table.value_iter(graph.nodes) do
    local particle = Particle:new(node.pos, node.weight)
    particle.node = node
    quadtree:insert(particle)
  end

  return quadtree
end



function Hu2006SpringElectrical.conservative_step_update(step, cooling_factor)
  return cooling_factor * step, nil
end



function Hu2006SpringElectrical.adaptive_step_update(step, cooling_factor, energy, old_energy, progress)
  if energy < old_energy then
    progress = progress + 1
    if progress >= 5 then
      progress = 0
      step = step / cooling_factor
    end
  else
    progress = 0
    step = cooling_factor * step
  end
  return step, progress
end



function Hu2006SpringElectrical:dumpGraph(graph, title)
  Sys:log(title .. ':')
  for node in table.value_iter(graph.nodes) do
    Sys:log('  node ' .. node.name)
    for edge in table.value_iter(node.edges) do
      Sys:log('    ' .. tostring(edge))
    end
  end
  for edge in table.value_iter(graph.edges) do
    Sys:log('  ' .. tostring(edge))
  end
end
