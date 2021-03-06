redblack is package{
  -- inspired by Chris Okasaki's Purely Functional Data Structures
  -- and by Sedgwick's coursera course

  -- we only export the redblack type

  private type color is red or black;

  type redblack of (k,v) where comparable over k and equality over k is 
    E or
    N{
      color has type color;
      sze has type integer;
      lhs has type redblack of (k,v);
      ky has type k;
      vl has type v;
      rhs has type redblack of (k,v);

      sze default is size(lhs)+size(rhs)+1;
  --    assert color=red implies (not isRed(lhs) and not isRed(rhs))
  --    assert blackCount(lhs)=blackCount(rhs)
    };

  private 
  fun isRed(N{color=red}) is true
   |  isRed(_) default is false

  private
  fun isBlack(E) is true
   |  isBlack(N{color=black}) is true
   |  isBlack(_) default is false

  private
  fun rbMember(_,E) is false
   |  rbMember(x,Nd) is
        x<Nd.ky ? rbMember(x,Nd.lhs) :
        x>Nd.ky ? rbMember(x,Nd.rhs) :
        x=Nd.ky

  private
  fun rbFind(_,E) is none
   |  rbFind(x,Nd) is
        x<Nd.ky ? rbFind(x,Nd.lhs) :
        x>Nd.ky ? rbFind(x,Nd.rhs) :
        x=Nd.ky ? some(Nd.vl) :
        none;

  implementation indexable over redblack of (%k,%v) determines (%k,%v) is {
    fun _index(L,Ky) is rbFind(Ky,L)
    fun _set_indexed(L,Ix,El) is rbInsert(Ix,El,L)
    fun _delete_indexed(L,Ix) is rbDelete(L,Ix)
  }

  private
  fun rbInsert(ky,vl,S) is let{
    fun ins(E) is N{color=red;lhs=E;ky=ky;vl=vl;rhs=E}
     |  ins(N{color=C;lhs=L;ky=k;vl=v;rhs=R}) is valof{
          var h := ky<k?N{color=C;lhs=ins(L);ky=k;vl=v;rhs=R} :
                  	ky>k?N{color=C;lhs=L;ky=k;vl=v;rhs=ins(R)} :
                	  N{color=C;lhs=L;ky=k;vl=v;rhs=R};

          logMsg(info,"h before adjustment: #(__display(h))");

          if isRed(h.rhs) and isBlack(h.lhs) then
          	h := rotateLeft(h);
          if isRed(h.lhs) and isRed(h.lhs.lhs) then
          	h := rotateRight(h);
          if isRed(h.lhs) and isRed(h.rhs) then
          	h := flipColors(h);

          logMsg(info,"h after adjustment: #(__display(h))");

          valis h;
        };
  } in ins(S) substitute { color=black }

  private
  fun rotateLeft(N{color=C;lhs=h;ky=k;vl=v;rhs=N{lhs=x;ky=kS;vl=vS;rhs=y}}) is 
        N{color=C;lhs=N{color=red;lhs=h;ky=k;vl=v;rhs=x};ky=kS;vl=vS;rhs=y};

  private
  fun rotateRight(N{color=C;lhs=N{lhs=x;ky=kE;vl=vE;rhs=y};ky=kS;vl=vS;rhs=z}) is
        N{color=C;lhs=x;ky=kE;vl=vE;rhs=N{color=red;lhs=y;ky=kS;vl=vS;rhs=z}};

  private
  fun flipColors(N{lhs=N{lhs=x;ky=kA;vl=vA;rhs=y};
      ky=kE;vl=vE;
      rhs=N{lhs=z;ky=kS;vl=vS;rhs=u}}) is
    N{color=red;lhs=N{color=black;lhs=x;ky=kA;vl=vA;rhs=y};
      ky=kE;vl=vE;
      rhs=N{color=black;lhs=z;ky=kS;vl=vS;rhs=u}};

  -- eliminate double reds
  private
  fun balance(N{color=black;lhs=N{color=red;lhs=N{color=red;lhs=A;ky=xK;vl=xV;rhs=B};ky=yK;vl=yV;rhs=C};
      ky=zK;vl=zV;rhs=D}) is
    N{color=red;lhs=N{color=black;lhs=A;ky=xK;vl=xV;rhs=B};ky=yK;vl=yV;
        rhs=N{color=black;lhs=C;ky=zK;vl=zV;rhs=D}}
   |  balance(N{color=black;lhs=N{color=red;lhs=A;ky=xK;vl=xV;rhs=N{color=red;lhs=B;ky=yK;vl=yV;rhs=C}};
      ky=zK;vl=zV;rhs=D}) is
        N{color=red;lhs=N{color=black;lhs=A;ky=xK;vl=xV;rhs=B};ky=yK;vl=yV;
          rhs=N{color=black;lhs=C;ky=zK;vl=zV;rhs=D}}
   |  balance(N{color=black;lhs=A;ky=xK;vl=xV;rhs=N{color=red;lhs=N{color=red;lhs=B;ky=yK;vl=yV;rhs=C};
    	ky=zK;vl=zV;rhs=D}}) is
        N{color=red;lhs=N{color=black;lhs=A;ky=xK;vl=xV;rhs=B};ky=yK;vl=yV;
          rhs=N{color=black;lhs=C;ky=zK;vl=zV;rhs=D}}
   |  balance(N{color=black;lhs=A;ky=xK;vl=xV;rhs=N{color=red;lhs=B;ky=yK;vl=yV;rhs=N{color=red;lhs=C;
      ky=zK;vl=zV;rhs=D}}}) is
        N{color=red;lhs=N{color=black;lhs=A;ky=xK;vl=xV;rhs=B};ky=yK;vl=yV;
          rhs=N{color=black;lhs=C;ky=zK;vl=zV;rhs=D}}
   |  balance(nd) default is nd

  private
  fun rbDelete(E,_) is E
   |  rbDelete(N{color=C;lhs=L;ky=k;vl=v;rhs=R},K) where K<k is balance(N{color=C;lhs=rbDelete(L,K);ky=k;vl=v;rhs=R})
   |  rbDelete(N{color=C;lhs=L;ky=k;vl=v;rhs=R},K) where K>k is balance(N{color=C;lhs=L;ky=k;vl=v;rhs=rbDelete(R,K)})
   |  rbDelete(N{lhs=E;ky=K;rhs=E},K) is E
   |  rbDelete(N{lhs=L;ky=K;rhs=E},K) is L substitute {color=black}
   |  rbDelete(N{lhs=E;ky=K;rhs=R},K) is R substitute {color=black}
   |  rbDelete(N{color=C;lhs=L;ky=K;rhs=R},K) is valof{
        def (k,v,L1) is deleteMax(L);
        valis balance(N{color=C;lhs=L1;ky=k;vl=v;rhs=R})
      }
  
  private
  fun deleteMin(N{lhs=E;ky=k;vl=v;rhs=R}) is (k,v,R)
   |  deleteMin(N{color=C;lhs=L;ky=k;vl=v;rhs=R}) is valof{
        def (k1,v1,L1) is deleteMin(L);
        valis (k1,v1,balance(N{color=C;lhs=L1;ky=k;vl=v;rhs=R}))
      };

  private
  fun deleteMax(N{lhs=L;ky=k;vl=v;rhs=E}) is (k,v,L)
   |  deleteMax(N{color=C;lhs=L;ky=k;vl=v;rhs=R}) is valof{
        def (k1,v1,R1) is deleteMax(R);
        valis (k1,v1,balance(N{color=C;lhs=L;ky=k;vl=v;rhs=R1}))
      };

  implementation sizeable over redblack of (%k,%t) is {
    fun size(E) is 0
     |  size(N{sze=S}) is S

    fun isEmpty(E) is true
     |  isEmpty(_) default is false
  }

  implementation sequence over redblack of (%k,%v) determines ((%k,%v)) is {
    fun _nil() is E
    fun _cons((K,V),T) is rbInsert(K,V,T)
    fun _apnd(T,(K,V)) is rbInsert(K,V,T)

    ptn _pair((K,V),T) from Tr where deleteMin(Tr) matches (K,V,T)
    ptn _back(T,(K,V)) from Tr where deleteMax(Tr) matches (K,V,T)

    ptn _empty() from E
  }

  private 
  fun ixIterate(E,_,St) is St
   |  ixIterate(N{lhs=L;ky=k;vl=v;rhs=R},F,St) is
        ixNext(ixIterate(L,F,St),F,k,v,R)
  
  private
  fun ixNext(NoMore(X),_,_,_,_) is NoMore(X)
   |  ixNext(St,F,k,v,R) is ixIterate(R,F,F(k,v,St))

  implementation iterable over redblack of (%k,%v) determines %v is {
    fun _iterate(M,F,S) is ixIterate(M,(iX,iY,St) => F(iY,St),S)
  }

  implementation indexed_iterable over redblack of (%k,%v) determines (%k,%v) is {
    fun _ixiterate(M,F,S) is ixIterate(M,F,S)
  }

  private 
  fun left(_,S,E) is S
   |  left(F,S,N{lhs=L;vl=V;rhs=R}) is left(F,F(left(F,S,L),V),R)
  
  private
  fun right(_,S,E) is S
   |  right(F,S,N{lhs=L;vl=V;rhs=R}) is right(F,F(V,right(F,S,R)),L)
}