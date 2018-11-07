(**************************************************************************)
(*     Sail                                                               *)
(*                                                                        *)
(*  Copyright (c) 2013-2017                                               *)
(*    Kathyrn Gray                                                        *)
(*    Shaked Flur                                                         *)
(*    Stephen Kell                                                        *)
(*    Gabriel Kerneis                                                     *)
(*    Robert Norton-Wright                                                *)
(*    Christopher Pulte                                                   *)
(*    Peter Sewell                                                        *)
(*    Alasdair Armstrong                                                  *)
(*    Brian Campbell                                                      *)
(*    Thomas Bauereiss                                                    *)
(*    Anthony Fox                                                         *)
(*    Jon French                                                          *)
(*    Dominic Mulligan                                                    *)
(*    Stephen Kell                                                        *)
(*    Mark Wassell                                                        *)
(*                                                                        *)
(*  All rights reserved.                                                  *)
(*                                                                        *)
(*  This software was developed by the University of Cambridge Computer   *)
(*  Laboratory as part of the Rigorous Engineering of Mainstream Systems  *)
(*  (REMS) project, funded by EPSRC grant EP/K008528/1.                   *)
(*                                                                        *)
(*  Redistribution and use in source and binary forms, with or without    *)
(*  modification, are permitted provided that the following conditions    *)
(*  are met:                                                              *)
(*  1. Redistributions of source code must retain the above copyright     *)
(*     notice, this list of conditions and the following disclaimer.      *)
(*  2. Redistributions in binary form must reproduce the above copyright  *)
(*     notice, this list of conditions and the following disclaimer in    *)
(*     the documentation and/or other materials provided with the         *)
(*     distribution.                                                      *)
(*                                                                        *)
(*  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS''    *)
(*  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED     *)
(*  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A       *)
(*  PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR   *)
(*  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,          *)
(*  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT      *)
(*  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF      *)
(*  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND   *)
(*  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,    *)
(*  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT    *)
(*  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF    *)
(*  SUCH DAMAGE.                                                          *)
(**************************************************************************)

(* generated by Ott 0.25 from: l2_parse.ott *)

module Big_int = Nat_big_num

type text = string

type l =
  | Unknown
  | Unique of int * l
  | Generated of l
  | Range of Lexing.position * Lexing.position
  | Documented of string * l

type 'a annot = l * 'a

exception Parse_error_locn of l * string


type x = text (* identifier *)
type ix = text (* infix identifier *)

type 
base_kind_aux =  (* base kind *)
   BK_type (* kind of types *)
 | BK_int (* kind of natural number size expressions *)
 | BK_order (* kind of vector order specifications *)


type 
base_kind = 
   BK_aux of base_kind_aux * l


type 
base_effect_aux =  (* effect *)
   BE_rreg (* read register *)
 | BE_wreg (* write register *)
 | BE_rmem (* read memory *)
 | BE_rmemt (* read memory tagged *)
 | BE_wmem (* write memory *)
 | BE_wmv (* write memory value *)
 | BE_wmvt (* write memory value + tag *)
 | BE_eamem (* address for write signaled *)
 | BE_exmem (* determine if a store-exclusive (ARM) is going to succeed *)
 | BE_barr (* memory barrier *)
 | BE_depend (* dynmically dependent footprint *)
 | BE_undef (* undefined-instruction exception *)
 | BE_unspec (* unspecified values *)
 | BE_nondet (* nondeterminism from intra-instruction parallelism *)
 | BE_escape
 | BE_config

type 
kid_aux =  (* identifiers with kind, ticked to differntiate from program variables *)
   Var of x


type 
id_aux =  (* Identifier *)
   Id of x
 | DeIid of x (* remove infix status *)


type 
kind_aux =  (* kinds *)
   K_kind of (base_kind) list


type 
base_effect = 
   BE_aux of base_effect_aux * l


type 
kid = 
   Kid_aux of kid_aux * l


type 
id = 
   Id_aux of id_aux * l


type 
kind = 
   K_aux of kind_aux * l


type 
atyp_aux =  (* expressions of all kinds, to be translated to types, nats, orders, and effects after parsing *)
   ATyp_id of id (* identifier *)
 | ATyp_var of kid (* ticked variable *)
 | ATyp_constant of Big_int.num (* constant *)
 | ATyp_times of atyp * atyp (* product *)
 | ATyp_sum of atyp * atyp (* sum *)
 | ATyp_minus of atyp * atyp (* subtraction *)
 | ATyp_exp of atyp (* exponential *)
 | ATyp_neg of atyp (* Internal (but not M as I want a datatype constructor) negative nexp *)
 | ATyp_inc (* increasing (little-endian) *)
 | ATyp_dec (* decreasing (big-endian) *)
 | ATyp_default_ord (* default order for increasing or decreasing signficant bits *)
 | ATyp_set of (base_effect) list (* effect set *)
 | ATyp_fn of atyp * atyp * atyp (* Function type (first-order only in user code), last atyp is an effect *)
 | ATyp_bidir of atyp * atyp (* Function type (first-order only in user code), last atyp is an effect *)
 | ATyp_wild
 | ATyp_tup of (atyp) list (* Tuple type *)
 | ATyp_app of id * (atyp) list (* type constructor application *)
 | ATyp_exist of kid list * n_constraint * atyp
 | ATyp_with of atyp * n_constraint

and atyp = 
   ATyp_aux of atyp_aux * l


and 
kinded_id_aux =  (* optionally kind-annotated identifier *)
   KOpt_none of kid (* identifier *)
 | KOpt_kind of kind * kid (* kind-annotated variable *)


and 
n_constraint_aux =  (* constraint over kind $_$ *)
   NC_equal of atyp * atyp
 | NC_bounded_ge of atyp * atyp
 | NC_bounded_le of atyp * atyp
 | NC_not_equal of atyp * atyp
 | NC_set of kid * (Big_int.num) list
 | NC_or of n_constraint * n_constraint
 | NC_and of n_constraint * n_constraint
 | NC_app of id * atyp list
 | NC_true
 | NC_false

and
n_constraint = 
   NC_aux of n_constraint_aux * l

type 
kinded_id = 
   KOpt_aux of kinded_id_aux * l

type
quant_item_aux =  (* Either a kinded identifier or a nexp constraint for a typquant *)
   QI_id of kinded_id (* An optionally kinded identifier *)
 | QI_const of n_constraint (* A constraint for this type *)


type 
quant_item = 
   QI_aux of quant_item_aux * l


type 
typquant_aux =  (* type quantifiers and constraints *)
   TypQ_tq of (quant_item) list
 | TypQ_no_forall (* sugar, omitting quantifier and constraints *)


type 
typquant = 
   TypQ_aux of typquant_aux * l


type 
lit_aux =  (* Literal constant *)
   L_unit (* $() : _$ *)
 | L_zero (* $_ : _$ *)
 | L_one (* $_ : _$ *)
 | L_true (* $_ : _$ *)
 | L_false (* $_ : _$ *)
 | L_num of Big_int.num (* natural number constant *)
 | L_hex of string (* bit vector constant, C-style *)
 | L_bin of string (* bit vector constant, C-style *)
 | L_undef (* undefined value *)
 | L_string of string (* string constant *)
 | L_real of string

type 
typschm_aux =  (* type scheme *)
   TypSchm_ts of typquant * atyp


type 
lit = 
   L_aux of lit_aux * l


type 
typschm = 
   TypSchm_aux of typschm_aux * l


type 
pat_aux =  (* Pattern *)
   P_lit of lit (* literal constant pattern *)
 | P_wild                (* wildcard        - always matches *)
 | P_or of pat * pat (* choice pattern  - P|Q matches if P matches or Q matches *)
 | P_typ of atyp * pat (* typed pattern *)
 | P_id of id (* identifier *)
 | P_var of pat * atyp (* bind pat to type variable *)
 | P_app of id * (pat) list (* union constructor pattern *)
 | P_record of (fpat) list * bool (* struct pattern *)
 | P_vector of (pat) list (* vector pattern *)
 | P_vector_concat of (pat) list (* concatenated vector pattern *)
 | P_tup of (pat) list (* tuple pattern *)
 | P_list of (pat) list (* list pattern *)
 | P_cons of pat * pat (* cons pattern *)
 | P_string_append of pat list (* string append pattern, x ^^ y *)

and pat = 
   P_aux of pat_aux * l

and fpat_aux =  (* Field pattern *)
   FP_Fpat of id * pat

and fpat = 
   FP_aux of fpat_aux * l

type loop = While | Until

type 
exp_aux =  (* Expression *)
   E_block of (exp) list (* block (parsing conflict with structs?) *)
 | E_nondet of (exp) list (* block that can evaluate the contained expressions in any ordering *)
 | E_id of id (* identifier *)
 | E_ref of id
 | E_deref of exp
 | E_lit of lit (* literal constant *)
 | E_cast of atyp * exp (* cast *)
 | E_app of id * (exp) list (* function application *)
 | E_app_infix of exp * id * exp (* infix function application *)
 | E_tuple of (exp) list (* tuple *)
 | E_if of exp * exp * exp (* conditional *)
 | E_loop of loop * exp * exp
 | E_for of id * exp * exp * exp * atyp * exp (* loop *)
 | E_vector of (exp) list (* vector (indexed from 0) *)
 | E_vector_access of exp * exp (* vector access *)
 | E_vector_subrange of exp * exp * exp (* subvector extraction *)
 | E_vector_update of exp * exp * exp (* vector functional update *)
 | E_vector_update_subrange of exp * exp * exp * exp (* vector subrange update (with vector) *)
 | E_vector_append of exp * exp (* vector concatenation *)
 | E_list of (exp) list (* list *)
 | E_cons of exp * exp (* cons *)
 | E_record of exp list (* struct *)
 | E_record_update of exp * (exp) list (* functional update of struct *)
 | E_field of exp * id (* field projection from struct *)
 | E_case of exp * (pexp) list (* pattern matching *)
 | E_let of letbind * exp (* let expression *)
 | E_assign of exp * exp (* imperative assignment *)
 | E_sizeof of atyp
 | E_constraint of n_constraint
 | E_exit of exp
 | E_throw of exp
 | E_try of exp * pexp list
 | E_return of exp
 | E_assert of exp * exp
 | E_var of exp * exp * exp

and exp = 
   E_aux of exp_aux * l

and fexp_aux =  (* Field-expression *)
   FE_Fexp of id * exp

and fexp = 
   FE_aux of fexp_aux * l

and fexps_aux =  (* Field-expression list *)
   FES_Fexps of (fexp) list * bool

and fexps = 
   FES_aux of fexps_aux * l

and opt_default_aux =  (* Optional default value for indexed vectors, to define a defualt value for any unspecified positions in a sparse map *)
   Def_val_empty
 | Def_val_dec of exp

and opt_default = 
   Def_val_aux of opt_default_aux * l

and pexp_aux =  (* Pattern match *)
   Pat_exp of pat * exp
 | Pat_when of pat * exp * exp

and pexp = 
   Pat_aux of pexp_aux * l

and letbind_aux =  (* Let binding *)
   LB_val of pat * exp (* value binding, implicit type (pat must be total) *)

and letbind = 
   LB_aux of letbind_aux * l


type 
tannot_opt_aux =  (* Optional type annotation for functions *)
   Typ_annot_opt_none
 | Typ_annot_opt_some of typquant * atyp

type
typschm_opt_aux =
  TypSchm_opt_none
| TypSchm_opt_some of typschm

type
typschm_opt =
  TypSchm_opt_aux of typschm_opt_aux * l

type 
effect_opt_aux =  (* Optional effect annotation for functions *)
   Effect_opt_pure (* sugar for empty effect set *)
 | Effect_opt_effect of atyp


type 
rec_opt_aux =  (* Optional recursive annotation for functions *)
   Rec_nonrec (* non-recursive *)
 | Rec_rec (* recursive *)


type 
funcl_aux =  (* Function clause *)
   FCL_Funcl of id * pexp


type 
type_union_aux =  (* Type union constructors *)
   Tu_ty_id of atyp * id
 | Tu_ty_anon_rec of (atyp * id) list * id


type 
name_scm_opt_aux =  (* Optional variable-naming-scheme specification for variables of defined type *)
   Name_sect_none
 | Name_sect_some of string


type 
tannot_opt = 
   Typ_annot_opt_aux of tannot_opt_aux * l


type 
effect_opt = 
   Effect_opt_aux of effect_opt_aux * l


type 
rec_opt = 
   Rec_aux of rec_opt_aux * l


type 
funcl = 
   FCL_aux of funcl_aux * l

type 
type_union = 
   Tu_aux of type_union_aux * l


type 
index_range_aux =  (* index specification, for bitfields in register types *)
   BF_single of Big_int.num (* single index *)
 | BF_range of Big_int.num * Big_int.num (* index range *)
 | BF_concat of index_range * index_range (* concatenation of index ranges *)

and index_range = 
   BF_aux of index_range_aux * l


type 
name_scm_opt = 
   Name_sect_aux of name_scm_opt_aux * l


type 
default_typing_spec_aux =  (* Default kinding or typing assumption, and default order for literal vectors and vector shorthands *)
   DT_order of base_kind * atyp


type mpat_aux =  (* Mapping pattern. Mostly the same as normal patterns but only constructible parts *)
 | MP_lit of lit
 | MP_id of id
 | MP_app of id * ( mpat) list
 | MP_record of ( mfpat) list * bool
 | MP_vector of ( mpat) list
 | MP_vector_concat of ( mpat) list
 | MP_tup of ( mpat) list
 | MP_list of ( mpat) list
 | MP_cons of ( mpat) * ( mpat)
 | MP_string_append of mpat list
 | MP_typ of mpat * atyp
 | MP_as of mpat * id

and mpat =
 | MP_aux of ( mpat_aux) * l

and mfpat_aux =  (* Mapping field pattern, why does this have to exist *)
 | MFP_mpat of id * mpat

and mfpat =
 | MFP_aux of mfpat_aux * l

type mpexp_aux =
 | MPat_pat of ( mpat)
 | MPat_when of ( mpat) * ( exp)

type mpexp =
  | MPat_aux of ( mpexp_aux) * l

type mapcl_aux =  (* mapping clause (bidirectional pattern-match) *)
  | MCL_bidir of ( mpexp) * ( mpexp)
  | MCL_forwards of mpexp * exp
  | MCL_backwards of mpexp * exp

type mapcl =
 | MCL_aux of ( mapcl_aux) * l

type mapdef_aux =  (* mapping definition (bidirectional pattern-match function) *)
 | MD_mapping of id * typschm_opt * ( mapcl) list

type mapdef =
 | MD_aux of ( mapdef_aux) * l


type 
fundef_aux =  (* Function definition *)
   FD_function of rec_opt * tannot_opt * effect_opt * (funcl) list


type 
type_def_aux =  (* Type definition body *)
   TD_abbrev of id * name_scm_opt * typschm (* type abbreviation *)
 | TD_record of id * name_scm_opt * typquant * ((atyp * id)) list * bool (* struct type definition *)
 | TD_variant of id * name_scm_opt * typquant * (type_union) list * bool (* union type definition *)
 | TD_enum of id * name_scm_opt * (id) list * bool (* enumeration type definition *)
 | TD_bitfield of id * atyp * (id * index_range) list (* register mutable bitfield type definition *)

type 
val_spec_aux =  (* Value type specification *)
   VS_val_spec of typschm * id * (string -> string option) * bool


type 
kind_def_aux =  (* Definition body for elements of kind; many are shorthands for type\_defs *)
   KD_abbrev of kind * id * name_scm_opt * typschm (* type abbreviation *)

type 
dec_spec_aux =  (* Register declarations *)
   DEC_reg of atyp * id
 | DEC_config of id * atyp * exp
 | DEC_alias of id * exp
 | DEC_typ_alias of atyp * id * exp


type 
scattered_def_aux =  (* Function and type union definitions that can be spread across
         a file. Each one must end in $_$ *)
   SD_scattered_function of rec_opt * tannot_opt * effect_opt * id (* scattered function definition header *)
 | SD_scattered_funcl of funcl (* scattered function definition clause *)
 | SD_scattered_variant of id * name_scm_opt * typquant (* scattered union definition header *)
 | SD_scattered_unioncl of id * type_union (* scattered union definition member *)
 | SD_scattered_mapping of id * tannot_opt
 | SD_scattered_mapcl of id * mapcl
 | SD_scattered_end of id (* scattered definition end *)


type 
default_typing_spec = 
   DT_aux of default_typing_spec_aux * l


type 
fundef = 
   FD_aux of fundef_aux * l


type 
type_def = 
   TD_aux of type_def_aux * l


type 
val_spec = 
   VS_aux of val_spec_aux * l


type 
kind_def = 
   KD_aux of kind_def_aux * l


type 
dec_spec = 
   DEC_aux of dec_spec_aux * l


type 
scattered_def = 
   SD_aux of scattered_def_aux * l

type prec = Infix | InfixL | InfixR

type fixity_token = (prec * Big_int.num * string)

type
def =  (* Top-level definition *)
   DEF_kind of kind_def (* definition of named kind identifiers *)
 | DEF_type of type_def (* type definition *)
 | DEF_fundef of fundef (* function definition *)
 | DEF_mapdef of mapdef (* mapping definition *)
 | DEF_val of letbind (* value definition *)
 | DEF_overload of id * id list (* operator overload specifications *)
 | DEF_fixity of prec * Big_int.num * id (* fixity declaration *)
 | DEF_spec of val_spec (* top-level type constraint *)
 | DEF_default of default_typing_spec (* default kind and type assumptions *)
 | DEF_scattered of scattered_def (* scattered definition *)
 | DEF_reg_dec of dec_spec (* register declaration *)
 | DEF_pragma of string * string * l
 | DEF_constraint of id * kid list * n_constraint
 | DEF_internal_mutrec of fundef list


type 
lexp_aux =  (* lvalue expression, can't occur out of the parser *)
   LEXP_id of id (* identifier *)
 | LEXP_mem of id * (exp) list
 | LEXP_vector of lexp * exp (* vector element *)
 | LEXP_vector_range of lexp * exp * exp (* subvector *)
 | LEXP_vector_concat of lexp list
 | LEXP_field of lexp * id (* struct field *)

and lexp = 
   LEXP_aux of lexp_aux * l


type 
defs =  (* Definition sequence *)
   Defs of (def) list
