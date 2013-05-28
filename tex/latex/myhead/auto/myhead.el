(TeX-add-style-hook "myhead"
 (lambda ()
    (TeX-add-symbols
     '("languagepath" 1)
     '("uselanguage" 1)
     "EURbis")
    (TeX-run-style-hooks
     "myhead-org"
     "comment"
     "sistyle"
     "multicol"
     "enumerate"
     "eurosym"
     "geometry"
     "amsmath"
     "amssymb"
     "amsthm"
     "amstext"
     "amsfonts"
     "fontenc"
     "T1"
     "inputenc"
     "utf8"
     "lastpage"
     "fancyhdr"
     "graphicx"
     "tkz-tab"
     "tikz"
     "variations"
     "pgf"
     ""
     "babel"
     "francais")))

