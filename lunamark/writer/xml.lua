-- (c) 2009-2011 John MacFarlane. Released under MIT license.
-- See the file LICENSE in the source for details.

--- Generic XML writer for lunamark.
-- It extends [lunamark.writer.generic] and is extended by
-- [lunamark.writer.html] and [lunamark.writer.docbook].

local M = {}

local gsub = string.gsub
local generic = require("lunamark.writer.generic")

--- Returns a new XML writer.
-- For a list of fields, see [lunamark.writer.generic].
function M.new(options)
  local options = options or {}
  local Xml = generic.new(options)

  Xml.container = "section"
  --  {1,2} means: a second level header inside a first-level
  local header_level_stack = {}

  function Xml.start_section(level)
    header_level_stack[#header_level_stack + 1] = level
    return "<" .. Xml.container .. ">"
  end

  function Xml.stop_section(level)
    local len = #header_level_stack
    if len == 0 then
      return ""
    else
      local last = header_level_stack[len]
      local res = {}
      while last >= level do
        header_level_stack[len] = nil
        table.insert(res, "</" .. Xml.container .. ">")
        len = len - 1
        last = (len > 0 and header_level_stack[len]) or 0
      end
      return table.concat(res, Xml.containersep)
    end
  end

  Xml.linebreak = "<linebreak />"

  local escaped = {
     ["<" ] = "&lt;",
     [">" ] = "&gt;",
     ["&" ] = "&amp;",
     ["\"" ] = "&quot;",
     ["'" ] = "&#39;"
  }

  function Xml.string(s)
    return s:gsub(".",escaped)
  end

  return Xml
end

return M
