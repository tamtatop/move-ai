module move_ai::Math {
    use aptos_std::fixed_point32;
    use aptos_std::fixed_point32::FixedPoint32;
    use move_ai::signed_fixed_point32;
    use move_ai::signed_fixed_point32::SignedFixedPoint32;

    public fun sigmoid(z: &SignedFixedPoint32): SignedFixedPoint32 {
        let one = SignedFixedPoint32 { value: 1, is_negative: false };
        div(one, add(one, exp(negate(z))))
    }
}

module move_ai::signed_fixed_point32 {
    use aptos_std::fixed_point32;
    use aptos_std::fixed_point32::FixedPoint32;

    public fun new(value: FixedPoint32, is_negative: bool) {
        SignedFixedPoint32 { value: value, is_negative: is_negative }
    }

    public fun new_positive(value: FixedPoint32) {
        SignedFixedPoint32 { value: value, is_negative: false }
    }

    public fun new_negative(value: FixedPoint32) {
        SignedFixedPoint32 { value: value, is_negative: true }
    }

    /// Define a signed integer type with two 32 bits.
    struct SignedFixedPoint32 has copy, drop, store {
        value: FixedPoint32,
        is_negative: bool,
    }

    /// Sub: `num - minus`
    /// 0 is negative
    public fun sub_fixed_point_32(num: FixedPoint32, minus: SignedFixedPoint32): SignedFixedPoint32 {
        if (minus.is_negative) {
            let result = fixed_point32::add(num, minus.value);
            SignedFixedPoint32 { value: result, is_negative: false }
        } else {
            if (fixed_point32::greater_or_equal(num, minus.value)) {
                let result = fixed_point32::sub(num, minus.value);
                SignedFixedPoint32 { value: result, is_negative: false }
            } else {
                let result = fixed_point32::sub(minus.value, num);
                SignedFixedPoint32 { value: result, is_negative: true }
            }
        }
    }

    public fun exp(x: SignedFixedPoint32): SignedFixedPoint32 {
        if (x.is_negative) {
            let fixed_point = fixed_point32::exp(x.value);
            let inverse_fixed_point = fixed_point32::mul_div(FixedPoint32 { value: 1 }, FixedPoint32 { value: 1 }, fixed_point);
            SignedFixedPoint32 { value: inverse_fixed_point, is_negative: false }
        } else {
            SignedFixedPoint32 { value: fixed_point32::exp(x.value), is_negative: false }
        }
        
    }

    /// a + b
    public fun add(a: SignedFixedPoint32, b: SignedFixedPoint32): SignedFixedPoint32 {
        if (a.is_negative == b.is_negative) {
            SignedFixedPoint32 { value: fixed_point32::add(a.value, b.value), is_negative: a.is_negative }
        } else {
            if (fixed_point32::greater_or_equal(a.value, b.value)) {
                SignedFixedPoint32 { value: fixed_point32::sub(a.value, b.value), is_negative: a.is_negative }
            } else {
                SignedFixedPoint32 { value: fixed_point32::sub(b.value, a.value), is_negative: b.is_negative }
            }
        }
    }

    /// a - b
    public fun sub(a: SignedFixedPoint32, b: SignedFixedPoint32): SignedFixedPoint32 {
        add(a, negate(b))
    }

    public fun mul_div(a: SignedFixedPoint32, b: SignedFixedPoint32, c: SignedFixedPoint32): SignedFixedPoint32 {
        let value = fixed_point32::mul_div(a, b, c);
        let sign = a.is_negative ^ b.is_negative ^ c.is_negative;
        SignedFixedPoint32 { value: value, is_negative: sign }
    }

    public fun mul(a: SignedFixedPoint32, b: SignedFixedPoint32): SignedFixedPoint32 {
        let one = SignedFixedPoint32{ value: 1, is_negative: false };
        mul_div(a, b, one)
    }

    public fun div(a: SignedFixedPoint32, b: SignedFixedPoint32): SignedFixedPoint32 {
        let one = SignedFixedPoint32{ value: 1, is_negative: false };
        mul_div(one, a, b)
    }

    /// Check if the given num is negative.
    public fun is_negative(num: SignedFixedPoint32): bool {
        num.is_negative
    }

    /// -num
    public fun negate(num: SignedFixedPoint32) {
        num.is_negative = !num.is_negative;
        num
    }

     spec is_negative {
        aborts_if false;
        ensures result == num.is_negative;
    }

    #[test]
    public fun test_add() {
        let one = SignedFixedPoint32{ value: 3, is_negative: false };
        let two = SignedFixedPoint32{ value: 2, is_negative: false };
        let five = SignedFixedPoint32{ value: 5, is_negative: false };
        assert_approx_the_same(five, add(one, two));
    }

}