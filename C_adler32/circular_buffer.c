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
 
void CircularBuffer_write(CircularBuffer *cb, ElemType elem) {
  cb->elems[cb->end] = elem;
  if (CircularBuffer_isFull(cb))  { // full, overwrite moves start pointer
    cbIncr(cb, &cb->start, &cb->s_msb);
  }
  cbIncr(cb, &cb->end, &cb->e_msb);
}
 
ElemType CircularBuffer_read(CircularBuffer *cb) {
  ElemType ret;
  // buffer should not be empty to be read
  assert( CircularBuffer_isEmpty(cb) == 0 );
  ret = cb->elems[cb->start];
  cbIncr(cb, &cb->start, &cb->s_msb);
  return ret;
}

#ifdef UT
#include <stdio.h>
int main(int argc, char* argv[])
{
  CircularBuffer buffer;
  CircularBuffer_init(&buffer, 3);
  assert( CircularBuffer_isEmpty(&buffer) );
  
  CircularBuffer_write(&buffer, '1');
  assert( CircularBuffer_isEmpty(&buffer) == 0 );
  assert( CircularBuffer_head(&buffer) == '1' );

  CircularBuffer_write(&buffer, '2');
  assert( CircularBuffer_head(&buffer) == '1' );
  
  CircularBuffer_write(&buffer, '3');
  assert( CircularBuffer_isFull(&buffer) );
  assert( CircularBuffer_head(&buffer) == '1' );

  CircularBuffer_write(&buffer, '4');
  assert( CircularBuffer_isFull(&buffer) );
  assert( CircularBuffer_head(&buffer) == '2' );

  assert( CircularBuffer_read(&buffer) == '2' ); // '1' was overwritten when buffer was full
  assert( CircularBuffer_isFull(&buffer) == 0 );
  assert( CircularBuffer_read(&buffer) == '3' ); 
  assert( CircularBuffer_read(&buffer) == '4' );
  assert( CircularBuffer_isEmpty(&buffer) );

  printf("Circular Buffer: All tests PASSED.\n");
  return 0;
}
#endif
