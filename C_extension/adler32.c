#include <stdio.h>
#include <stdlib.h>

#include "adler32.h"
 
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
 
int CircularBuffer_isFull(CircularBuffer *cb) {
  return cb->end == cb->start && cb->e_msb != cb->s_msb;
}
 
int CircularBuffer_isEmpty(CircularBuffer *cb) {
  return cb->end == cb->start && cb->e_msb == cb->s_msb;
}

#define CircularBuffer_head(cb) (cb)->elems[(cb)->start]
 
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
  *elem = cb->elems[cb->start];
  cbIncr(cb, &cb->start, &cb->s_msb);
}


#define MOD_ADLER 65521
#define APPLY_MOD_ADLER(a) \
  if ((a) > MOD_ADLER) {\
    a -= MOD_ADLER;\
  } 
#define DECR_MOD_ADLER(a, b) \
  if ((a) < (b)) {\
    a += MOD_ADLER - b; \
  } else { \
    a -= b; \
  }

void Adler32_free(Adler32* self)
{
  CircularBuffer_free(&self->buffer);
}

void Adler32_init(Adler32* self, size_t size)
{
  CircularBuffer_init(&self->buffer, size);
  self->A = 1;
  self->B = 0;
}

void Adler32_newByte(Adler32* self, ElemType added)
{
  ElemType removed;
  if (self->buffer.size > 0)
  {
    // remove head if buffer is full
    if ( CircularBuffer_isFull( &self->buffer ) ) {
      removed = CircularBuffer_head( &self->buffer );
      DECR_MOD_ADLER(self->A, removed)
      DECR_MOD_ADLER(self->B, 1 + self->buffer.size * removed)
    }
    // add new element to buffer
    CircularBuffer_write( &(self->buffer), &added );
  }
  self->A += added;
  self->B += self->A;
  APPLY_MOD_ADLER( self->A )
  APPLY_MOD_ADLER( self->B )
  printf("%d - %ld - %ld\n", added, self->A, self->B);
}

void Adler32_update(Adler32* self, const ElemType* buffer)
{
  size_t i = 0;
  while (buffer[i] != 0) {
    Adler32_newByte(self, buffer[i]);
    ++i;
  }
}

unsigned long Adler32_digest(Adler32* self) {
  return self->B * 65536 + self->A;
}

#ifdef WITHMAIN 
int main(int argc, char* argv[])
{
  const unsigned char str[] = "Wikipedia";
  Adler32 adler;

// test1  
  Adler32_init( &adler, 0 );
  Adler32_update(&adler, str);
  printf("adler=%lx\n", Adler32_digest(&adler)); //expect 11e60398
  Adler32_free(&adler);

// test2
  Adler32_init( &adler, strlen(str) );
  Adler32_update(&adler, str);
  Adler32_update(&adler, str);
  printf("adler=%lx\n", Adler32_digest(&adler)); //expect 11e60398
  Adler32_free(&adler);

  return 0;
}
#endif


