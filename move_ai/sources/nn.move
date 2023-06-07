module move_ai::nn {
	use move_ai::linalg::{Self, Mat, Vec};
	use std::vector;

	struct NN {
		layers: vector<Mat>,
		activation_fn: vector<u8>,
	}
   const IDENTITY: u8 = 0x0;
   const SIGMOID: u8 = 0x1;
   const RELU: u8 = 0x2;

	public fun n_layers(nn: &NN): u64 {
		vector::length(&nn.layers)
	}

	public fun do_activation(in: Vec, type: u8): Vec {
		if(type == IDENTITY) {
			return in
		};
		if(type == SIGMOID) {
			return in
		};
		if(type == RELU) {
			return in
		};
		abort 42
	}

	public fun eval(nn: &NN, input: Vec): Vec {
		let res: Vec = input;
		let i = 0;
		while(i < n_layers(nn)) {
			res = linalg::m_mul_v(vector::borrow(&nn.layers, i), &res);
			res = do_activation(res, *vector::borrow(&nn.activation_fn, i));
			i = i + 1;
		};
		res
	}
}
