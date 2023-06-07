module move_ai::linalg {
	use move_ai::signed_fixed_point64::{Self, SignedFixedPoint64};
	use std::vector;
	
	struct Mat has drop, store{
		n0: u64,
		n1: u64,
		v: vector<vector<SignedFixedPoint64>>
	}

	struct Vec has drop, store{
		n0: u64,
		v: vector<SignedFixedPoint64>
	}


	public fun m_new(values: vector<vector<SignedFixedPoint64>>): Mat {
		let n0 = ((vector::length(&values)));
		let n1 = (vector::length(vector::borrow(&values, 0)));
		Mat {
			n0,
			n1,
			v: values,
		}
	}

	public fun m_zeros(n0: u64, n1: u64): Mat {
		let v = vector[];
		let i = 0;
		while (i < n0) {
			let g = vector[];
			let j = 0;
			while (j < n1) {
				vector::push_back(&mut g, signed_fixed_point64::zero());
				j = j + 1;
			};
			vector::push_back(&mut v, g);
			i = i + 1;
		};
		m_new(v)
	}


	public fun v_new(values: vector<SignedFixedPoint64>): Vec {
		let n0 = (vector::length(&values));
		Vec {
			n0,
			v: values,
		}
	}

	public fun v_zeros(n0: u64): Vec {
		let g = vector[];
		let j = 0;
		while (j < n0) {
			vector::push_back(&mut g, signed_fixed_point64::zero());
			j = j + 1;
		};
		v_new(g)
	}

	public fun m_n0(m: &Mat): u64 {
		m.n0
	}

	public fun m_n1(m: &Mat): u64 {
		m.n1
	}

	public fun v_n0(v: &Vec): u64 {
		v.n0
	}

	public fun m_get(m: &Mat, i: u64, j: u64): SignedFixedPoint64 {
		*vector::borrow(vector::borrow(&m.v, i), j)
	}

	public fun m_get_mut(m: &mut Mat, i: u64, j: u64): &mut SignedFixedPoint64 {
		vector::borrow_mut(vector::borrow_mut(&mut m.v, i), j)
	}

	public fun v_get(v: &Vec, i: u64): SignedFixedPoint64 {
		*vector::borrow(&v.v, i)
	}

	public fun v_get_mut(v: &mut Vec, i: u64): &mut SignedFixedPoint64 {
		vector::borrow_mut(&mut v.v, i)
	}


	// (N, M) X (M, K) -> (N, K)
	public fun m_mul_m(a: &Mat, b: &Mat): Mat {
		assert!( m_n1(a) == m_n0(b), 123);
		let c = m_zeros(m_n0(a), m_n1(b)); // (a_n0, b_n1)
		let i = 0;
		while (i < m_n0(&c)) {
			let j = 0;
			while (j < m_n1(&c)) {
				let k = 0;
				while (k < m_n1(a)) {
					*m_get_mut(&mut c, i, j) = signed_fixed_point64::add(
						m_get(&c, i, j),
						signed_fixed_point64::mul(
							m_get(a, i, k),
							m_get(b, k, j)
						)
					);
					k = k + 1;
				};
				j = j + 1;
			};
			i = i + 1;
		};
		c
	}

	// (N, M) X (M) -> (N, )
	public fun m_mul_v(a: &Mat, b: &Vec): Vec {
		assert!( m_n1(a) == v_n0(b), 123);
		let c = v_zeros(m_n0(a)); // (a_n0, )
		let i = 0;
		while (i < v_n0(&c)) {
			let k = 0;
			while (k < m_n1(a)) {
				*v_get_mut(&mut c, i) = signed_fixed_point64::add(
					v_get(&c, i),
					signed_fixed_point64::mul(
						m_get(a, i, k),
						v_get(b, k)
					)
				);
				k = k + 1;
			};
			i = i + 1;
		};
		c
	}

	public fun m_equal(a: &Mat, b: &Mat): bool {
		let n0 = m_n0(a);
		let n1 = m_n1(a);
		assert!(m_n0(b) == n0, 124);
		assert!(m_n1(b) == n1, 124);
		let i = 0;
		while ( i < n0 ) {
			let j = 0;
			while ( j < n1 ) {
				if(!signed_fixed_point64::equal(m_get(a, i, j), m_get(b, i, j))) {
					return false
				};
				j = j + 1;
			};
			i = i + 1;
		};
		true
	}

	public fun v_equal(a: &Vec, b: &Vec): bool {
		let n0 = v_n0(a);
		assert!(v_n0(b) == n0, 124);
		let i = 0;
		while ( i < n0 ) {
			if(!signed_fixed_point64::equal(v_get(a, i), v_get(b, i))) {
				return false
			};
			i = i + 1;
		};
		true
	}


	public fun pn(x: u128): SignedFixedPoint64 { // positive_number
		signed_fixed_point64::create_from_int(x, false)
	}

	#[test]
	public fun mul_2_by_2s() {
		let a = m_new(vector[
			vector[ pn(1),  pn(2) ],
			vector[ pn(3),  pn(4) ],
		]);
		let b = m_new(vector[
			vector[ pn(4),  pn(1) ],
			vector[ pn(3),  pn(2) ],
		]);
		let c = m_new(vector[
			vector[ pn(10), pn( 5) ],
			vector[ pn(24), pn(11) ],
		]);
		assert!(m_equal(&m_mul_m(&a, &b), &c), 125);
	}

	#[test]
	public fun mul_1_by_2s() {
		let a = m_new(vector[
			vector[ pn(1),  pn(2) ],
		]);
		let b = m_new(vector[
			vector[ pn(4),  pn(1) ],
			vector[ pn(3),  pn(2) ],
		]);
		let c = m_new(vector[
			vector[ pn(10), pn( 5) ],
		]);
		assert!(m_equal(&m_mul_m(&a, &b), &c), 125);
	}

	#[test]
	public fun mul_11_21() {
		let a = m_new(vector[
			vector[ pn(3) ],
		]);
		let b = m_new(vector[
			vector[ pn(4) ],
		]);
		let c = m_new(vector[
			vector[ pn(12) ],
		]);
		assert!(m_equal(&m_mul_m(&a, &b), &c), 125);
	}

	#[test]
	public fun mul_m_by_v() {
		let a = m_new(vector[
			vector[ pn(1), pn(2), pn(3) ],
			vector[ pn(4), pn(5), pn(6) ],
		]);
		let b = v_new(vector[
			pn(7),
			pn(8),
			pn(9),
		]);
		let c = v_new(vector[
			pn(50),
			pn(122),
		]);
		assert!(v_equal(&m_mul_v(&a, &b), &c), 125);
	}


}
