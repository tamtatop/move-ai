module move_ai::activations_fns {
    use move_ai::signed_fixed_point64::{zero, div, add, exp, negate, create_from_int, is_negative};
    use move_ai::signed_fixed_point64::SignedFixedPoint64;

    public fun sigmoid(z: SignedFixedPoint64): SignedFixedPoint64 {
        let one = create_from_int(1, false);
        div(one, add(one, exp(negate(z))))
    }

    public fun relu(z: SignedFixedPoint64): SignedFixedPoint64 {
        if (is_negative(z)) {
            zero()
        } else {
            z
        }
    }
}
