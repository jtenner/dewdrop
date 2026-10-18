# Native review formatting

Run `moon fmt` after the cache, privacy-test, and match-coverage review fixes.
The change applies canonical line wrapping and block layout. It changes no
compiler rule or assertion value. The final native builds and test checks use
these formatted files. Earlier exact-source measurement records keep their
original hashes and state their scope.
