(TeX-add-style-hook "myhead"
 (lambda ()
    (LaTeX-add-environments
     "Exo"
     "Sol"
     "Exem"
     "Exems"
     "Theo"
     "Cor"
     "Conq"
     "Conqs"
     "Def"
     "Defs"
     "Meth"
     "Prop"
     "Lem"
     "Rap"
     "Rem"
     "Rems"
     "Voc"
     "Not"
     "Appl"
     "Appls"
     "Preuve"
     "myeqn")
    (TeX-add-symbols
     '("dx" ["argument"] 0)
     '("CM" ["argument"] 0)
     '("Variables" ["argument"] 1)
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
     '("languagepath" 1)
     '("uselanguage" 1)
     '("Affect" 2)
     '("Ecrire" 1)
     '("Resultat" 1)
     '("Entrees" 1)
     "nomprenom"
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
     "dotline"
     "snum"
     "slinez"
     "sline"
     "vu"
     "vv"
     "vw"
     "vi"
     "vj"
     "vk"
     "vO"
     "Oij"
     "OIJ"
     "Oijk"
     "framesecsub"
     "framesec"
     "framesub"
     "EURbis"
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
     "algorithmicx"
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
     "tikz"
     "variations"
     "pgf"
     "babel"
     "francais")))

