## libbatch dependency
LIB := ../libbatch.a

## Test source files
SRC := $(wildcard *.m)

## Test source objects
OBJS := $(SRC:.m=.o)

## Test files
TESTS := $(SRC:.m=)

## Compiler flags
CFLAGS += -I../include -Wall

## Linker flags
LDFLAGS += -lobjc -framework Cocoa

## Node executable
NODE := $(shell which node) --harmony

## NPM executable
NPM := $(shell which npm)

## Builds all tests
all: $(TESTS)

## Builds a named test
$(TESTS): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(LIB) $@.o -o $@
	./$@

## Builds test object files
$(OBJS): $(LIB)
$(OBJS): $(SRC)
	$(CC) $(CFLAGS) -c $(@:.o=.m) -o $@

## Ensure dependency library is built
$(LIB):
	$(MAKE) -C ..

## Clean up tests
clean:
	$(RM) -f $(OBJS)
	$(RM) -f $(TESTS)
