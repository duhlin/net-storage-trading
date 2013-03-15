#ifndef __ADLER32_H__
#define __ADLER32_H__

typedef unsigned char ElemType;

/** Circular buffer object */
typedef struct {
  size_t    size;   /** maximum number of elements           */
  size_t    start;  /** index of oldest element              */
  size_t    end;    /** index at which to write new element  */
  int       s_msb;
  int       e_msb;
  ElemType *elems;  /** vector of elements                   */
} CircularBuffer;
 
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
