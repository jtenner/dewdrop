# Compile request fixture error output

A native check found that the compile-request fixture formatted `@fs.IOError`
through `Show`, which the installed filesystem package does not implement.
This made the fixture fail to build, before it could report a failed write.

The catch arm now extracts the error's message and keeps the existing diagnostic
prefix and exit status 2. The error is not discarded or changed to a successful
result. Native check passes in 0.387 seconds and native build in 0.223 seconds.
The built fixture was run with a request path under a missing directory inside
a fresh temporary directory. It prints the prefix and the real `No such file
or directory` error, then exits with status 2. Both were asserted, not inferred
from any nonzero exit.
