/*
 *  Attribute.h
 *
 *  Created by Janin on 10/2019
 *  Copyright 2018 LaBRI. All rights reserved.
 *
 *  Module for a clean handling of attibutes values
 *
 */

#ifndef ATTRIBUTE_H
#define ATTRIBUTE_H

#include <stdio.h>

typedef enum {INT, FLOAT} type;

struct ATTRIBUTE {
  char * name;
  int int_val;
  float float_val;
  type type_val;
  int reg_number;

  /* other attribute's fields can goes here */

};

typedef struct ATTRIBUTE * attribute;

attribute new_attribute ();
/* returns the pointeur to a newly allocated (but uninitialized) attribute value structure */


attribute plus_attribute(attribute x, attribute y);
attribute mult_attribute(attribute x, attribute y);
attribute minus_attribute(attribute x, attribute y);
attribute div_attribute(attribute x, attribute y);
attribute neg_attribute(attribute x);
int new_registre();
int new_l_number();
char* getType(type t);

FILE* test_c;
FILE* test_h;

#endif
