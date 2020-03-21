#include "Attribute.h"

#include <stdlib.h>

int reg_id_counter = 0;
int l_number_counter = 0;

attribute new_attribute () {
  attribute r;
  r  = malloc (sizeof (struct ATTRIBUTE));
  return r;
};


attribute plus_attribute(attribute x, attribute y) {
  attribute r = new_attribute();
  /* unconditionally adding integer values */
  r -> int_val = x -> int_val + y -> int_val;
  return r;
};

attribute mult_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  /* unconditionally adding integer values */
  r -> int_val = x -> int_val * y -> int_val;
  return r;
};

attribute minus_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  /* unconditionally adding integer values */
  r -> int_val = x -> int_val - y -> int_val;
  return r;
};

attribute div_attribute(attribute x, attribute y){
  attribute r = new_attribute();
  /* unconditionally adding integer values */
  r -> int_val = x -> int_val % y -> int_val;
  return r;
};

attribute neg_attribute(attribute x){
  attribute r = new_attribute();
  /* unconditionally adding integer values */
  r -> int_val = -(x -> int_val);
  return r;
};


int new_registre()
{
  reg_id_counter ++;
  return reg_id_counter;
}

int new_l_number()
{
  l_number_counter ++;
  return l_number_counter;
}

char* getType(type t)
{
  switch (t) {
    case 0: return "int";
    case 1: return "float";
  }
}
