/*==========================================================================*/
/*     Sail                                                                 */
/*                                                                          */
/* Copyright 2024 Intel Corporation                                         */
/*   Pan Li - pan2.li@intel.com                                             */
/*                                                                          */
/*  SPDX-License-Identifier: BSD-2-Clause                                   */
/*==========================================================================*/

default Order dec

$include <prelude.sail>
$include <float/add.sail>
$include "data.sail"
$include "tuple_equality.sail"

function test_float_add () -> unit = {
  /* Half floating point */
  assert(float_add (fp16_pos_denormal_add_0_op_0, fp16_pos_denormal_add_0_op_1) == (fp16_pos_denormal_add_0_sum, fp_eflag_none));
  assert(float_add (fp16_pos_denormal_add_1_op_0, fp16_pos_denormal_add_1_op_1) == (fp16_pos_denormal_add_1_sum, fp_eflag_none));
  assert(float_add (fp16_neg_denormal_add_0_op_0, fp16_neg_denormal_add_0_op_1) == (fp16_neg_denormal_add_0_sum, fp_eflag_none));
  assert(float_add (fp16_neg_denormal_add_1_op_0, fp16_neg_denormal_add_1_op_1) == (fp16_neg_denormal_add_1_sum, fp_eflag_none));

  assert(float_add (fp16_pos_inf, fp16_pos_inf) == (fp16_pos_inf, fp_eflag_none));
  assert(float_add (fp16_pos_inf, fp16_pos_denormal_1) == (fp16_pos_inf, fp_eflag_none));
  assert(float_add (fp16_pos_inf, fp16_pos_normal_0) == (fp16_pos_inf, fp_eflag_none));

  /* Single floating point */
  assert(float_add (fp32_pos_denormal_add_0_op_0, fp32_pos_denormal_add_0_op_1) == (fp32_pos_denormal_add_0_sum, fp_eflag_none));
  assert(float_add (fp32_pos_denormal_add_1_op_0, fp32_pos_denormal_add_1_op_1) == (fp32_pos_denormal_add_1_sum, fp_eflag_none));
  assert(float_add (fp32_neg_denormal_add_0_op_0, fp32_neg_denormal_add_0_op_1) == (fp32_neg_denormal_add_0_sum, fp_eflag_none));
  assert(float_add (fp32_neg_denormal_add_1_op_0, fp32_neg_denormal_add_1_op_1) == (fp32_neg_denormal_add_1_sum, fp_eflag_none));

  assert(float_add (fp32_pos_inf, fp32_pos_inf) == (fp32_pos_inf, fp_eflag_none));
  assert(float_add (fp32_pos_inf, fp32_pos_denormal_1) == (fp32_pos_inf, fp_eflag_none));
  assert(float_add (fp32_pos_inf, fp32_pos_normal_0) == (fp32_pos_inf, fp_eflag_none));

  /* Double floating point */
  assert(float_add (fp64_pos_denormal_add_0_op_0, fp64_pos_denormal_add_0_op_1) == (fp64_pos_denormal_add_0_sum, fp_eflag_none));
  assert(float_add (fp64_pos_denormal_add_1_op_0, fp64_pos_denormal_add_1_op_1) == (fp64_pos_denormal_add_1_sum, fp_eflag_none));
  assert(float_add (fp64_neg_denormal_add_0_op_0, fp64_neg_denormal_add_0_op_1) == (fp64_neg_denormal_add_0_sum, fp_eflag_none));
  assert(float_add (fp64_neg_denormal_add_1_op_0, fp64_neg_denormal_add_1_op_1) == (fp64_neg_denormal_add_1_sum, fp_eflag_none));

  assert(float_add (fp64_pos_inf, fp64_pos_inf) == (fp64_pos_inf, fp_eflag_none));
  assert(float_add (fp64_pos_inf, fp64_pos_denormal_1) == (fp64_pos_inf, fp_eflag_none));
  assert(float_add (fp64_pos_inf, fp64_pos_normal_0) == (fp64_pos_inf, fp_eflag_none));

  /* Quad floating point */
  assert(float_add (fp128_pos_denormal_add_0_op_0, fp128_pos_denormal_add_0_op_1) == (fp128_pos_denormal_add_0_sum, fp_eflag_none));
  assert(float_add (fp128_pos_denormal_add_1_op_0, fp128_pos_denormal_add_1_op_1) == (fp128_pos_denormal_add_1_sum, fp_eflag_none));
  assert(float_add (fp128_neg_denormal_add_0_op_0, fp128_neg_denormal_add_0_op_1) == (fp128_neg_denormal_add_0_sum, fp_eflag_none));
  assert(float_add (fp128_neg_denormal_add_1_op_0, fp128_neg_denormal_add_1_op_1) == (fp128_neg_denormal_add_1_sum, fp_eflag_none));

  assert(float_add (fp128_pos_inf, fp128_pos_inf) == (fp128_pos_inf, fp_eflag_none));
  assert(float_add (fp128_pos_inf, fp128_pos_denormal_1) == (fp128_pos_inf, fp_eflag_none));
  assert(float_add (fp128_pos_inf, fp128_pos_normal_0) == (fp128_pos_inf, fp_eflag_none));
}

function main () -> unit = {
  test_float_add ();
}

