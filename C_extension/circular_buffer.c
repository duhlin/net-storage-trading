#include "circular_buffer.h"
#include <assert.h>

void CircularBuffer_init(CircularBuffer *cb, int size) {
  cb->size  = size;
  cb->start = 0;
  cb->end   = 0;
  cb->s_msb = 0;
  cb->e_msb = 0;
  if (size > 0) {
    cb->elems = (ElemType *)calloc(cb->size, sizeof(ElemType));
  } else {
    cb->elems = NULL;
  }
}

void CircularBuffer_free(CircularBuffer *cb) {
  if (cb->elems != NULL) {
    free(cb->elems);
  }
}
 
static void cbIncr(CircularBuffer *cb, size_t *p, int *msb) {
  *p = *p + 1;
  if (*p == cb->size) {
    *msb ^= 1;
    *p = 0;
  }
}
 
void CircularBuffer_write(CircularBuffer *cb, ElemType *elem) {
  cb->elems[cb->end] = *elem;
  if (CircularBuffer_isFull(cb))  { // full, overwrite moves start pointer
    cbIncr(cb, &cb->start, &cb->s_msb);
  }
  cbIncr(cb, &cb->end, &cb->e_msb);
}
 
void CircularBuffer_read(CircularBuffer *cb, ElemType *elem) {
  // buffer should not be empty to be read
  assert( CircularBuffer_isEmpty(cb) == 0 );
  *elem = cb->elems[cb->start];
  cbIncr(cb, &cb->start, &cb->s_msb);
}


