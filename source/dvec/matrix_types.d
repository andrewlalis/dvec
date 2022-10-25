/**
 * Convenient pre-defined matrix types.
 */
module dvec.matrix_types;

import dvec.matrix : Mat;

/** 
 * A 2x2 matrix of floats.
 */
alias Mat2f = Mat!(float, 2, 2);

/** 
 * A 3x3 matrix of floats.
 */
alias Mat3f = Mat!(float, 3, 3);

/** 
 * A 4x4 matrix of floats.
 */
alias Mat4f = Mat!(float, 4, 4);

/** 
 * A 2x2 matrix of doubles.
 */
alias Mat2d = Mat!(double, 2, 2);

/** 
 * A 3x3 matrix of doubles.
 */
alias Mat3d = Mat!(double, 3, 3);

/** 
 * A 4x4 matrix of doubles.
 */
alias Mat4d = Mat!(double, 4, 4);

/** 
 * A 2x2 matrix of ints.
 */
alias Mat2i = Mat!(int, 2, 2);

/** 
 * A 3x3 matrix of ints.
 */
alias Mat3i = Mat!(int, 3, 3);

/** 
 * A 4x4 matrix of ints.
 */
alias Mat4i = Mat!(int, 4, 4);
