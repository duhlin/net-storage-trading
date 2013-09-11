#ifndef __CIRCULAR_BUFFER_H__
#define __CIRCULAR_BUFFER_H___

#include "typedef.h"
#include <stdlib.h>

/** Circular buffer object */
typedef struct {
  size_t    size;   /** maximum number of elements           */
  size_t    start;  /** index of oldest element              */
  size_t    end;    /** index at which to write new element  */
  int       s_msb;
  int       e_msb;
  ElemType *elems;  /** vector of elements                   */
} CircularBuffer;
 
void CircularBuffer_init(CircularBuffer *cb, int size);
void CircularBuffer_free(CircularBuffer *cb);
 
static int CircularBuffer_isFull(CircularBuffer *cb) {
  return cb->end == cb->start && cb->e_msb != cb->s_msb;
}
 
static int CircularBuffer_isEmpty(CircularBuffer *cb) {
  return cb->end == cb->start && cb->e_msb == cb->s_msb;
}

static ElemType CircularBuffer_head(CircularBuffer *cb) {
  return cb->elems[cb->start];
}
 
void CircularBuffer_write(CircularBuffer *cb, ElemType elem);
ElemType CircularBuffer_read(CircularBuffer *cb);

#endif //__CIRCULAR_BUFFER_H___


