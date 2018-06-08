-- (c) 2009-2011 John MacFarlane. Released under MIT license.
-- See the file LICENSE in the source for details.

--- LaTeX writer for lunamark.
-- Extends the [lunamark.writer.tex].

local M = {}

local tex = require("lunamark.writer.tex")
local util = require("lunamark.util")
local gsub = string.gsub
local format = string.format

--- Returns a new LaTeX writer.
-- For a list of fields in the writer, see [lunamark.writer.generic].
function M.new(options)
  local options = options or {}
  local LaTeX = tex.new(options)

  function LaTeX.code(s)
    return format("\\texttt{%s}", LaTeX.string(s))
  end

  function LaTeX.link(lab,src,tit)
    return format("\\href{%s}{%s}", LaTeX.string(src), lab)
  end

  function LaTeX.image(lab,src,tit)
    return format("\\includegraphics{%s}", LaTeX.string(src))
  end

  local function listitem(s)
    return format("\\item %s",s)
  end

  function LaTeX.bulletlist(items)
    local buffer = {}
    for _,item in ipairs(items) do
      buffer[#buffer + 1] = listitem(item)
    end
    local contents = table.concat(buffer, "\n")
    return format("\\begin{itemize}\n%s\n\\end{itemize}",contents)
  end

  function LaTeX.orderedlist(items)
    local buffer = {}
    for _,item in ipairs(items) do
      buffer[#buffer + 1] = listitem(item)
    end
    local contents = table.concat(buffer, "\n")
    return format("\\begin{enumerate}\n%s\n\\end{enumerate}",contents)
  end

  function LaTeX.emphasis(s)
    return format("\\emph{%s}",s)
  end

  function LaTeX.strong(s)
    return format("\\textbf{%s}",s)
  end

  function LaTeX.blockquote(s)
    return format("\\begin{quote}\n%s\n\\end{quote}", s)
  end

  function LaTeX.verbatim(s)
    return format("\\begin{verbatim}\n%s\\end{verbatim}", s)
  end

  function LaTeX.header(s,level)
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

  LaTeX.hrule = "\\hspace{\\fill}\\rule{.6\\linewidth}{0.4pt}\\hspace{\\fill}"

  function LaTeX.note(contents)
    return format("\\footnote{%s}", contents)
  end

  function LaTeX.definitionlist(items)
    local buffer = {}
    for _,item in ipairs(items) do
      buffer[#buffer + 1] = format("\\item[%s]\n%s",
        item.term, table.concat(item.definitions, LaTeX.interblocksep))
    end
    local contents = table.concat(buffer, LaTeX.containersep)
    return format("\\begin{description}\n%s\n\\end{description}",contents)
  end

  LaTeX.template = [===[
\documentclass{article}
\usepackage{amssymb,amsmath}
\usepackage{ifxetex,ifluatex}
\ifxetex
  \usepackage{fontspec,xltxtra,xunicode}
  \defaultfontfeatures{Mapping=tex-text,Scale=MatchLowercase}
\else
  \ifluatex
    \usepackage{fontspec}
    \defaultfontfeatures{Mapping=tex-text,Scale=MatchLowercase}
  \else
    \usepackage[utf8]{inputenc}
  \fi
\fi
\ifxetex
  \usepackage[setpagesize=false, % page size defined by xetex
              unicode=false, % unicode breaks when used with xetex
              xetex]{hyperref}
\else
  \usepackage[unicode=true]{hyperref}
\fi
\hypersetup{breaklinks=true, pdfborder={0 0 0}}
\setlength{\parindent}{0pt}
\setlength{\parskip}{6pt plus 2pt minus 1pt}
\setlength{\emergencystretch}{3em}  % prevent overfull lines
\setcounter{secnumdepth}{0}

\title{$title}
\author{$sepby{author}[=[$it]=][=[ \and ]=]}
\date{$date}

\begin{document}

$if{ title }[[\maketitle
]]
$body

\end{document}
]===]

  return LaTeX
end

return M
