module move_ai::signed_fixed_point64 {
    use aptos_std::math_fixed64;
    use aptos_std::fixed_point64::FixedPoint64;
    use aptos_std::fixed_point64;

    /// Define a signed fixed point type with two 32 bits.
    struct SignedFixedPoint64 has copy, drop, store {
        value: FixedPoint64,
        is_negative: bool,
    }

    public fun zero(): SignedFixedPoint64 {
        let zero_fixed = fixed_point64::create_from_rational(0, 1);
        SignedFixedPoint64 { value: zero_fixed, is_negative: true }
    }

    public fun new(value: FixedPoint64, is_negative: bool): SignedFixedPoint64 {
        SignedFixedPoint64 { value: value, is_negative: is_negative }
    }

    public fun create_from_int(value: u128, is_negative: bool): SignedFixedPoint64 {
        let fixed = fixed_point64::create_from_u128(value);
        SignedFixedPoint64 { value: fixed, is_negative: is_negative }
    }

    public fun create_from_raw_value(raw_value: u128, is_negative: bool): SignedFixedPoint64 {
        let fixed = fixed_point64::create_from_raw_value(raw_value);
        SignedFixedPoint64 { value: fixed, is_negative: is_negative }
    }

    public fun new_positive(value: FixedPoint64): SignedFixedPoint64 {
        SignedFixedPoint64 { value: value, is_negative: false }
    }

    public fun new_negative(value: FixedPoint64): SignedFixedPoint64 {
        SignedFixedPoint64 { value: value, is_negative: true }
    }

    ///

    public fun exp(x: SignedFixedPoint64): SignedFixedPoint64 {
        if (x.is_negative) {
            let fixed_point = math_fixed64::exp(x.value);
            div(create_from_int(1, false), new_positive(fixed_point))
        } else {
            SignedFixedPoint64 { value: math_fixed64::exp(x.value), is_negative: false }
        }
        
    }

    /// a + b
    public fun add(a: SignedFixedPoint64, b: SignedFixedPoint64): SignedFixedPoint64 {
        if (a.is_negative == b.is_negative) {
            SignedFixedPoint64 { value: fixed_point64::add(a.value, b.value), is_negative: a.is_negative }
        } else {
            if (fixed_point64::greater_or_equal(a.value, b.value)) {
                SignedFixedPoint64 { value: fixed_point64::sub(a.value, b.value), is_negative: a.is_negative }
            } else {
                SignedFixedPoint64 { value: fixed_point64::sub(b.value, a.value), is_negative: b.is_negative }
            }
        }
    }

    /// a - b
    public fun sub(a: SignedFixedPoint64, b: SignedFixedPoint64): SignedFixedPoint64 {
        add(a, negate(b))
    }

    public fun mul_div(a: SignedFixedPoint64, b: SignedFixedPoint64, c: SignedFixedPoint64): SignedFixedPoint64 {
        let value = math_fixed64::mul_div(a.value, b.value, c.value);
        let sign = xor(xor(a.is_negative, b.is_negative),c.is_negative);
        SignedFixedPoint64 { value: value, is_negative: sign }
    }

    public fun mul(a: SignedFixedPoint64, b: SignedFixedPoint64): SignedFixedPoint64 {
        let one = create_from_int(1, false);
        mul_div(a, b, one)
    }

    public fun div(a: SignedFixedPoint64, b: SignedFixedPoint64): SignedFixedPoint64 {
        let one = create_from_int(1, false);
        mul_div(one, a, b)
    }

    /// Check if the given num is negative.
    public fun is_negative(num: SignedFixedPoint64): bool {
        num.is_negative
    }

    spec is_negative {
        aborts_if false;
        ensures result == num.is_negative;
    }

    /// -num
    public fun negate(num: SignedFixedPoint64):  SignedFixedPoint64{
        num.is_negative = !num.is_negative;
        num
    }

    public fun equal(a: SignedFixedPoint64, b: SignedFixedPoint64): bool {
        if (a.is_negative != b.is_negative) {
            false
        } else {
            fixed_point64::equal(a.value, b.value)
        }
    }

    fun xor(a: bool, b: bool): bool {
        (a && !b) || (!a && b)
    }

    #[test]
    public fun test_add() {
        let one = create_from_int(1, false);
        let two = create_from_int(2, false);
        let three = create_from_int(3, false);
        assert!(equal(three, add(one, two)), 0);

        let minus_one = add(create_from_int(3, true), create_from_int(2, false));
        assert!(equal(create_from_int(1, true), minus_one), 0);
    }

    // #[test]
    // public fun test_equal() {
    //     let num1 = create_from_int(4, false);
    //     let num2 = create_from_int(2, false);
    //     assert!(equal(res, add(one, two)), 0);

    //     let minus_one = add(create_from_int(3, true), create_from_int(2, false));
    //     assert!(equal(create_from_int(1, true), minus_one), 0);
    // }

}
