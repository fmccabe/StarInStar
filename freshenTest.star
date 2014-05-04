import worksheet
worksheet{
  import freshen;
  import types;

  show iFnTp(iTuple(list of {iType("string");iType("integer")}),
      iType("float"))

  idType is iUniv("t",iFnTp(iTuple(list of {iBvar("t")}),iBvar("t")))

  show idType;

  show freshenForUse(idType);

  show freshenForEvidence(idType);

  lType is iTpExp(iType("list"),iType("string"))

  show lType;

  -- map type
  mpType is iUniv("s",iUniv("t",
	iFnTp(iTuple(list of {
	    iFnTp(iTuple(list of {iBvar("s")}),iBvar("t"));
	    iTpExp(iType("list"),iBvar("s"))}),
	  iTpExp(iType("list"),iBvar("t")))));

  show mpType;
  show freshenForUse(mpType);
  show freshenForEvidence(mpType);

  -- record types
  rcType is iUniv("s",iExists("t",
	iRecord(
	map of {
	  "name" -> iType("string");
	  "id" -> iBvar("t");
	  "mp" -> iFnTp(iTuple(list of {iBvar("s")}),iBvar("t"))
	},
	  map of {
	    "t" -> kType
	  }
	)))

  show rcType;
  show freshenForUse(rcType);
  show freshenForEvidence(rcType);
}

  