-- Copyright 2010 by Renée Ahrens, Olof Frahm, Jens Kluttig, Matthias Schulz, Stephan Schuster
--
-- This file may be distributed and/or modified
--
-- 1. under the LaTeX Project Public License
-- 2. under the GNU Public License
--
-- See the file doc/generic/pgf/licenses/LICENSE for more information

-- @release $Header: /cvsroot/pgf/pgf/generic/pgf/graphdrawing/core/lualayer/pgflibrarygraphdrawing-texboxregister.lua,v 1.1 2011/05/06 15:12:16 jannis-pohlmann Exp $

-- This class stores the TeX nodes which were copied from
-- the TeX box register.
--
-- The methods are called from the sys class.

pgf.module("pgf.graphdrawing")

TeXBoxRegister = {
   boxes = {}
}

TeXBoxRegister.__index = TeXBoxRegister

--- Adds the content of a \TeX\ box to the box register class. Contents of the box will be stored.
--
-- @texbox Contents of the box to be stored.
-- @returns Box reference.
function TeXBoxRegister:insertBox(texbox)
   table.insert(self.boxes, texbox)
   Sys:log("GD:TBR: inserting tex box in slot " .. # self.boxes)
   return # self.boxes
end

--- Gets a box by its reference.
-- @param boxReference Reference id of the box to get.
-- @returns Box content.
-- @see TeXBoxRegister:insertBox(texbox)
function TeXBoxRegister:getBox(boxReference)
   local ret = self.boxes[boxReference]
   assert(ret, "GD:TBR: fetching box " .. boxReference .. " returned a nil value")
   Sys:log("GD:TBR: fetching box " .. boxReference)
   self.boxes[boxReference] = nil
   return ret
end
