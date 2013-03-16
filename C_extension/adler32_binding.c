#include "adler32.h"
#include <ruby.h>


static void adler_free(Adler32 *p) {
  Adler32_free( p );
  free(p);
}

static VALUE adler_new(VALUE class, VALUE size)
{
  VALUE argv[1];
  Adler32* ptr = (Adler32*)malloc(sizeof(Adler32));
  VALUE ret = Data_Wrap_Struct(class, 0, adler_free, ptr);
  argv[0] = size;
  rb_obj_call_init(ret, 1, argv);
  return ret;
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

static VALUE adler_update(VALUE self, VALUE str)
{
  int i;
  const ElemType* cstr = StringValuePtr(str);
  Adler32 *ptr;
  Data_Get_Struct(self, Adler32, ptr);

  for (i = 0; cstr[i]; ++i) {
    Adler32_newByte(ptr, cstr[i]);
  }
  return Qnil;
}


void Init_adler32() {
  static VALUE cAdler32;
  cAdler32 = rb_define_class("Adler32", rb_cObject);
  rb_define_singleton_method(cAdler32, "new", adler_new, 1);
  rb_define_method(cAdler32, "initialize", adler_init, 1);
  rb_define_method(cAdler32, "newByte", adler_newByte, 1);
  rb_define_method(cAdler32, "update", adler_update, 1);
  rb_define_method(cAdler32, "<<", adler_update, 1);
  rb_define_method(cAdler32, "digest", adler_digest, 0);
}
