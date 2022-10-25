/**
 * The main module for the dvec library. Publicly imports all components
 * so you just need to `import dvec;`
 */
module dvec;

/**
 * Imports the `Vec` struct for vectors.
 */
public import dvec.vector;

/**
 * Imports common vector types.
 */
public import dvec.vector_types;

/**
 * Imports the `Mat` struct for matrices.
 */
public import dvec.matrix;

/**
 * Imports common matrix types.
 */
public import dvec.matrix_types;
