(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (struct))
  (type (;9;) (struct))
  (type (;10;) (func (result (ref null 9))))
  (type (;11;) (func (param (ref 9))))
  (type (;12;) (func))
  (export "main" (func 2))
  (func (;0;) (type 10) (result (ref null 9))
    ref.null none
    ref.cast (ref null 9)
  )
  (func (;1;) (type 11) (param (ref 9)))
  (func (;2;) (type 12)
    call 0
    ref.as_non_null
    call 1
  )
)
