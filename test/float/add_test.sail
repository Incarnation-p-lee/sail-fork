/*==========================================================================*/
/*     Sail                                                                 */
/*                                                                          */
/* Copyright 2024 Intel Corporation                                         */
/*   Pan Li - pan2.li@intel.com                                             */
/*                                                                          */
/* Redistribution and use in source and binary forms, with or without       */
/* modification, are permitted provided that the following conditions are   */
/* met:                                                                     */
/*                                                                          */
/* 1. Redistributions of source code must retain the above copyright        */
/*    notice, this list of conditions and the following disclaimer.         */
/* 2. Redistributions in binary form must reproduce the above copyright     */
/*    notice, this list of conditions and the following disclaimer in the   */
/*    documentation and/or other materials provided with the distribution.  */
/*                                                                          */
/* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      */
/* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        */
/* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A  */
/* PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT       */
/* HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,   */
/* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED */
/* TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR   */
/* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   */
/* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     */
/* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       */
/* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.             */
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

