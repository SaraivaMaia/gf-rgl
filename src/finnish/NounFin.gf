concrete NounFin of Noun = CatFin ** open ResFin, MorphoFin, StemFin, Prelude in {

  flags coding=utf8 ;
  lin

-- The $Number$ is subtle: "nuo autot", "nuo kolme autoa" are both plural
-- for verb agreement, but the noun form is singular in the latter.

    DetCN det cn =
      let
        n : Number = case det.isNum of {
          True => Sg ;
          _ => det.n
          } ;
        ncase : NPForm -> Case * NForm = \c ->
          let k = npform2case n c
          in
          case <n, c, det.isNum, det.isPoss, det.isDef> of {
            <_, NPAcc,       True,_,_>  => <Nom,NCase Sg Part> ; -- myin kolme kytkintä(ni)
            <_, NPCase Nom | NPSep,  True,_,_>  => <Nom,NCase Sg Part> ; -- kolme kytkintä(ni) on
            <_, _, True,False,_>        => <k,  NCase Sg k> ;    -- kolmeksi kytkimeksi
            <Pl,NPAcc,     _, _, False> => <k,  NCase Pl Part> ; -- myin kytkimiä
            <_, NPAcc,     _,True,_>    => <k,  NPossNom n> ;    -- myin kytkime+ni
            <_, NPCase Nom | NPSep,_,True,_>  => <k,  NPossNom n> ;    -- kytkime+ni on/ovat...
            <_, NPCase Gen,_,True,_>    => <k,  NPossGen n> ;    -- kytkime+ni vika
            <_, NPCase Transl,_,True,_> => <k,  NPossTransl n> ; -- kytkim(e|i)kse+ni
            <_, NPCase Illat,_,True,_>  => <k,  NPossIllat n> ;  -- kytkim(ee|ii)+ni

            _                           => <k,  NCase n k>       -- kytkin, kytkimen,...
            }
      in {
        s = \\c => let
                     k = ncase c ;
                   in
                     det.s1 ! k.p1 ++         -- minun
                     cn.s   ! k.p2 ++         -- kytkime
                     det.s2 ! cn.h ++         -- ni
                     cn.postmod ! numN k.p2 ; -- jonka/jotka myin
        a = agrP3 (case <det.isDef, det.isNum> of {
            <False,True> => Sg ;  -- kolme kytkintä on
            _ => det.n
            }) ;
      isPron = False ; isNeg = det.isNeg
      } ;

    DetNP det =
      let
        n : Number = case det.isNum of {
          True => Sg ;
          _ => det.n
          } ;
      in {
        s = \\c => let k = npform2case n c in
                 det.sp ! k ; -- det.s2 is possessive suffix
        a = agrP3 (case det.isDef of {
            False => Sg ;  -- autoja menee; kolme autoa menee
            _ => det.n
            }) ;
        isPron = False ; isNeg = det.isNeg
      } ;

    UsePN pn = {
      s = snoun2np Sg pn ;
      a = agrP3 Sg ;
      isPron = False ; isNeg = False
      } ;
    UsePron p = p ** {isPron = p.hasPoss ; isNeg = False} ;  -- to block "se"; possessive suffix is the only use of isPron

    PredetNP pred np = {
      s = \\c => pred.s ! complNumAgr np.a ! c ++ np.s ! c ;
      a = np.a ;
      isPron = np.isPron ;  -- kaikki minun - ni
      isNeg = np.isNeg
      } ;

    PPartNP np v2 = {
      s = \\c => np.s ! c ++ (sverb2verbSep v2).s ! PastPartPass (AN (NCase (complNumAgr np.a) Ess)) ;
      a = np.a ;
      isPron = np.isPron ;  -- minun täällä - ni
      isNeg = np.isNeg
      } ;

    AdvNP np adv = {
      s = \\c => np.s ! c ++ adv.s ;
      a = np.a ;
      isPron = np.isPron ;  -- minun täällä - ni
      isNeg = np.isNeg
      } ;

    ExtAdvNP np adv = {
      s = \\c => np.s ! c ++ embedInCommas adv.s ;
      a = np.a ;
      isPron = np.isPron ;  -- minun täällä - ni
      isNeg = np.isNeg
      } ;

    DetQuantOrd quant num ord = {
      s1 = \\c => quant.s1 ! num.n ! c ++ num.s ! Sg ! c ++ ord.s ! NCase num.n c ;
      sp = \\c => quant.s1 ! num.n ! c ++ num.s ! Sg ! c ++ ord.s ! NCase num.n c ;
      s2 = quant.s2 ;
      n = num.n ;
      isNum = num.isNum ;
      isPoss = quant.isPoss ;
      isDef = quant.isDef ;
      isNeg = quant.isNeg
      } ;

    DetQuant quant num = {
      s1 = \\c => quant.s1 ! num.n ! c ++ num.s ! Sg ! c ;
      sp = \\c => case num.isNum of {
         True  => quant.s1 ! num.n ! c ++ num.s ! Sg ! c ;   -- 0 kolme with Indef
         False => quant.sp ! num.n ! c ++ num.s ! Sg ! c     -- yksi 0
         } ;
      s2 = quant.s2 ;
      n = num.n ;
      isNum = num.isNum ; -- case num.n of {Sg => False ; _ => True} ;
      isPoss = quant.isPoss ;
      isDef = quant.isDef ; isNeg = quant.isNeg
      } ;

    PossPron p = {
      s1 = \\_,_ => p.poss ;           -- [] in det position with proDrop
      sp = \\_,_ => p.s ! NPCase Gen ; -- to prevent [] with proDrop
      s2 = case p.hasPoss of {
             True => table {Front => BIND ++ possSuffixFront p.a ;
                            Back  => BIND ++ possSuffix p.a } ;
             False => \\_ => []
             } ;
      isNum = False ;
      isPoss = p.hasPoss ;
      isDef = True ; --- "minun kolme autoani ovat" ; thus "...on" is missing
      isNeg = False
      } ;

    NumSg = {s = \\_,_ => [] ; isNum = False ; n = Sg} ;
    NumPl = {s = \\_,_ => [] ; isNum = False ; n = Pl} ;

    NumCard n = n ** {isNum = case n.n of {Sg => False ; _ => True}} ;  -- yksi talo/kaksi taloa

    NumDigits numeral = {
      s = \\n,c => numeral.s ! NCard (NCase n c) ;
      n = numeral.n
      } ;
    OrdDigits numeral = {s = \\f => numeral.s ! NOrd f} ;

    NumFloat n1 n2 = {
      s = \\n,c => n1.s ! NCard (NCase Sg Nom) ++ BIND ++ "." ++ BIND ++ n2.s ! NCard (NCase n c) ;
      n = Pl
      } ;

    NumNumeral numeral = {
      s = \\n,c => numeral.s ! NCard (NCase n c) ;
      n = numeral.n
      } ;
    OrdNumeral numeral = {s = \\f => numeral.s ! NOrd f} ;

    AdNum adn num = {
      s = \\n,c => adn.s ++ num.s ! n ! c ;
      n = num.n
      } ;

    OrdSuperl a = {s = sAdjFull2nforms Superl a ; h = a.h} ;

    OrdNumeralSuperl n a = -- kolmanneksi suurin
      {s = \\f => n.s ! NOrd (NCase Sg Transl) ++ (snoun2nounSep {s = \\nc => a.s ! Superl ! sAN nc ; h = a.h}).s ! f} ;

    DefArt = {
      s1 = \\_,_ => [] ;
      sp = table {Sg => pronSe.s ; Pl => pronNe.s} ;
      s2 = \\_ => [] ;
      isNum,isPoss,isNeg = False ;
      isDef = True   -- autot ovat
      } ;

    IndefArt = {
      s1 = \\_,_ => [] ; -- Nom is Part in Pl: use isDef in DetCN
      sp = \\n,c =>
         (nhn (mkSubst "ä" "yksi" "yhde" "yhte" "yhtä" "yhteen" "yksi" "yksi"
         "yksien" "yksiä" "yksiin")).s ! NCase n c ;
      s2 = \\_ => [] ;
      isNum,isPoss,isDef,isNeg = False -- autoja on
      } ;

    MassNP cn =
      let
        n : Number = Sg ;
        ncase : Case -> NForm = \c -> NCase n c ;
      in {
        s = \\c => let k = npform2case n c in
                cn.s ! ncase k ++ cn.postmod ! n ;
        a = agrP3 Sg ;
        isPron = False ; isNeg = False
      } ;

    UseN n = snoun2nounSep n ** {
      postmod = \\_ => []
      } ;

    UseN2 n = snoun2nounSep n ** {
      postmod = n.postmod
      } ;

    Use2N3 f = {
      s = f.s ;
      c2 = f.c2 ;
      h = f.h ;
      isPre = f.isPre ;
      postmod = \\_ => [] ;
      } ;
    Use3N3 f = {
      s = f.s ;
      c2 = f.c3 ;
      h = f.h ;
      isPre = f.isPre2 ;
      postmod = \\_ => [] ;
      } ;

    ComplN2 f x = {
      s = \\nf =>
        case f.isPre of {
          True  =>          cn.s ! nf ;
          False => compl ++ cn.s ! nf } ;
      postmod = \\num =>
        case f.isPre of { -- If N2 comes from ComplN3, postmod may be filled
          True  => cn.postmod ! num ++ compl ;
          False => cn.postmod ! num } ;
      h = f.h }
      where {
        compl : Str = appCompl True Pos f.c2 x ;
        cn : CN = UseN2 f ;
      } ;

    -- reuse the pre/post logic from ComplN2.
    -- we just need to make the N3 into the lincat of N2
    ComplN3 f x = ComplN2 (toN2 f) x ** {
      c2 = f.c3 ;
      isPre = f.isPre2 }
      where {
        toN2 : N3 -> N2 = \n3 -> lin N2 (n3 ** {postmod = \\_ => []})
      } ;

    AdjCN ap cn = cn ** {
      s = case ap.hasPrefix of {
            True  => \\nf => ap.p ++ BIND ++ cn.s ! nf ;
            False => \\nf => ap.s ! True ! (n2nform nf) ++ cn.s ! nf } ;
      h = cn.h } ;

    RelCN cn rs = cn ** {
      postmod = \\num => cn.postmod ! num ++ BIND ++ "," ++  rs.s ! agrP3 num ;
      } ;

    RelNP np rs = {
      s = \\c => np.s ! c ++ BIND ++ "," ++ rs.s ! np.a ;
      a = np.a ;
      isPron = np.isPron ; ---- correct ?
      isNeg = np.isNeg
      } ;

    AdvCN cn ad = cn ** {
      postmod = \\num => cn.postmod ! num ++ ad.s ;
      } ;

    SentCN cn sc = cn **{
      postmod = \\num => cn.postmod ! num ++ sc.s ;
      } ;

    ApposCN cn np = cn ** { -- luvun x
      postmod = \\num => cn.postmod ! num ++ np.s ! NPSep ;
      } ;

    PossNP cn np = cn ** {
      s = \\nf => np.s ! NPCase Gen ++ cn.s ! nf ;
      h = cn.h
      } ;

    PartNP cn np = cn ** {
      postmod = \\num => np.s ! NPCase Part ++ cn.postmod ! num ;
      } ;


    CountNP det np =
      let
        n : Number = case det.isNum of {
          True => Sg ;
          _ => det.n
          } ;
      in {
        s = \\c => let k = npform2case n c in
                   det.sp ! k ++ np.s ! NPCase Elat ; -- cf DetNP above
        a = agrP3 (case det.isDef of {
            False => Sg ;  -- autoja menee; kolme autoa menee
            _ => det.n
            }) ;
        isPron = False ; isNeg = det.isNeg
      } ;

    DetDAP d = d ;

    QuantityNP n m = {
      s = \\c => preOrPost m.isPre m.s (n.s ! NCard (NCase Sg Nom)) ;
      a = agrP3 n.n ;
      isPron = False ;
      isNeg = False
      } ;

    QuantityFloatNP n1 n2 m = {
      s = \\role => preOrPost m.isPre m.s (n1.s ! NCard (NCase Sg Nom) ++ BIND ++ "." ++ BIND ++ n2.s ! NCard (NCase Sg Nom)) ;
      a = agrP3 Pl ;
      isPron = False ;
      isNeg = False
      } ;

  oper
    numN : NForm -> Number = \nf -> case nf of {
      NCase n _ => n ;
      _ => Sg ---
      } ;


}
