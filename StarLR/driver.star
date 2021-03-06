driver is package{
  private import lrTypes;

  -- implement a parser that handles the tables generated.

  fun driver(actions,goto) is let {
    fun parser(tokens) is valof{
      var stk := cons of [0];
      var state := 0;
      var output := cons of [];
      var Toks := tokens;

      while Toks matches list of [Tk,..Rest] do {
    		def pA is actions[state][Tk];

    		if isEmpty(pA) then{
    		  logMsg(info,"error state: $state:$Tk");
    		  valis none;
    		} else{
    		  if size(pA)>1 then
    		    logMsg(info,"multiple actions: $pA in $state:$Tk");

    		  switch (pA[0]) in {
    		    case shiftTo(Sno) do {
    		      logMsg(info,"shift on $Tk to $Sno");
    		      stk := [Sno,..stk];
    		      state := Sno;
    		      Toks := Rest;
    		    }
    		    case reduceBy(Nt,Rno,Cnt) do {
    		      stk := drop(stk,Cnt);
    		      state := goto[stk[0]][Nt];
    		      stk := [state,..stk];
    		      logMsg(info,"reduce $Nt by $Rno -> $state");
    		    }
    		    case accept(Rno) do {
    		      logMsg(info,"accept state by $Rno");
    		      valis some(stk);
    		    }
    		  }
    		}
      };
      valis none;
    };
  } in parser;

  private fun drop(L,Cnt) is L[Cnt:];

  fun glrDriver(actions,goto) is let{

    fun reduceState(Stk,Cnt,Nt) is valof{
      logMsg(info,"reducing $Stk by $Cnt");
      
      def nStk is Stk[Cnt:];
      valis cons of [goto[nStk[0]][Nt],..nStk]
    }

    fun parser(tokens) is valof{
      var stacks := cons of [cons of [0]];

      for Tk in tokens do {
      	var pathQ := queue of [];

      	for stk in stacks do {
      	  for reduceBy(Nt,Rno,Cnt) in actions[stk[0]][Tk] do 
      	    pathQ := [pathQ..,(Nt,Rno,Cnt,stk)]
      	};

      	while not isEmpty(pathQ) do {
      	  def (Nt,Rno,Cnt,Stk) is qHead(pathQ);
      	  logMsg(info,"reducing $Nt using $Rno");
      	  pathQ := qTail(pathQ);
      	  logMsg(info,"pathQ now $pathQ");

      	  def rStk is reduceState(Stk,Cnt,Nt);

      	  logMsg(info,"rStk is $rStk");

      	  for A in actions[rStk[0]][Tk] do{
      	    switch A in {
      	      case reduceBy(xNt,xRno,xCnt) do 
            		pathQ := [pathQ..,(xNt,xRno,xCnt,rStk)];
      	      case _ default do
            		stacks := [rStk,..stacks]
      	    }
      	  }
      	  logMsg(info,"pathQ now $pathQ");
      	}
      	
      	var nStks := cons of [];
      	for stk in stacks do {
      	  for A in actions[stk[0]][Tk] do {
      	    switch A in {
      	      case shiftTo(Sno) do {
            		logMsg(info,"shift on $Tk to $Sno");
            		nStks := [[Sno,..stk],..nStks];
      	      }
      	      case accept(Rno) do {
            		logMsg(info,"accept state by $Rno");
            		valis some(stk)
      	      }
      	      case _ default do nothing;
      	    }
      	  }
      	}
      	stacks := nStks;
      };
      valis none;
    };
  } in parser;

  private qHead(queue of [H,.._]) is H;
  private qTail(queue of [_,..T]) is T;
}
	    
