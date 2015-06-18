{-# LANGUAGE OverloadedStrings #-}
module Main where

import Data.Monoid
import Control.Monad
import Control.Exception
import Control.Concurrent
import Control.Concurrent.Async
import System.Socket
import System.Socket.Family.INET
import System.Socket.Family.INET6
import System.Exit

main :: IO ()
main = do 
  test "INET"  (undefined :: Socket INET  DGRAM  UDP)  localhost
  test "INET6" (undefined :: Socket INET6 DGRAM  UDP)  localhost6

-- Test stateless sockets (i.e. UDP).
test :: (Family f, Type t, Protocol p) => String -> Socket f t p -> SocketAddress f -> IO ()
test inet dummy addr = do 
  server <- socket `asTypeOf` return dummy                   `onException` p 1
  client <- socket `asTypeOf` return dummy                   `onException` p 2

  bind server addr                                           `onException` p 4

  ((msg,peeraddr),_) <- concurrently 
   ( do
      receiveFrom server 4096 mempty                            `onException` p 5
   )
   ( do 
      -- This is a race condition:
      --   The server must listen before the client sends his msg or the packt goes
      --   to nirvana. Still, a second here should be enough. If not, there's 
      --   something wrong worth investigating.
      threadDelay 1000000
      sendTo client helloWorld mempty addr                   `onException` p 6
   )

  when (msg /= helloWorld) $                                               e 8

  close client                                               `onException` p 10
  close server                                               `onException` p 11

  where
    helloWorld = "Hello world!"
    e i        = error (inet ++ ": " ++ show i)
    p i        = print (inet ++ ": " ++ show i)

localhost :: SocketAddressIn
localhost =
  SocketAddressIn
  { sinPort      = 7777
  , sinAddr      = inaddrLOOPBACK
  }

localhost6 :: SocketAddressIn6
localhost6 =
  SocketAddressIn6
  { sin6Port     = 7777
  , sin6Addr     = in6addrLOOPBACK
  , sin6Flowinfo = 0
  , sin6ScopeId  = 0
  }
