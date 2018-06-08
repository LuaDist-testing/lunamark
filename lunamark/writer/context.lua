-- (c) 2009-2011 John MacFarlane, Khaled Hosny, Hans Hagen.
-- Released under MIT license. See the file LICENSE in the source for details.

--- ConTeXt writer for lunamark.
-- Extends [lunamark.writer.tex].

local M = {}

local tex = require("lunamark.writer.tex")
local util = require("lunamark.util")
local gsub = string.gsub
local format = string.format

--- Returns a new ConTeXt writer
-- For a list of all the fields, see [lunamark.writer.generic].
function M.new(options)
  local options = options or {}
  local ConTeXt = tex.new(options)

  -- we don't try to escape utf-8 characters in context
  function ConTeXt.string(s)
    return s:gsub(".",ConTeXt.escaped)
  end

  function ConTeXt.singlequoted(s)
    return format("\\quote{%s}",s)
  end

  function ConTeXt.doublequoted(s)
    return format("\\quotation{%s}",s)
  end

  function ConTeXt.code(s)
    return format("\\type{%s}", s)  -- escape here?
  end

  function ConTeXt.link(lab,src,tit)
    return format("\\goto{%s}[url(%s)]",lab, ConTeXt.string(src))
  end

  function ConTeXt.image(lab,src,tit)
    return format("\\externalfigure[%s]", ConTeXt.string(src))
  end

  local function listitem(s)
    return format("\\item %s\n",s)
  end

  function ConTeXt.bulletlist(items,tight)
    local opt = ""
    if tight then opt = "[packed]" end
    local buffer = {}
    for _,item in ipairs(items) do
      buffer[#buffer + 1] = listitem(item)
    end
    local contents = table.concat(buffer)
    return format("\\startitemize%s\n%s\\stopitemize",opt,contents)
  end

  function ConTeXt.orderedlist(items,tight,startnum)
    local tightstr = ""
    if tight then tightstr = ",packed" end
    local opt = string.format("[%d%s]", startnum or 1, tightstr)
    local buffer = {}
    for _,item in ipairs(items) do
      buffer[#buffer + 1] = listitem(item)
    end
    local contents = table.concat(buffer)
    return format("\\startitemize%s\n%s\\stopitemize",opt,contents)
  end

  function ConTeXt.emphasis(s)
    return format("{\\em %s}",s)
  end

  function ConTeXt.strong(s)
    return format("{\\bf %s}",s)
  end

  function ConTeXt.blockquote(s)
    return format("\\startblockquote\n%s\\stopblockquote", s)
  end

  function ConTeXt.verbatim(s)
    return format("\\starttyping\n%s\\stoptyping", s)
  end

  function ConTeXt.header(s,level)
    local cmd
    if level == 1 then
      cmd = "\\section"
    elseif level == 2 then
      cmd = "\\subsection"
    elseif level == 3 then
      cmd = "\\subsubsection"
    elseif level == 4 then
      cmd = "\\paragraph"
    elseif level == 5 then
      cmd = "\\subparagraph"
    else
      cmd = ""
    end
    return format("%s{%s}", cmd, s)
  end

  ConTeXt.hrule = "\\hairline"

  function ConTeXt.note(contents)
    return format("\\footnote{%s}", contents)
  end

  function ConTeXt.definitionlist(items)
    local buffer = {}
    for _,item in ipairs(items) do
      buffer[#buffer + 1] = format("\\startdescription{%s}\n%s\n\\stopdescription",
        item.term, table.concat(item.definitions, ConTeXt.interblocksep))
    end
    local contents = table.concat(buffer, ConTeXt.containersep)
    return contents
  end

  ConTeXt.template = [===[
\startmode[*mkii]
  \enableregime[utf-8]
  \setupcolors[state=start]
\stopmode

% Enable hyperlinks
\setupinteraction[state=start, color=middleblue]

\setuppapersize [letter][letter]
\setuplayout    [width=middle,  backspace=1.5in, cutspace=1.5in,
                 height=middle, topspace=0.75in, bottomspace=0.75in]

\setuppagenumbering[location={footer,center}]

\setupbodyfont[11pt]

\setupwhitespace[medium]

\setuphead[section]      [style=\tfc]
\setuphead[subsection]   [style=\tfb]
\setuphead[subsubsection][style=\bf]

\definedescription
  [description]
  [headstyle=bold, style=normal, location=hanging, width=broad, margin=1cm]

\setupitemize[autointro]    % prevent orphan list intro
\setupitemize[indentnext=no]

\setupthinrules[width=15em] % width of horizontal rules

\setupdelimitedtext
  [blockquote]
  [before={\blank[medium]},
   after={\blank[medium]},
   indentnext=no,
  ]

\starttext
$if{ title }[=[
\startalignment[center]
\blank[2*big]
{\tfd $title}
$if{ author }[[
\blank[3*medium]
{\tfa $sepby{author}[==[$it]==][==[\crlf ]==]}
]]
$if{ date }[[
\blank[2*medium]
{\tfa $date}
]]
\blank[3*medium]
\stopalignment

]=]
$if{ toc }[[{\placecontent}
]]
$body

\stoptext
]===]

  return ConTeXt
end

return M
