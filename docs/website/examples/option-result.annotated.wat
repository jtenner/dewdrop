(module
  (type (;0 Option_I32;) (sub
    (struct
      (field (;tag;) i32))))
  (type (;1 Option_Some_I32;) (sub final 0
    (struct
      (field (;tag;) i32)
      (field (;value;) i32))))
  (type (;2 Result_I32_I32;) (sub
    (struct
      (field (;tag;) i32))))
  (type (;3 Result_Ok_I32;) (sub final 2
    (struct
      (field (;tag;) i32)
      (field (;value;) i32))))
  (type (;4 Result_Err_I32;) (sub final 2
    (struct
      (field (;tag;) i32)
      (field (;value;) i32))))
  (type (;5 maybe_type;) (func (param (;enabled;) i32) (result (ref 0))))
  (type (;6 divide_type;) (func (param (;value;) i32) (param (;divisor;) i32) (result (ref 2))))
  (export "maybe" (func 0))
  (export "divide" (func 1))
  (func (;0 maybe;) (type 5) (param (;enabled;) i32) (result (ref 0))
    local.get 0
    if (result eqref)
      i32.const 1 (;Some_tag;)
      i32.const 42 (;Some_value;)
      struct.new 1 (;Option_Some_I32;)
    else
      i32.const 0 (;None_tag;)
      struct.new 0 (;Option_I32;)
    end
    ref.cast (ref 0 (;Option_I32;))
  )
  (func (;1 divide;) (type 6) (param (;value;) i32) (param (;divisor;) i32) (result (ref 2))
    local.get 1
    i32.const 0
    i32.eq
    if (result eqref)
      i32.const 1 (;Err_tag;)
      local.get 0 (;Err_value;)
      struct.new 4 (;Result_Err_I32;)
    else
      i32.const 0 (;Ok_tag;)
      local.get 0
      local.get 1
      i32.div_s (;Ok_value;)
      struct.new 3 (;Result_Ok_I32;)
    end
    ref.cast (ref 2 (;Result_I32_I32;))
  )
)
