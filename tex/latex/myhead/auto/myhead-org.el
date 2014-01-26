(TeX-add-style-hook "myhead-org"
 (lambda ()
    (LaTeX-add-environments
     "enumtwo"
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
     '("nohead" ["argument"] 0)
     '("header" ["argument"] 1)
     '("NoVariables" ["argument"] 1)
     '("Variables" ["argument"] 1)
     '("mr" 1)
     '("mdr" 1)
     '("dr" 1)
     '("mseg" 1)
     '("interval" 2)
     '("seg" 1)
     '("vcoord" 2)
     '("vectr" 1)
     '("dset" 2)
     '("set" 1)
     '("pa" 1)
     '("languagepath" 1)
     '("uselanguage" 1)
     '("mytan" 3)
     '("myfend" 3)
     '("myfcont" 3)
     '("myfstart" 3)
     '("Affect" 2)
     '("Ecrire" 1)
     '("Resultat" 1)
     '("Entree" 1)
     '("Lire" 1)
     '("Entrees" 1)
     "itemtwo"
     "ExoName"
     "nomprenom"
     "dsum"
     "doplus"
     "dint"
     "dlim"
     "dfrac"
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
     "amssymb"
     "amsthm"
     "amstext"
     "amsfonts"
     "array"
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

