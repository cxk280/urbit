{-# LANGUAGE UndecidableInstances #-}

module Vere.Pier.Types where

import UrbitPrelude
import Urbit.Time

import qualified Vere.Ames        as Ames
import qualified Vere.Http.Client as Client
import qualified Vere.Http.Server as Server

--------------------------------------------------------------------------------

newtype ShipId = ShipId (Ship, Bool)
  deriving newtype (Eq, Ord, Show, ToNoun, FromNoun)

newtype Octs = Octs ByteString
  deriving newtype (Eq, Ord, Show, FromNoun, ToNoun)

newtype FileOcts = FileOcts ByteString
  deriving newtype (Eq, Ord, ToNoun, FromNoun)

newtype BigTape = BigTape Text
  deriving newtype (Eq, Ord, ToNoun, FromNoun)

type Life = Noun
type Pass = Noun
type Turf = Noun
type PUrl = Todo Noun
type Seed = Todo Noun
type Czar = Todo Noun -- Map Ship (Life, Pass)
type Bloq = Todo Atom -- @ud

newtype Todo a = Todo a
  deriving newtype (Eq, Ord, ToNoun, FromNoun)

instance Show (Todo a) where
  show (Todo _) = "TODO"

data Dawn = MkDawn
    { dSeed :: Seed
    , dShip :: Ship
    , dCzar :: Czar
    , dTurf :: [Turf]
    , dBloq :: Bloq
    , dNode :: PUrl
    }
  deriving (Eq, Ord, Show)

data LegacyBootEvent
    = Fake Ship
    | Dawn Dawn
  deriving (Eq, Ord, Show)

newtype Nock = Nock Noun
  deriving newtype (Eq, Ord, FromNoun, ToNoun)

data Pill = Pill
    { pBootFormulas   :: [Nock]
    , pKernelOvums    :: [RawOvum]
    , pUserspaceOvums :: [RawOvum]
    }
  deriving (Eq, Ord)

data LogIdentity = LogIdentity
    { who          :: Ship
    , isFake       :: Bool
    , lifecycleLen :: Word
    } deriving (Eq, Ord, Show)

data BootSeq = BootSeq LogIdentity [Nock] [RawOvum]
  deriving (Eq, Ord, Show)

newtype Desk = Desk Text
  deriving newtype (Eq, Ord, Show, ToNoun, FromNoun)

data Mime = Mime Path FileOcts
  deriving (Eq, Ord, Show)

type EventId = Word64


-- Jobs ------------------------------------------------------------------------

data Work = Work EventId Mug Wen RawOvum
  deriving (Eq, Ord, Show)

data LifeCyc = LifeCyc EventId Mug Nock
  deriving (Eq, Ord, Show)

data Job
    = DoWork Work
    | RunNok LifeCyc
  deriving (Eq, Ord, Show)

jobId :: Job -> EventId
jobId (RunNok (LifeCyc eId _ _)) = eId
jobId (DoWork (Work eId _ _ _))  = eId

jobMug :: Job -> Mug
jobMug (RunNok (LifeCyc _ mug _)) = mug
jobMug (DoWork (Work _ mug _ _))  = mug


--------------------------------------------------------------------------------

data Order
    = OBoot LogIdentity
    | OExit Word8
    | OSave EventId
    | OWork Job
  deriving (Eq, Ord, Show)

data ResponseHeader = ResponseHeader
    { rhStatus  :: Word
    , rhHeaders :: [(Text, Text)]
    }
  deriving (Eq, Ord, Show)

data HttpEvent
    = Start ResponseHeader (Maybe Octs) Bool
    | Continue (Maybe Octs) Bool
    | Cancel
  deriving (Eq, Ord, Show)

data Lane
    = If Wen Atom Atom           --  {$if p/@da q/@ud r/@if}
    | Is Atom (Maybe Lane) Atom  --  {$is p/@ud q/(unit lane) r/@is}
    | Ix Wen Atom Atom           --  {$ix p/@da q/@ud r/@if}
  deriving (Eq, Ord, Show)

data ArrowKey = D | L | R | U
  deriving (Eq, Ord, Show)

data Address
    = AIpv4 Atom -- @if
    | AIpv6 Atom -- @is
    | AAmes Atom -- @p
  deriving (Eq, Ord, Show)

instance ToNoun Address where
  toNoun = \case
    AIpv4 x -> toNoun (Cord "ipv4", x)
    AIpv6 x -> toNoun (Cord "ipv6", x)
    AAmes x -> toNoun (Cord "ames", x)

instance FromNoun Address where
  parseNoun n = do
    parseNoun n >>= \case
      (Cord "ipv4", at) -> pure (AIpv4 at)
      (Cord "ipv6", at) -> pure (AIpv6 at)
      (Cord "ames", at) -> pure (AAmes at)
      _                 -> fail "Address must be either %ipv4, %ipv6, or %ames"

data Belt
    = Aro ArrowKey
    | Bac
    | Ctl Char
    | Del
    | Met Char
    | Ret
    | Txt Tour
  deriving (Eq, Ord, Show)

type ServerId = Atom

type JSON = Todo Noun

data RequestParams
    = List [JSON]
    | Object [(Text, JSON)]
  deriving (Eq, Ord, Show)

data HttpRequest = HttpRequest
    { reqId       :: Text
    , reqUrl      :: Text
    , reqHeaders  :: [(Text, Text)]
    , reqFinished :: Maybe Octs
    }
  deriving (Eq, Ord, Show)

data Event
    = Veer Cord Path BigTape
    | Into Desk Bool [(Path, Maybe Mime)]
    | Whom Ship
    | Boot LegacyBootEvent
    | Wack Word512
    | Boat
    | Barn
    | Born
    | Blew Word Word
    | Hail
    | Wake
    | Receive ServerId HttpEvent
    | Request ServerId Address HttpRequest
    | Live Text Bool Word
    | Hear Lane Atom
    | Belt Belt
    | Crud Text [Tank]
  deriving (Eq, Ord, Show)

data PutDel = PDPut | PDDel
  deriving (Eq, Ord, Show)

instance ToNoun PutDel where
  toNoun = \case PDPut -> toNoun (Cord "put")
                 PDDel -> toNoun (Cord "del")

instance FromNoun PutDel where
  parseNoun n = do
    parseNoun n >>= \case
      Cord "put" -> pure PDPut
      Cord "del" -> pure PDDel
      _          -> fail "PutDel must be either %put or %del"

data RecEx = RE Word Word
  deriving (Eq, Ord, Show)

data NewtEx = NE Word
  deriving (Eq, Ord, Show)

data Eff
    = EHttpServer Server.Eff
    | EHttpClient Client.Eff
    | EAmes Ames.Eff
    | EBbye Noun
    | EBehn Noun
    | EBlit [Blit]
    | EBoat Noun
    | EClay Noun
    | ECrud Noun
    | EDirk Noun
    | EDoze (Maybe Wen)
    | EErgo Noun
    | EExit Noun
    | EFlog Noun
    | EForm Noun
    | EHill [Term]
    | EInit
    | ELogo Noun
    | EMass Noun
    | ENewt Noun
    | EOgre Noun
    | ESend [Blit]
    | ESync Noun
    | ETerm Noun
    | EThou Noun
    | ETurf (Maybe (PutDel, [Text])) -- TODO Unsure
    | EVega Noun
    | EWest Noun
    | EWoot Noun
  deriving (Eq, Ord, Show)

data Blit
    = Bel
    | Clr
    | Hop Word64
    | Lin [Char]
    | Mor
    | Sag Path Noun
    | Sav Path Atom
    | Url Text
  deriving (Eq, Ord, Show)

data Varience = Gold | Iron | Lead

type Perform = Eff -> IO ()

data RawOvum = Ovum Path Event
  deriving (Eq, Ord, Show)

--------------------------------------------------------------------------------

{-
    This parses an ovum in a slightly complicated way.

    The Ovum structure is not setup to be easily parsed into typed data,
    since the type of the event depends on the head of the path, and
    the shape of the rest of the path depends on the shape of the event.

    To make parsing easier (indeed, to allow use to use `deriveEvent` to
    generate parsers for this) we first re-arrange the data in the ovum.

    And ovum is `[path event]`, but the first two fields of the path
    are used for routing, the event is always a head-tagged structure,
    and the rest of the path is basically data that's a part of the event.

    So, we take something with this struture:

        [[fst snd rest] [tag val]]

    Then restructure it into *this* shape:

        [fst [snd [tag rest val]]]

    And then proceed with parsing as usual.
-}
data OvalOvum
  = OOBlip BlipOvum
  | OOVane VaneOvum

instance FromNoun OvalOvum where
    parseNoun n = named "Ovum" $ do
      (path::Path, tag::Cord, v::Noun) <- parseNoun n
      case path of
        Path (""     : m : p) -> OOBlip <$> parseNoun (toNoun (m, tag, p, v))
        Path ("vane" : m : p) -> OOVane <$> parseNoun (toNoun (m, tag, p, v))
        Path (_:_:_)          -> fail "path must start with %$ or %vane"
        Path (_:_)            -> fail "path too short"
        Path _                -> fail "empty path"

instance ToNoun OvalOvum where
  toNoun oo =
      fromNounErr noun & \case
        Left err -> error (show err)
        Right (pathSnd::Knot, tag::Cord, Path path, val::Noun) ->
          toNoun (Path (pathHead:pathSnd:path), (tag, val))
    where
      (pathHead, noun) =
        case oo of OOBlip bo -> ("",     toNoun bo)
                   OOVane vo -> ("vane", toNoun vo)

--------------------------------------------------------------------------------


type AmesOvum = Void
type ArvoOvum = Void
type BehnOvum = Void
type BoatOvum = Void
type HttpClientOvum = Void
type HttpServerOvum = Void
type NewtOvum = Void
type SyncOvum = Void
type TermOvum = Void

data BlipOvum
    = BOAmes       AmesOvum
    | BOArvo       ArvoOvum
    | BOBehn       BehnOvum
    | BOBoat       BoatOvum
    | BOHttpClient HttpClientOvum
    | BOHttpServer HttpServerOvum
    | BONewt       NewtOvum
    | BOSync       SyncOvum
    | BOTerm       TermOvum

data KernelModule
    = Ames | Behn | Clay | Dill | Eyre | Ford | Gall | Iris | Jael

data VaneOvum
    = VOVane (KernelModule, ()) Void
    | VOZuse ()                 Void

--------------------------------------------------------------------------------

newtype Jam = Jam { unJam :: Atom }
  deriving newtype (Eq, Ord, Show, ToNoun, FromNoun)

data IODriver = IODriver
  { bornEvent   :: IO RawOvum
  , startDriver :: (RawOvum -> STM ()) -> IO (Async (), Perform)
  }

data Writ a = Writ
  { eventId :: Word64
  , timeout :: Maybe Word
  , event   :: Jam -- mat
  , payload :: a
  }


-- Instances -------------------------------------------------------------------

instance ToNoun Work where
  toNoun (Work eid m d o) = toNoun (eid, Jammed (m, d, o))

instance FromNoun Work where
    parseNoun n = named "Work" $ do
        (eid, Jammed (m, d, o)) <- parseNoun n
        pure (Work eid m d o)

instance ToNoun LifeCyc where
  toNoun (LifeCyc eid m n) = toNoun (eid, Jammed (m, n))

instance FromNoun LifeCyc where
  parseNoun n = named "LifeCyc" $ do
      (eid, Jammed (m, n)) <- parseNoun n
      pure (LifeCyc eid m n)

-- No FromNoun instance, because it depends on context (lifecycle length)
instance ToNoun Job where
  toNoun (DoWork w) = toNoun w
  toNoun (RunNok l) = toNoun l

instance Show FileOcts where
  show (FileOcts bs) = show (take 32 bs <> "...")

instance Show BigTape where
  show (BigTape t) = show (take 32 t <> "...")

instance Show Nock where
  show _ = "Nock"

instance Show Pill where
  show (Pill x y z) = show (length x, length y, length z)

deriveToNoun ''Order

deriveNoun ''ArrowKey
deriveNoun ''Belt
deriveNoun ''BlipOvum
deriveNoun ''Blit
deriveNoun ''Dawn
deriveNoun ''Eff
deriveNoun ''Event
deriveNoun ''HttpEvent
deriveNoun ''HttpRequest
deriveNoun ''KernelModule
deriveNoun ''Lane
deriveNoun ''LegacyBootEvent
deriveNoun ''LogIdentity
deriveNoun ''Mime
deriveNoun ''NewtEx
deriveNoun ''Pill
deriveNoun ''RawOvum
deriveNoun ''RecEx
deriveNoun ''RequestParams
deriveNoun ''ResponseHeader
deriveNoun ''VaneOvum