type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

let rec c_rule rule result r = match rule with
	[]->result
	| (sym, res)::tail -> if sym = r then c_rule tail (result@[res]) r
							else c_rule tail result r

let rec convert_grammar gram = match gram with
	|(s_sym, rule) -> (s_sym, (c_rule rule []))

let rec nt_matcher start_sym gram_rules rules acceptor deriv frag = match rules with
	[] -> None
	| head::tail -> let suc_match = t_matcher gram_rules head acceptor (deriv@[(start_sym, head)]) frag
					in
					match suc_match with
						None -> nt_matcher start_sym gram_rules tail acceptor deriv frag
						| _ -> suc_match

and t_matcher gram_rules rule acceptor deriv frag = match rule with
	[] -> acceptor deriv frag
	| (N sym)::other_rules -> nt_matcher sym gram_rules (gram_rules sym) (t_matcher gram_rules other_rules acceptor) deriv frag
	| (T sym)::other_rules -> match frag with
								[] -> None
								| pre::suf -> if pre = sym then t_matcher gram_rules other_rules acceptor deriv suf
												else None

let parse_prefix gram acceptor fragment = match gram with
	(start_sym, all_rules) -> nt_matcher start_sym all_rules (all_rules start_sym) acceptor [] fragment