module Dialogue1 where
import qualified System.IO as Sys       
import qualified System.Environment as Environment
import System.IO.Error(catchIOError)
import Control.Exception(catch)

type Dialogue = [Response] -> [Request]

data Response 
  = Success
  | Chr Char
  | Str String
  | StrList [String]
  | Failure IOError
  deriving(Show)  

data Request    
  = ReadChan Chan
  | AppendChan Chan String
  | ReadFile Path
  | WriteFile Path String
  | GetArgs
  deriving(Show)    
          
type Chan = Sys.Handle
stdin = Sys.stdin
stdout = Sys.stdout
stderr  = Sys.stderr

type Path = String

runDialogue :: Dialogue -> IO()
runDialogue d = case (d undefined) of
     [] -> return ()
     (q:qs) -> do 
       r <- (runRequest q )
       runDialogue $ \rs -> tail (d (r:rs))
runRequest :: Request -> IO Response
runRequest r = runR r `catchIOError` \e -> return (Failure e)


runR (AppendChan h s) = Sys.hPutStr h s >> return Success
runR (ReadChan h ) = fmap Str (Sys.hGetContents h)
runR (ReadFile p) = fmap Str (readFile p)
runR (GetArgs) = fmap StrList Environment.getArgs
