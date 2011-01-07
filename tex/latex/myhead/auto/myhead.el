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
     '("vcoord" 2)
     '("vectr" 1)
     '("dset" 2)
     '("set" 1)
     '("pa" 1)
     '("header" 1)
     "nohead"
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
     "vk"
     "Oij"
     "Oijk"
     "framesecsub"
     "framesec"
     "framesub"
     "im"
     "R"
     "Q"
     "N"
     "Z")
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
     "amstext"
     "amsfonts"
     "fontenc"
     "T1"
     "inputenc"
     "utf8"
     "lastpage"
     "fancyhdr"
     "tikz"
     "variations"
     "pgf"
     "babel"
     "francais")))

