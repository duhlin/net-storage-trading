#include <ruby.h>
#include "adler32.h"


static void adler_free(void *p) {
  Adler32_free( (Adler32*)p );
  free(p);
}

static VALUE adler_new(VALUE class, VALUE size)
{
  Adler32* ptr = (Adler32*)malloc(sizeof(Adler32));
  return Data_Wrap_Struct(class, 0, adler_free, ptr);
}

static VALUE adler_init(VALUE self, VALUE size)
{
  Adler32 *ptr;
  Data_Get_Struct(self, Adler32, ptr);

  Adler32_init(ptr, NUM2UINT(size));
  return self;
}

static VALUE adler_newByte(VALUE self, VALUE byte)
{
  Adler32 *ptr;
  Data_Get_Struct(self, Adler32, ptr);
  
  Adler32_newByte(ptr, NUM2CHR(byte));

  return Qnil;
}

static VALUE adler_digest(VALUE self)
{
  Adler32 *ptr;
  Data_Get_Struct(self, Adler32, ptr);

  return INT2NUM( Adler32_digest(ptr) );
}



void Init_adler32() {
  static VALUE cAdler32;
  cAdler32 = rb_define_class("Adler32", rb_cObject);
  rb_define_singleton_method(cAdler32, "new", adler_new, 1);
  rb_define_method(cAdler32, "initialize", adler_init, 1);
  rb_define_method(cAdler32, "newByte", adler_newByte, 1);
  rb_define_method(cAdler32, "digest", adler_digest, 0);
}
