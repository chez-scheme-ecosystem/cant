(print ("hey there" .split))
(print ("  hey  there   " .split))
(print ("     " .split))
(print ("a" .split))

(print ("" .starts-with? "hey"))
(print ("" .starts-with? ""))
(print ("hey" .starts-with? ""))
(print ("hey" .starts-with? "h"))
(print ("hey" .starts-with? "x"))
(print ("hey" .starts-with? "hey"))
(print ("hey" .starts-with? "heyo"))

(print ("hey there" .split "||"))
(print ("hey|there" .split "||"))
(print ("hey||there" .split "||"))
(print ("hey||there||" .split "||"))
(print ("hey||th|ere|||whee" .split "||"))
(print ("hey||th|ere||||whee" .split "||"))

(print ("hey there" .replace "x" "123"))
(print ("hey" .replace "" "X"))
(print ("hey-yo-dude" .replace "-" "=="))
(print ("-hey-yo--dude-" .replace "-" "=="))
(print ("-hey-yo--dude-" .replace "-" ""))
(print ("-hey->yo->dude-" .replace "->" "(())"))
