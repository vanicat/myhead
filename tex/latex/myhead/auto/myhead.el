(TeX-add-style-hook "myhead"
 (lambda ()
    (LaTeX-add-environments
     "Exo"
     "Theo"
     "Def"
     "Prop"
     "Preuve"
     "myeqn")
    (TeX-add-symbols
     '("dx" ["argument"] 0)
     '("CM" ["argument"] 0)
     '("mr" 1)
     '("mdr" 1)
     '("dr" 1)
     '("mseg" 1)
     '("seg" 1)
     '("vectr" 1)
     '("dset" 2)
     '("set" 1)
     '("pa" 1)
     '("header" 1)
     "ExoName"
     "dsum"
     "doplus"
     "dint"
     "dlim"
     "dprod"
     "dsup"
     "dinf"
     "udl"
     "ovl"
     "vect"
     "R"
     "N"
     "Z"
     "id"
     "sh"
     "ch"
     "renum"
     "enum"
     "snum"
     "slinez"
     "sline"
     "vu"
     "vv"
     "vw"
     "vi"
     "vj"
     "Oij"
     "im")
    (TeX-run-style-hooks
     "comment"
     "sistyle"
     "multicol"
     "enumerate"
     "eurosym"
     "geometry"
     "amsmath"
     "amssymb"
     "amsthm"
     "inputenc"
     "utf8x"
     "amstext"
     "amsfonts"
     "fontenc"
     "T1"
     "lastpage"
     "fancyhdr"
     "tikz"
     "pgf"
     "babel"
     "frenchb")))

