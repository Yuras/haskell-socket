{-# LANGUAGE TypeFamilies, FlexibleInstances, GeneralizedNewtypeDeriving #-}
module System.Socket.Family.Inet6
  ( -- * Inet6
    Inet6
    -- ** Inet6Address
  , Inet6Address
    -- ** Inet6Port
  , Inet6Port
    -- ** Inet6FlowInfo
  , Inet6FlowInfo
    -- ** Inet6ScopeId
  , Inet6ScopeId
    -- ** SocketAddress Inet6
  , SocketAddress (SocketAddressInet6, sin6Address, sin6Port, sin6FlowInfo, sin6ScopeId)
  -- * Special Addresses
  -- ** any
  , System.Socket.Family.Inet6.any
  -- ** loopback
  , loopback
  -- * Socket Options
  -- ** V6Only
  , V6Only (..)
  ) where

import Data.Word
import Control.Applicative as A

import Foreign.Ptr
import Foreign.C.Types
import Foreign.Storable

import System.Socket.Internal.Socket
import System.Socket.Internal.Platform

#include "hs_socket.h"
#let alignment t = "%lu", (unsigned long)offsetof(struct {char x__; t (y__); }, y__)

data Inet6

instance Family Inet6 where
  familyNumber _ = (#const AF_INET6)

-- | Example:
--
--  > SocketAddressInet6 loopback 8080 0 0
data instance SocketAddress Inet6
   = SocketAddressInet6
     { sin6Address   :: Inet6Address
     , sin6Port      :: Inet6Port
     , sin6FlowInfo  :: Inet6FlowInfo
     , sin6ScopeId   :: Inet6ScopeId
     } deriving (Eq, Show)

-- | To avoid errors with endianess it was decided to keep this type abstract.
--
--   Hint: Use the `Foreign.Storable.Storable` instance if you really need to access. It exposes it
--   exactly as found within an IP packet (big endian if you insist
--   on interpreting it as a number).
--
--   Another hint: Use `System.Socket.getAddressInfo` for parsing and suppress
--   nameserver lookups:
--
--   > > getAddressInfo (Just "::1") Nothing aiNumericHost :: IO [AddressInfo SocketAddressInet6 Stream TCP]
--   > [AddressInfo {
--   >    addressInfoFlags = AddressInfoFlags 4,
--   >    socketAddress    = SocketAddressInet6 {address = 0000:0000:0000:0000:0000:0000:0000:0001, port = 0, flowInfo = mempty, scopeId = 0},
--   >    canonicalName    = Nothing }]
data  Inet6Address    = Inet6Address {-# UNPACK #-} !Word64 {-# UNPACK #-} !Word64
      deriving (Eq)

newtype Inet6Port     = Inet6Port Word16
      deriving (Eq, Ord, Show, Num)

newtype Inet6FlowInfo = Inet6FlowInfo Word32
      deriving (Eq, Ord, Show, Num)

newtype Inet6ScopeId  = Inet6ScopeId Word32
      deriving (Eq, Ord, Show, Num)

-- | @::@
any      :: Inet6Address
any       = Inet6Address 0 0

-- | @::1@
loopback :: Inet6Address
loopback  = Inet6Address 0 1

instance Show Inet6Address where
  show (Inet6Address high low) =
    [ hex $ hn $ w64_0 high
    , hex $ ln $ w64_0 high
    , hex $ hn $ w64_1 high
    , hex $ ln $ w64_1 high
    , ':'
    , hex $ hn $ w64_2 high
    , hex $ ln $ w64_2 high
    , hex $ hn $ w64_3 high
    , hex $ ln $ w64_3 high
    , ':'
    , hex $ hn $ w64_4 high
    , hex $ ln $ w64_4 high
    , hex $ hn $ w64_5 high
    , hex $ ln $ w64_5 high
    , ':'
    , hex $ hn $ w64_6 high
    , hex $ ln $ w64_6 high
    , hex $ hn $ w64_7 high
    , hex $ ln $ w64_7 high
    , ':'
    , hex $ hn $ w64_0 low
    , hex $ ln $ w64_0 low
    , hex $ hn $ w64_1 low
    , hex $ ln $ w64_1 low
    , ':'
    , hex $ hn $ w64_2 low
    , hex $ ln $ w64_2 low
    , hex $ hn $ w64_3 low
    , hex $ ln $ w64_3 low
    , ':'
    , hex $ hn $ w64_4 low
    , hex $ ln $ w64_4 low
    , hex $ hn $ w64_5 low
    , hex $ ln $ w64_5 low
    , ':'
    , hex $ hn $ w64_6 low
    , hex $ ln $ w64_6 low
    , hex $ hn $ w64_7 low
    , hex $ ln $ w64_7 low
    ]
    where
      hn, ln :: Word8 -> Word8
      hn x = div x 16
      ln x = mod x 16
      hex :: Word8 -> Char
      hex 0  = '0'
      hex 1  = '1'
      hex 2  = '2'
      hex 3  = '3'
      hex 4  = '4'
      hex 5  = '5'
      hex 6  = '6'
      hex 7  = '7'
      hex 8  = '8'
      hex 9  = '9'
      hex 10 = 'a'
      hex 11 = 'b'
      hex 12 = 'c'
      hex 13 = 'd'
      hex 14 = 'e'
      hex 15 = 'f'
      hex  _ = '_'

instance Storable Inet6Address where
  sizeOf   _  = 16
  alignment _ = 16
  peek ptr    = do
    h0 <- peekByteOff ptr  0 :: IO Word8
    h1 <- peekByteOff ptr  1 :: IO Word8
    h2 <- peekByteOff ptr  2 :: IO Word8
    h3 <- peekByteOff ptr  3 :: IO Word8
    h4 <- peekByteOff ptr  4 :: IO Word8
    h5 <- peekByteOff ptr  5 :: IO Word8
    h6 <- peekByteOff ptr  6 :: IO Word8
    h7 <- peekByteOff ptr  7 :: IO Word8
    l0 <- peekByteOff ptr  8 :: IO Word8
    l1 <- peekByteOff ptr  9 :: IO Word8
    l2 <- peekByteOff ptr 10 :: IO Word8
    l3 <- peekByteOff ptr 11 :: IO Word8
    l4 <- peekByteOff ptr 12 :: IO Word8
    l5 <- peekByteOff ptr 13 :: IO Word8
    l6 <- peekByteOff ptr 14 :: IO Word8
    l7 <- peekByteOff ptr 15 :: IO Word8
    return $ Inet6Address (((((((((((((( fromIntegral h0
                                * 256) + fromIntegral h1 )
                                * 256) + fromIntegral h2 )
                                * 256) + fromIntegral h3 )
                                * 256) + fromIntegral h4 )
                                * 256) + fromIntegral h5 )
                                * 256) + fromIntegral h6 )
                                * 256) + fromIntegral h7 )
                          (((((((((((((( fromIntegral l0
                                * 256) + fromIntegral l1 )
                                * 256) + fromIntegral l2 )
                                * 256) + fromIntegral l3 )
                                * 256) + fromIntegral l4 )
                                * 256) + fromIntegral l5 )
                                * 256) + fromIntegral l6 )
                                * 256) + fromIntegral l7 )
  poke ptr (Inet6Address high low) = do
    pokeByteOff ptr  0 (w64_0 high)
    pokeByteOff ptr  1 (w64_1 high)
    pokeByteOff ptr  2 (w64_2 high)
    pokeByteOff ptr  3 (w64_3 high)
    pokeByteOff ptr  4 (w64_4 high)
    pokeByteOff ptr  5 (w64_5 high)
    pokeByteOff ptr  6 (w64_6 high)
    pokeByteOff ptr  7 (w64_7 high)
    pokeByteOff ptr  8 (w64_0 low)
    pokeByteOff ptr  9 (w64_1 low)
    pokeByteOff ptr 10 (w64_2 low)
    pokeByteOff ptr 11 (w64_3 low)
    pokeByteOff ptr 12 (w64_4 low)
    pokeByteOff ptr 13 (w64_5 low)
    pokeByteOff ptr 14 (w64_6 low)
    pokeByteOff ptr 15 (w64_7 low)

instance Storable Inet6Port where
  sizeOf   _  = 2
  alignment _ = 2
  peek ptr    = do
    p0 <- peekByteOff ptr 0 :: IO Word8
    p1 <- peekByteOff ptr 1 :: IO Word8
    return $ Inet6Port (fromIntegral p0 * 256 + fromIntegral p1)
  poke ptr (Inet6Port w16) = do
    pokeByteOff ptr 0 (w16_0 w16)
    pokeByteOff ptr 1 (w16_1 w16)

instance Storable Inet6FlowInfo where
  sizeOf   _  = 4
  alignment _ = 4
  peek ptr    = do
    p0 <- peekByteOff ptr 0 :: IO Word8
    p1 <- peekByteOff ptr 1 :: IO Word8
    p2 <- peekByteOff ptr 2 :: IO Word8
    p3 <- peekByteOff ptr 3 :: IO Word8
    return $ Inet6FlowInfo $ ((((( fromIntegral p0  * 256) + fromIntegral p1) * 256)
                                 + fromIntegral p2) * 256) + fromIntegral p3
  poke ptr (Inet6FlowInfo w32) = do
    pokeByteOff ptr 0 (w32_0 w32)
    pokeByteOff ptr 1 (w32_1 w32)
    pokeByteOff ptr 2 (w32_2 w32)
    pokeByteOff ptr 3 (w32_3 w32)

instance Storable Inet6ScopeId where
  sizeOf   _  = 4
  alignment _ = 4
  peek ptr    = do
    p0 <- peekByteOff ptr 0 :: IO Word8
    p1 <- peekByteOff ptr 1 :: IO Word8
    p2 <- peekByteOff ptr 2 :: IO Word8
    p3 <- peekByteOff ptr 3 :: IO Word8
    return $ Inet6ScopeId $ ((((( fromIntegral p0  * 256) + fromIntegral p1) * 256)
                                + fromIntegral p2) * 256) + fromIntegral p3
  poke ptr (Inet6ScopeId w32) = do
    pokeByteOff ptr 0 (w32_0 w32)
    pokeByteOff ptr 1 (w32_1 w32)
    pokeByteOff ptr 2 (w32_2 w32)
    pokeByteOff ptr 3 (w32_3 w32)

instance Storable (SocketAddress Inet6) where
  sizeOf    _ = (#size struct sockaddr_in6)
  alignment _ = (#alignment struct sockaddr_in6)
  peek ptr    = SocketAddressInet6  A.<$> peek (sin6_addr     ptr)
                                      <*> peek (sin6_port     ptr)
                                      <*> peek (sin6_flowinfo ptr)
                                      <*> peek (sin6_scope_id ptr)
    where
      sin6_flowinfo = (#ptr struct sockaddr_in6, sin6_flowinfo)
      sin6_scope_id = (#ptr struct sockaddr_in6, sin6_scope_id)
      sin6_port     = (#ptr struct sockaddr_in6, sin6_port)
      sin6_addr     = (#ptr struct in6_addr, s6_addr) . (#ptr struct sockaddr_in6, sin6_addr)
  poke ptr (SocketAddressInet6 a p f s) = do
    c_memset ptr 0 (#const sizeof(struct sockaddr_in6))
    poke (sin6_family   ptr) ((#const AF_INET6) :: Word16)
    poke (sin6_addr     ptr) a
    poke (sin6_port     ptr) p
    poke (sin6_flowinfo ptr) f
    poke (sin6_scope_id ptr) s
    where
      sin6_family   = (#ptr struct sockaddr_in6, sin6_family)
      sin6_flowinfo = (#ptr struct sockaddr_in6, sin6_flowinfo)
      sin6_scope_id = (#ptr struct sockaddr_in6, sin6_scope_id)
      sin6_port     = (#ptr struct sockaddr_in6, sin6_port)
      sin6_addr     = (#ptr struct in6_addr, s6_addr) . (#ptr struct sockaddr_in6, sin6_addr)

-------------------------------------------------------------------------------
-- Address family specific socket options
-------------------------------------------------------------------------------

-- | @IPV6_V6ONLY@
data V6Only
   = V6Only Bool
   deriving (Eq, Ord, Show)

instance GetSocketOption V6Only where
  getSocketOption s =
    V6Only . ((/=0) :: CInt -> Bool) <$> unsafeGetSocketOption s (#const IPPROTO_IPV6) (#const IPV6_V6ONLY)

instance SetSocketOption V6Only where
  setSocketOption s (V6Only o) =
    unsafeSetSocketOption s (#const IPPROTO_IPV6) (#const IPV6_V6ONLY) (if o then 1 else 0 :: CInt)

w64_0, w64_1, w64_2, w64_3, w64_4, w64_5, w64_6, w64_7 :: Word64 -> Word8
w64_0 x = fromIntegral $ rem (quot x $ 256*256*256*256*256*256*256) 256
w64_1 x = fromIntegral $ rem (quot x $     256*256*256*256*256*256) 256
w64_2 x = fromIntegral $ rem (quot x $         256*256*256*256*256) 256
w64_3 x = fromIntegral $ rem (quot x $             256*256*256*256) 256
w64_4 x = fromIntegral $ rem (quot x $                 256*256*256) 256
w64_5 x = fromIntegral $ rem (quot x $                     256*256) 256
w64_6 x = fromIntegral $ rem (quot x $                         256) 256
w64_7 x = fromIntegral $ rem       x                                256

w32_0, w32_1, w32_2, w32_3 :: Word32 -> Word8
w32_0 x = fromIntegral $ rem (quot x $                 256*256*256) 256
w32_1 x = fromIntegral $ rem (quot x $                     256*256) 256
w32_2 x = fromIntegral $ rem (quot x $                         256) 256
w32_3 x = fromIntegral $ rem       x                                256

w16_0, w16_1 :: Word16 -> Word8
w16_0 x = fromIntegral $ rem (quot x $                         256) 256
w16_1 x = fromIntegral $ rem       x                                256
