/*==========================================================================*/
/*     Sail                                                                 */
/*                                                                          */
/* Copyright 2024 Intel Corporation                                         */
/*   Pan Li - pan2.li@intel.com                                             */
/*                                                                          */
/*  SPDX-License-Identifier: BSD-2-Clause                                   */
/*==========================================================================*/

$ifndef _FLOAT_ARITH_INTERNAL
$define _FLOAT_ARITH_INTERNAL

$include <float/common.sail>
$include <float/zero.sail>
$include <float/nan.sail>

val      float_is_lt_internal : fp_bits_x2 -> bool
function float_is_lt_internal ((op_0, op_1)) = {
  let fp_0 = float_decompose (op_0);
  let fp_1 = float_decompose (op_1);

  let is_zero      = float_is_zero (op_0) & float_is_zero (op_1);
  let diff_sign_lt = is_lowest_one (fp_0.sign) & not (is_zero);

  let is_neg       = is_lowest_one (fp_0.sign);
  let unsigned_lt  = unsigned (op_0) < unsigned (op_1);
  let is_xor       = (is_neg & not (unsigned_lt)) | (not (is_neg) & unsigned_lt);
  let same_sign_lt = (op_0 != op_1) & is_xor;

  let is_lt = if   fp_0.sign != fp_1.sign
              then diff_sign_lt
              else same_sign_lt;

  is_lt;
}

val      float_is_eq_internal : fp_bits_x2 -> bool
function float_is_eq_internal ((op_0, op_1)) = {
  let is_zero = float_is_zero (op_0) & float_is_zero (op_1);
  let is_eq   = (op_0 == op_1) | is_zero;

  is_eq;
}

val      float_is_ne_internal : fp_bits_x2 -> bool
function float_is_ne_internal ((op_0, op_1))
  = not (float_is_eq_internal ((op_0, op_1)))

val      float_is_le_internal : fp_bits_x2 -> bool
function float_is_le_internal ((op_0, op_1))
  = float_is_eq_internal ((op_0, op_1)) | float_is_lt_internal ((op_0, op_1))

val      float_is_gt_internal : fp_bits_x2 -> bool
function float_is_gt_internal ((op_0, op_1))
  = not (float_is_le_internal ((op_0, op_1)))

val      float_is_ge_internal : fp_bits_x2 -> bool
function float_is_ge_internal ((op_0, op_1))
  = not (float_is_lt_internal ((op_0, op_1)))

val      float_add_internal : forall 'n, 'n in {16, 32, 64, 128}.
  (bits('n), bits('n)) -> (bits('n), fp_exception_flags)
function float_add_internal (op_0, op_1) = {
  let fp_0 = float_decompose (op_0);
  let fp_1 = float_decompose (op_1);
  let exp_diff = sub_bits (fp_0.exp, fp_1.exp);
  let zero_exp_diff = is_all_zeros (exp_diff);

  let bitsize = length (op_0);
  let sum = if zero_exp_diff & is_all_zeros (fp_0.exp)
            then op_0 + sail_zero_extend (fp_1.mantissa, bitsize)
            else if is_all_ones (fp_0.exp)
                 then op_0
            else {
              assert (false, "Not implemented yet.");
              sail_zeros ('n);
            };

  (sum, fp_eflag_none);
}

val      float_sub_internal : forall 'n, 'n in {16, 32, 64, 128}.
  (bits('n), bits('n)) -> (bits('n), fp_exception_flags)
function float_sub_internal (op_0, op_1) = {
  assert (false, "Not implemented yet.");
  (sail_zeros ('n), fp_eflag_none);
}

$endif
