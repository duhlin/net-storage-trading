#ifndef __ADLER32_H__
#define __ADLER32_H__

#include "circular_buffer.h"
#include "typedef.h"

typedef struct {
  CircularBuffer buffer; /**< required when size is provided */
  long unsigned A, B; /** Adler indicators */
} Adler32;

void Adler32_free(Adler32* self);
void Adler32_init(Adler32* self, size_t size);
void Adler32_newByte(Adler32* self, ElemType added);
void Adler32_update(Adler32* self, const ElemType* buffer);
unsigned long Adler32_digest(Adler32* self);

#endif //__ADLER32_H__
