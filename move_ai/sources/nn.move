module move_ai::nn {
	use move_ai::linalg::{Self, Mat, Vec};
	//use move_ai::signed_fixed_point64::{Self};
	use move_ai::activations_fns;
	//use aptos_framework::resource_account;
	//use aptos_framework::account;
	use std::vector;
	use std::signer;

	struct NN has drop, key, store {
		layers: vector<Mat>,
		activation_fn: vector<u8>,
	}
   const IDENTITY: u8 = 0x0;
   const SIGMOID: u8 = 0x1;
   const RELU: u8 = 0x2;


   public entry fun update_nn(self: &signer, w: vector<vector<vector<u128>>>, w_s: vector<vector<vector<bool>>>, activations: vector<u8>) acquires NN {
		assert!(signer::address_of(self) == @move_ai, 123);
		if(exists<NN>(signer::address_of(self))) {
			let _ = move_from<NN>(signer::address_of(self)); // drop existing one
		};
		let nn = nn_from_raws(w, w_s, activations);
		move_to<NN>(self, nn);
	}

	public fun n_layers(nn: &NN): u64 {
		vector::length(&nn.layers)
	}

	public fun do_activation(in: Vec, type: u8): Vec {
		if(type == IDENTITY) {
			return in
		};
		if(type == SIGMOID) {
			let inner = linalg::v_inner(&mut in);
			let i = 0;
			while( i < vector::length(inner)) {
				*vector::borrow_mut(inner, i) = activations_fns::sigmoid(*vector::borrow(inner, i));
				i = i + 1;
			};
			return in
		};
		if(type == RELU) {
			let inner = linalg::v_inner(&mut in);
			let i = 0;
			while( i < vector::length(inner)) {
				*vector::borrow_mut(inner, i) = activations_fns::relu(*vector::borrow(inner, i));
				i = i + 1;
			};
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

	public fun nn_from_raws(w: vector<vector<vector<u128>>>, w_s: vector<vector<vector<bool>>>, activaitons: vector<u8>): NN {
		let n_layers = vector::length(&w);
		let v_layers = vector[];
		let i = 0;
		while(i < n_layers) {
			vector::push_back(&mut v_layers, linalg::m_from_raws(vector::borrow(&w, i), vector::borrow(&w_s, i)));
			i = i + 1;
		};
		NN {
			layers: v_layers,
			activation_fn: activaitons,
		}
	}

	struct MLAttestation has key, drop {
		in: Vec,
		out: Vec,
	}

	public entry fun run(sender: &signer, in: vector<u128>, in_s: vector<bool>) acquires NN, MLAttestation {
		let nn = borrow_global<NN>(@move_ai);
		let in = linalg::v_from_raws(&in, &in_s);
		let res = eval(nn, in);

		// drop if exists
		if(exists<MLAttestation>(signer::address_of(sender))) {
			let _ = move_from<MLAttestation>(signer::address_of(sender));
		};


		move_to<MLAttestation>(sender, MLAttestation {
			in: in,
			out: res,
		})
	}
}
