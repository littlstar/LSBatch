## Copyright (c) 2015 Littlstar

## Source files
SRC := $(wildcard src/*.m)

## Source objects
OBJS := $(SRC:.m=.o)

## Target static library name
TARGET_STATIC := libbatch.a

## Compiler flags
CFLAGS += -Iinclude -Wall

## Builds all targets
.PHONY: all
all: $(TARGET_STATIC)

## Builds static library
$(TARGET_STATIC): $(OBJS)
	$(AR) crus $@ $^

## Builds source objects
$(OBJS): $(SRC)
	$(CC) $(CFLAGS) -c $(@:.o=.m) -o $@

## Runs all tests
.PHONY: test
test: $(TARGET_STATIC)
	$(MAKE) -C $@

## Cleans all built files and test executables
.PHONY: clean
clean:
	$(RM) -f $(OBJS)
	$(RM) -f $(TARGET_STATIC)
	$(MAKE) clean -C test
