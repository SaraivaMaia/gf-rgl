--1 Extensions of core RGL syntax (the Grammar module)

-- This module defines syntax rules that are not yet implemented in all
-- languages, and perhaps never implementable either. But all rules are given
-- a default implementation in common/ExtendFunctor.gf so that they can be included
-- in the library API. The default implementations are meant to be overridden in each
-- xxxxx/ExtendXxx.gf when the work proceeds.
--
-- This module is aimed to replace the original Extra.gf, which is kept alive just
-- for backwardcommon compatibility. It will also replace translator/Extensions.gf
-- and thus eliminate the often duplicated work in those two modules.
--
-- (c) Aarne Ranta 2017-08-20 under LGPL and BSD


abstract Extend = Cat ** {

  fun
    GenNP       : NP -> Quant ;       -- this man's
    GenIP       : IP -> IQuant ;      -- whose
    GenRP       : Num -> CN -> RP ;   -- whose car

-- In case the first two are not available, the following applications should in any case be.

    GenModNP    : Num -> NP -> CN -> NP ; -- this man's car(s)
    GenModIP    : Num -> IP -> CN -> IP ; -- whose car(s)

    CompBareCN  : CN -> Comp ;        -- (is) teacher

    StrandQuestSlash : IP -> ClSlash -> QCl ;   -- whom does John live with
    StrandRelSlash   : RP -> ClSlash -> RCl ;   -- that he lives in
    EmptyRelSlash    : ClSlash       -> RCl ;   -- he lives in


-- $VP$ conjunction, separate categories for finite and infinitive forms (VPS and VPI, respectively)
-- covering both in the same category leads to spurious VPI parses because VPS depends on many more tenses

  cat
    VPS ;           -- finite VP's with tense and polarity
    [VPS] {2} ;
    VPI ;
    [VPI] {2} ;     -- infinitive VP's (TODO: with anteriority and polarity)

  fun
    MkVPS      : Temp -> Pol -> VP -> VPS ;  -- hasn't slept
    ConjVPS    : Conj -> [VPS] -> VPS ;      -- has walked and won't sleep
    PredVPS    : NP   -> VPS -> S ;          -- she [has walked and won't sleep]
    SQuestVPS  : NP   -> VPS -> QS ;         -- has she walked
    QuestVPS   : IP   -> VPS -> QS ;         -- who has walked
    RelVPS     : RP   -> VPS -> RS ;         -- which won't sleep

-- existentials that work in the absence of Cl
    ExistS     : Temp -> Pol -> NP -> S ;    -- there was a party
    ExistNPQS  : Temp -> Pol -> NP -> QS ;   -- was there a party
    ExistIPQS  : Temp -> Pol -> IP -> QS ;   -- what was there

    MkVPI      : VP -> VPI ;                 -- to sleep (TODO: Ant and Pol)
    ConjVPI    : Conj -> [VPI] -> VPI ;      -- to sleep and to walk
    ComplVPIVV : VV   -> VPI -> VP ;         -- must sleep and walk

-- the same for VPSlash, taking a complement with shared V2 verbs

  cat
    VPS2 ;        -- have loved (binary version of VPS)
    [VPS2] {2} ;  -- has loved, hates"
    VPI2 ;        -- to love (binary version of VPI)
    [VPI2] {2} ;  -- to love, to hate

  fun
    MkVPS2    : Temp -> Pol -> VPSlash -> VPS2 ;  -- has loved
    ConjVPS2  : Conj -> [VPS2] -> VPS2 ;          -- has loved and now hates
    ComplVPS2 : VPS2 -> NP -> VPS ;               -- has loved and now hates that person
    ReflVPS2  : VPS2 -> RNP -> VPS ;              -- have loved and now hate myself and my car

    MkVPI2    : VPSlash -> VPI2 ;                 -- to love
    ConjVPI2  : Conj -> [VPI2] -> VPI2 ;          -- to love and hate
    ComplVPI2 : VPI2 -> NP -> VPI ;               -- to love and hate that person

-- Conjunction of copula complements
  cat [Comp]{2} ;
  fun ConjComp : Conj -> ListComp -> Comp ;

-- Conjunction of imperatives
  cat [Imp] {2} ;
  fun ConjImp : Conj -> ListImp -> Imp ;

  fun
    ProDrop : Pron -> Pron ;  -- unstressed subject pronoun becomes empty: "am tired"

    ICompAP : AP -> IComp ;   -- "how old"
    IAdvAdv : Adv -> IAdv ;   -- "how often"

    CompIQuant : IQuant -> IComp ;   -- which (is it) [agreement to NP]

    PrepCN     : Prep -> CN -> Adv ; -- by accident [Prep + CN without article]

  -- fronted/focal constructions, only for main clauses

  fun
    FocusObj : NP  -> SSlash  -> Utt ;   -- her I love
    FocusAdv : Adv -> S       -> Utt ;   -- today I will sleep
    FocusAdV : AdV -> S       -> Utt ;   -- never will I sleep
    FocusAP  : AP  -> NP      -> Utt ;   -- green was the tree

  -- participle constructions
    PresPartAP    : VP -> AP ;   -- (the man) looking at Mary
    EmbedPresPart : VP -> SC ;   -- looking at Mary (is fun)

    PastPartAP      : VPSlash -> AP ;         -- lost (opportunity) ; (opportunity) lost in space
    PastPartAgentAP : VPSlash -> NP -> AP ;   -- (opportunity) lost by the company

-- this is a generalization of Verb.PassV2 and should replace it in the future.

    PassVPSlash : VPSlash -> VP ; -- be forced to sleep

-- the form with an agent may result in a different linearization
-- from an adverbial modification by an agent phrase.

    PassAgentVPSlash : VPSlash -> NP -> VP ;  -- be begged by her to go

-- publishing of the document

    NominalizeVPSlashNP : VPSlash -> NP -> NP ;

-- counterpart to ProgrVP, for VPSlash

    ProgrVPSlash : VPSlash -> VPSlash;

-- construct VPSlash from A2 and N2

    A2VPSlash : A2 -> VPSlash ; -- is married to (that person)
    N2VPSlash : N2 -> VPSlash ; -- is a mother of (that person)

-- existential for mathematics

    ExistsNP : NP -> Cl ;  -- there exists a number / there exist numbers

-- existentials with a/no variation

    ExistCN       : CN -> Cl ;  -- there is a car / there is no car
    ExistMassCN   : CN -> Cl ;  -- there is beer / there is no beer
    ExistPluralCN : CN -> Cl ;  -- there are trees / there are no trees

-- generalisation of existential, with adverb as an argument
    AdvIsNP : Adv -> NP -> Cl ;  -- here is the tree / here are the trees
    AdvIsNPAP : Adv -> NP -> AP -> Cl ; -- here are the instructions documented

-- infinitive for purpose AR 21/8/2013

    PurposeVP : VP -> Adv ;  -- to become happy

-- object S without "that"

    ComplBareVS  : VS  -> S  -> VP ;       -- say she runs
    SlashBareV2S : V2S -> S  -> VPSlash ;  -- answer (to him) it is good

    ComplDirectVS : VS -> Utt -> VP ;      -- say: "today"
    ComplDirectVQ : VQ -> Utt -> VP ;      -- ask: "when"

-- front the extraposed part

    FrontComplDirectVS : NP -> VS -> Utt -> Cl ;      -- "I am here", she said
    FrontComplDirectVQ : NP -> VQ -> Utt -> Cl ;      -- "where", she asked

-- proper structure of "it is AP to VP"

    PredAPVP : AP -> VP -> Cl ;      -- it is good to walk

-- to use an AP as CN or NP without CN

    AdjAsCN : AP -> CN ;   -- a green one ; en grön (Swe)
    AdjAsNP : AP -> NP ;   -- green (is good)

-- infinitive complement for IAdv

    PredIAdvVP : IAdv -> VP -> QCl ; -- how to walk?

-- alternative to EmbedQS. For English, EmbedQS happens to work,
-- because "what" introduces question and relative. The default linearization
-- could be e.g. "the thing we did (was fun)".

    EmbedSSlash : SSlash -> SC  ;   -- what we did (was fun)

-- reflexive noun phrases: a generalization of Verb.ReflVP, which covers just reflexive pronouns
-- This is necessary in languages like Swedish, which have special reflexive possessives.
-- However, it is also needed in application grammars that want to treat "brush one's teeth" as a one-place predicate.

  cat
    RNP ;     -- reflexive noun phrase, e.g. "my family and myself"
    RNPList ; -- list of reflexives to be coordinated, e.g. "my family, myself, everyone"

-- Notice that it is enough for one NP in RNPList to be RNP.

  fun
    ReflRNP : VPSlash -> RNP -> VP ;   -- love my family and myself

    ReflPron : RNP ;                   -- myself
    ReflPoss : Num -> CN -> RNP ;      -- my car(s)

    PredetRNP : Predet -> RNP -> RNP ; -- all my brothers

    AdvRNP : NP -> Prep -> RNP -> RNP ;   -- a dispute with his wife
    AdvRVP : VP -> Prep -> RNP -> VP ;    -- lectured about her travels
    AdvRAP : AP -> Prep -> RNP -> AP ;    -- adamant in his refusal

    ReflA2RNP : A2 -> RNP -> AP ;         -- indifferent to their surroundings
                                               -- NOTE: generalizes ReflA2

    PossPronRNP : Pron -> Num -> CN -> RNP -> NP ; -- his abandonment of his wife and children

    ConjRNP : Conj -> RNPList -> RNP ;  -- my family, John and myself

    Base_rr_RNP : RNP -> RNP -> RNPList ;       -- my family, myself
    Base_nr_RNP : NP  -> RNP -> RNPList ;       -- John, myself
    Base_rn_RNP : RNP -> NP  -> RNPList ;       -- myself, John
    Cons_rr_RNP : RNP -> RNPList -> RNPList ;   -- my family, myself, John
    Cons_nr_RNP : NP  -> RNPList -> RNPList ;   -- John, my family, myself
----    Cons_rn_RNP : RNP -> ListNP  -> RNPList ;   -- myself, John, Mary

-- reflexive possessive on its own right, like in Swedish, Czech, Slovak

    ReflPossPron : Quant ;  -- Swe sin,sitt,sina

--- from Extensions

  ComplGenVV  : VV -> Ant -> Pol -> VP  -> VP ;         -- want not to have slept
----  SlashV2V    : V2V -> Ant -> Pol -> VPS -> VPSlash ;   -- force (her) not to have slept

  CompoundN   : N -> N  -> N ;      -- control system / controls system / control-system
  CompoundAP  : N -> A  -> AP ;     -- language independent / language-independent

  GerundCN    : VP -> CN ;          -- publishing of the document (can get a determiner)
  GerundNP    : VP -> NP ;          -- publishing the document (by nature definite)
  GerundAdv   : VP -> Adv ;         -- publishing the document (prepositionless adverb)

  WithoutVP   : VP -> Adv ;         -- without publishing the document
  ByVP        : VP -> Adv ;         -- by publishing the document
  InOrderToVP : VP -> Adv ;         -- (in order) to publish the document

  ApposNP : NP -> NP -> NP ;        -- Mr Macron, the president of France,

  AdAdV       : AdA -> AdV -> AdV ;           -- almost always
  UttAdV      : AdV -> Utt ;                  -- always(!)
  PositAdVAdj : A -> AdV ;                    -- (that she) positively (sleeps)

  CompS       : S -> Comp ;                   -- (the fact is) that she sleeps
  CompQS      : QS -> Comp ;                  -- (the question is) who sleeps
  CompVP      : Ant -> Pol -> VP -> Comp ;    -- (she is) to go

-- very language-specific things

-- Eng
  UncontractedNeg : Pol ;      -- do not, etc, as opposed to don't
  UttVPShort : VP -> Utt ;     -- have fun, as opposed to "to have fun"
  ComplSlashPartLast : VPSlash -> NP -> VP ; -- set it apart, as opposed to "set apart it"

-- Romance
  DetNPMasc : Det -> NP ;
  DetNPFem  : Det -> NP ;

  UseComp_estar : Comp -> VP ; -- (Cat, Spa, Por) "está cheio" instead of "é cheio"

  SubjRelNP : NP -> RS -> NP ; -- Force RS in subjunctive: lo que les *resulte* mejor

  iFem_Pron      : Pron ; -- I (Fem)
  youFem_Pron    : Pron ; -- you (Fem)
  weFem_Pron     : Pron ; -- we (Fem)
  youPlFem_Pron  : Pron ; -- you plural (Fem)
  theyFem_Pron   : Pron ; -- they (Fem)
  theyNeutr_Pron : Pron ; -- they (Neutr)
  youPolFem_Pron : Pron ; -- you polite (Fem)
  youPolPl_Pron  : Pron ; -- you polite plural (Masc)
  youPolPlFem_Pron : Pron ; -- you polite plural (Fem)

-- German
  UttAccNP : NP -> Utt ; -- him (accusative)
  UttDatNP : NP -> Utt ; -- him (dative)
  UttAccIP : IP -> Utt ; -- whom (accusative)
  UttDatIP : IP -> Utt ; -- whom (dative)


-- UseDAP replaces DetNP from the RGL which is more limited.
-- Instead of (DetNP d) use (UseDAP (DetDAP d)). The advantage
-- is that now we can also have an adjective inserted, i.e.
-- (UseDAP (AdjDAP (DetDAP d) a). There are also versions of
-- UseDAP for different genders.
fun UseDAP     : DAP -> NP ;
    UseDAPMasc : DAP -> NP ;
    UseDAPFem  : DAP -> NP ;

cat X ; -- for words that are difficult to classify, mainly for MorphoDict

fun
  UseComp_estar : Comp -> VP ; -- esta lleno, as opposed to es lleno
  UseComp_ser : Comp -> VP ; -- es lleno, as opposed to esta lleno

fun
  CardCNCard : Card -> CN -> Card ;  -- three million, four lakh, six dozen etc

fun
  AnaphPron : NP -> Pron ;

}
