module move_ai::Math {
    use aptos_std::fixed_point32;
    use aptos_std::fixed_point32::FixedPoint32;
    use move_ai::signed_fixed_point32;
    use move_ai::signed_fixed_point32::SignedFixedPoint32;

    public fun sigmoid(z: &SignedFixedPoint32): SignedFixedPoint32 {
        encode(1) / (encode(1) + exp_raw(signed_fixed_point32::SignedFixedPoint32 { value: z, is_negative: true }))
    }
}

module move_ai::signed_fixed_point32 {
    use aptos_std::fixed_point32;
    use aptos_std::fixed_point32::FixedPoint32;

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
        let fixed_point = exp(x.value);
        SignedFixedPoint32 { value: fixed_point, is_negative: false}
    }

    /// Check if the given num is negative.
    public fun is_negative(num: SignedFixedPoint32): bool {
        num.is_negative
    }

     spec is_negative {
        aborts_if false;
        ensures result == num.is_negative;
    }

}