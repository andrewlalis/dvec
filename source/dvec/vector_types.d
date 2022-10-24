/** 
 * Convenient pre-defined vector types.
 */
module dvec.vector_types;

import dvec.vector : Vec;

/** 
 * A 2-dimensional vector of floats.
 */
alias Vec2f = Vec!(float, 2);

/** 
 * A 3-dimensional vector of floats.
 */
alias Vec3f = Vec!(float, 3);

/** 
 * A 4-dimensional vector of floats.
 */
alias Vec4f = Vec!(float, 4);

/** 
 * A 2-dimensional vector of doubles.
 */
alias Vec2d = Vec!(double, 2);

/** 
 * A 3-dimensional vector of doubles.
 */
alias Vec3d = Vec!(double, 3);

/** 
 * A 4-dimensional vector of doubles.
 */
alias Vec4d = Vec!(double, 4);

/** 
 * A 2-dimensional vector of ints.
 */
alias Vec2i = Vec!(int, 2);

/** 
 * A 3-dimensional vector of ints.
 */
alias Vec3i = Vec!(int, 3);

/** 
 * A 4-dimensional vector of ints.
 */
alias Vec4i = Vec!(int, 4);