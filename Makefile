SRCDIR=src
TESTDIR=test
BUILDDIR=build

all:	myc

$(SRCDIR)/y.tab.h $(SRCDIR)/y.tab.c :	$(SRCDIR)/myc.y
			bison -v -y -d $(SRCDIR)/myc.y -o $(SRCDIR)/y.tab.c

lex.yy.c: $(SRCDIR)/myc.l $(SRCDIR)/y.tab.h
			flex -t $(SRCDIR)/myc.l > $(SRCDIR)/lex.yy.c

myc: lex.yy.c $(SRCDIR)/y.tab.c $(SRCDIR)/Table_des_symboles.c $(SRCDIR)/Table_des_chaines.c $(SRCDIR)/Attribute.c
			gcc -o myc $(SRCDIR)/lex.yy.c $(SRCDIR)/y.tab.c $(SRCDIR)/Attribute.c $(SRCDIR)/Table_des_symboles.c $(SRCDIR)/Table_des_chaines.c

clean:
			rm -f $(SRCDIR)/lex.yy.c $(SRCDIR)/*.o $(SRCDIR)/y.tab.h $(SRCDIR)/y.tab.c myc *~ $(SRCDIR)/y.output
			rm -f $(TESTDIR)/*.c $(TESTDIR)/*.h $(TESTDIR)/test
			rm -f $(TESTDIR)/test.h $(TESTDIR)/test.c
