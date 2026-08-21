# Self-host value shapes

Date: 2026-08-21

The Dew lowering port now classifies canonical resolved types into backend value shapes.

Implemented shapes include scalar integers and floats, SWAR lanes, V128 lanes, references, generic values, products, Unit, Never, and errors. Applied types use their base representation. Product traversal uses an explicit task stack and retains ordered nested field shapes.

Function planning, layouts, and body lowering can now share this shape classifier.
